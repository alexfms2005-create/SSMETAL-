<?php

namespace App\Http\Controllers;

use App\Models\Furnace;
use App\Models\Order;
use App\Models\WorkOrder;
use App\Services\WorkOrderFlow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class WorkOrderController extends Controller
{
    public function create(Request $r)
    {
        abort_unless($r->user()->canOperate(), 403);
        $pedidos = Order::with(['product', 'material', 'purchaseOrder.company', 'purchaseOrder.client'])->where(fn ($q) => $q->where(fn ($f) => $f->where('tipo_pedido', 'fundicion')->where('peso_por_fundir_kg', '>', 0))->orWhere(fn ($m) => $m->where('tipo_pedido', 'modelo')->where('cantidad_pendiente', '>', 0)))->whereDoesntHave('workOrders', fn ($q) => $q->where('estado', 'en_proceso'))->orderByDesc('id')->get();

        return view('work-orders.create', ['pedidos' => $pedidos, 'hornos' => Furnace::all(), 'selected' => $r->integer('order')]);
    }

    public function store(Request $r, WorkOrderFlow $flow)
    {
        abort_unless($r->user()->canOperate(), 403);
        $d = $r->validate(['pedido_id' => 'required|exists:pedidos,id', 'tipo' => 'required|in:interna,externa', 'horno_id' => 'nullable|exists:hornos,id', 'peso_kg' => 'nullable|numeric|min:0|max:999999999', 'cantidad' => 'nullable|integer|min:1|max:1000000', 'minutos_estimados' => 'required|integer|min:1|max:100000', 'observaciones' => 'nullable|string|max:5000']);
        $ot = $flow->create($d, $r->user());

        return redirect()->route('process')->with('success', 'OT '.$ot->codigo.' creada y guardada.');
    }

    public function process(Request $r)
    {
        $r->validate(['tipo' => 'nullable|in:interna,externa']);
        $query = WorkOrder::with(['order.product', 'order.material', 'order.purchaseOrder.client', 'order.purchaseOrder.company', 'furnace', 'events.user'])->where('estado', 'en_proceso');
        if ($r->filled('tipo')) {
            $query->where('tipo', $r->tipo);
        }

        return view('work-orders.process', ['ots' => $query->latest()->get(), 'hornos' => Furnace::with('activeWorkOrder')->get()]);
    }

    public function advance(Request $r, WorkOrder $workOrder, WorkOrderFlow $flow)
    {
        abort_unless($r->user()->canOperate(), 403);
        $d = $r->validate(['avance' => 'required|integer|min:1|max:100', 'observaciones' => 'nullable|string|max:3000']);
        $flow->advance($workOrder->id, $d['avance'], $r->user(), $d['observaciones'] ?? null);

        return back()->with('success', 'Avance registrado.');
    }

    public function furnace(Request $r, Furnace $furnace)
    {
        abort_unless($r->user()->canManage(), 403);
        $d = $r->validate(['estado' => 'required|in:disponible,mantenimiento', 'temperatura_actual' => 'nullable|integer|min:0|max:3000']);
        DB::transaction(function () use ($furnace, $d) {
            $f = Furnace::lockForUpdate()->findOrFail($furnace->id);
            if ($f->activeWorkOrder()->exists()) {
                throw ValidationException::withMessages(['furnace' => 'No se puede desactivar un horno ocupado.']);
            } $f->update($d);
        });

        return back()->with('success', 'Estado del horno actualizado.');
    }

    public function completed(Request $r)
    {
        $r->validate(['tipo' => 'nullable|in:interna,externa']);
        $query = WorkOrder::with(['order.product', 'order.material', 'order.purchaseOrder.company', 'order.purchaseOrder.client', 'furnace', 'inspections'])->where('estado', 'terminado');
        if ($r->filled('tipo')) {
            $query->where('tipo', $r->tipo);
        }
        $total = (clone $query)->count();
        $eligible = (clone $query)->whereNotNull('terminado_a_tiempo')->count();
        $onTime = (clone $query)->where('terminado_a_tiempo', true)->count();

        return view('work-orders.completed', ['ots' => $query->latest('terminado_en')->paginate(30)->withQueryString(), 'total' => $total, 'rate' => $eligible ? round($onTime * 100 / $eligible, 1) : null]);
    }
}
