<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Company;
use App\Models\WorkOrder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    private function query(Request $r)
    {
        $r->validate(['empresa_id' => 'nullable|exists:empresas,id', 'from' => 'nullable|date', 'to' => 'nullable|date|after_or_equal:from']);
        $q = WorkOrder::with(['order.purchaseOrder.company', 'order.purchaseOrder.client', 'order.product', 'order.material', 'furnace', 'inspections.user', 'events.user'])->where('estado', 'terminado');
        if ($r->filled('empresa_id')) {
            $q->whereHas('order.purchaseOrder', fn ($p) => $p->where('empresa_id', $r->empresa_id));
        }
        if ($r->filled('from')) {
            $q->whereDate('terminado_en', '>=', $r->from);
        }
        if ($r->filled('to')) {
            $q->whereDate('terminado_en', '<=', $r->to);
        }

        return $q->orderByDesc('terminado_en');
    }

    public function index(Request $r)
    {
        return view('reports.index', ['ots' => $this->query($r)->paginate(30)->withQueryString(), 'print' => false, 'empresas' => Company::all()]);
    }

    public function print(Request $r)
    {
        return view('reports.index', ['ots' => $this->query($r)->get(), 'print' => true, 'empresas' => Company::all()]);
    }

    public function csv(Request $r)
    {
        $query = $this->query($r);

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');
            fwrite($out, "\xEF\xBB\xBF");
            $write = function (array $row) use ($out) {
                $row = array_map(fn ($v) => preg_match('/^[=+@\-\t\r]/u', (string) $v) ? "'".$v : $v, $row);
                fputcsv($out, $row, ',', '"', '');
            };
            $write(['Empresa', 'OT', 'Tipo OT', 'Pedido', 'OC exterior', 'OC interior', 'Cliente', 'Producto', 'Material', 'Peso kg', 'Finalización', 'Cumplimiento', 'Calidad', 'C %', 'Si %', 'Mn %', 'P %', 'S %', 'Porosidad']);
            foreach ($query->lazy(200) as $ot) {
                $p = $ot->order->purchaseOrder;
                $i = $ot->inspections->sortByDesc('id')->first();
                $write([$p->company->nombre, $ot->codigo, $ot->tipo, $ot->order->codigo, $p->numero_externo, $p->numero_interno, $p->client->nombre, $ot->order->product->nombre, $ot->order->material->nombre, $ot->peso_kg, $ot->terminado_en->format('Y-m-d H:i'), $ot->terminado_a_tiempo === null ? 'Sin compromiso' : ($ot->terminado_a_tiempo ? 'A tiempo' : 'Fuera de tiempo'), $i?->dictamen ?? 'Sin inspección', $i?->carbono, $i?->silicio, $i?->manganeso, $i?->fosforo, $i?->azufre, $i ? ($i->porosidad ? 'Sí' : 'No') : 'Sin registro']);
            }
            fclose($out);
        }, 'SSMF_SFS_produccion_'.now()->format('Ymd').'.csv', ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    public function inspect(Request $r, WorkOrder $workOrder)
    {
        abort_unless($r->user()->canInspect(), 403);
        abort_unless($workOrder->estado === 'terminado', 422);
        $rules = ['dictamen' => 'required|in:aprobado,rechazado', 'porosidad' => 'nullable|boolean', 'observaciones' => 'nullable|string|max:5000'];
        foreach (['carbono', 'silicio', 'manganeso', 'fosforo', 'azufre'] as $e) {
            $rules[$e] = 'nullable|numeric|between:0,100';
        }
        $d = $r->validate($rules);
        $d['porosidad'] = $r->boolean('porosidad');
        DB::transaction(function () use ($workOrder, $d, $r) {
            $i = $workOrder->inspections()->create($d + ['usuario_id' => $r->user()->id]);
            AuditLog::create(['usuario_id' => $r->user()->id, 'accion' => 'calidad.registrada', 'entidad' => 'inspecciones_calidad', 'entidad_id' => $i->id]);
        });

        return back()->with('success', 'Inspección guardada con fecha y responsable.');
    }
}
