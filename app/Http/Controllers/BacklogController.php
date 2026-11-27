<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\CastingLevel;
use App\Models\Client;
use App\Models\Company;
use App\Models\Material;
use App\Models\Order;
use App\Models\ProcessStatus;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Services\DocumentCode;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class BacklogController extends Controller
{
    public function index(Request $r)
    {
        $r->validate(['from' => 'nullable|date', 'to' => 'nullable|date|after_or_equal:from', 'tipo_pedido' => 'nullable|in:fundicion,modelo', 'assignment' => 'nullable|in:unassigned,assigned', 'empresa_id' => 'nullable|exists:empresas,id', 'material_id' => 'nullable|exists:materiales,id', 'status_id' => 'nullable|exists:estados_proceso,id', 'q' => 'nullable|string|max:150']);
        $query = Order::with(['purchaseOrder.company', 'purchaseOrder.client', 'product', 'material', 'castingLevel', 'processStatus', 'workOrders']);
        if ($r->filled('tipo_pedido')) {
            $query->where('tipo_pedido', $r->tipo_pedido);
        }
        if ($r->filled('empresa_id')) {
            $query->whereHas('purchaseOrder', fn ($q) => $q->where('empresa_id', $r->empresa_id));
        }
        if ($r->filled('status_id')) {
            $query->where('estado_proceso_id', $r->status_id);
        }
        if ($r->filled('material_id')) {
            $query->where('material_id', $r->material_id);
        }
        if ($r->assignment === 'unassigned') {
            $query->whereNull('inicio_programacion');
        }
        if ($r->assignment === 'assigned') {
            $query->whereNotNull('inicio_programacion');
        }
        if ($r->filled('from')) {
            $query->where('fin_programacion', '>=', $r->date('from')->toDateString());
        }
        if ($r->filled('to')) {
            $query->where('inicio_programacion', '<=', $r->date('to')->toDateString());
        }
        if ($r->filled('q')) {
            $term = '%'.$r->q.'%';
            $query->where(fn ($q) => $q->where('codigo', 'like', $term)->orWhereHas('product', fn ($p) => $p->where('nombre', 'like', $term)->orWhere('codigo_interno', 'like', $term))->orWhereHas('purchaseOrder', fn ($p) => $p->where('numero_interno', 'like', $term)->orWhere('numero_externo', 'like', $term)->orWhereHas('client', fn ($c) => $c->where('nombre', 'like', $term))));
        }
        $stats = ['count' => (clone $query)->count(), 'weight' => (clone $query)->sum('peso_por_fundir_kg'), 'unassigned' => (clone $query)->whereNull('inicio_programacion')->count()];
        $pedidos = $query->orderByRaw('inicio_programacion IS NOT NULL')->orderBy('inicio_programacion')->orderByDesc('id')->paginate(40)->withQueryString();

        return view('backlog.index', compact('pedidos', 'stats') + $this->catalogs());
    }

    private function catalogs(): array
    {
        return ['empresas' => Company::all(), 'clientes' => Client::orderBy('nombre')->get(), 'productos' => Product::orderBy('nombre')->get(), 'materiales' => Material::orderBy('nombre')->get(), 'levels' => CastingLevel::orderBy('nivel')->get(), 'statuses' => ProcessStatus::orderBy('posicion')->get(), 'purchases' => PurchaseOrder::with(['company', 'client'])->orderByDesc('id')->get()];
    }

    public function create()
    {
        abort_unless(auth()->user()->canManage(), 403);

        return view('backlog.form', ['order' => new Order] + $this->catalogs());
    }

    public function edit(Order $order)
    {
        abort_unless(auth()->user()->canManage(), 403);

        return view('backlog.form', compact('order') + $this->catalogs());
    }

    public function store(Request $r)
    {
        return $this->save($r, new Order);
    }

    public function update(Request $r, Order $order)
    {
        return $this->save($r, $order);
    }

    private function save(Request $r, Order $order)
    {
        abort_unless($r->user()->canManage(), 403);
        $d = $r->validate(['orden_compra_id' => 'required|exists:ordenes_compra,id', 'producto_id' => 'required|exists:productos,id', 'material_id' => 'required|exists:materiales,id', 'nivel_fundicion_id' => 'nullable|exists:niveles_fundicion,id', 'estado_proceso_id' => 'required|exists:estados_proceso,id', 'tipo_pedido' => ['required', Rule::in(['fundicion', 'modelo'])], 'cantidad' => 'required|integer|min:1|max:1000000', 'peso_unitario_kg' => ($r->input('tipo_pedido') === 'modelo' ? 'required|numeric|min:0|max:999999999' : 'required|numeric|min:0.001|max:999999999'), 'requiere_maquinado' => 'nullable|boolean', 'modelo_recibido' => 'nullable|boolean', 'observaciones' => 'nullable|string|max:5000', 'anio_programacion' => 'nullable|required_with:scheduled_week|integer|min:2020|max:2100', 'semana_programacion' => 'nullable|required_with:scheduled_year|integer|min:1|max:53']);
        $d['requiere_maquinado'] = $r->boolean('requiere_maquinado');
        $d['modelo_recibido'] = $r->boolean('modelo_recibido');
        if ($d['cantidad'] * $d['peso_unitario_kg'] > 99999999999.999) {
            throw ValidationException::withMessages(['cantidad' => 'El peso total del pedido excede el máximo permitido.']);
        }
        $d['inicio_programacion'] = $d['fin_programacion'] = null;
        if (! empty($d['semana_programacion'])) {
            $date = CarbonImmutable::now()->setISODate((int) $d['anio_programacion'], (int) $d['semana_programacion'])->startOfWeek();
            if ($date->isoWeekYear() !== (int) $d['anio_programacion'] || $date->isoWeek() !== (int) $d['semana_programacion']) {
                throw ValidationException::withMessages(['semana_programacion' => 'La semana no existe en ese año.']);
            }
            $d['inicio_programacion'] = $date->toDateString();
            $d['fin_programacion'] = $date->endOfWeek()->toDateString();
        }
        DB::transaction(function () use ($d, $order, $r) {
            $existing = $order->exists;
            if ($existing) {
                $order = Order::lockForUpdate()->findOrFail($order->id);
                if ($order->workOrders()->exists() && collect($d)->only(['orden_compra_id', 'producto_id', 'material_id', 'tipo_pedido', 'cantidad', 'peso_unitario_kg'])->contains(fn ($v, $k) => $v != $order->$k)) {
                    throw ValidationException::withMessages(['order' => 'Un pedido con OTs conserva sus datos de producción. Puedes cambiar programación, nivel, estado y notas.']);
                }
            }
            $companyId = PurchaseOrder::findOrFail($d['orden_compra_id'])->empresa_id;
            if (! $existing || $order->tipo_pedido !== $d['tipo_pedido'] || (int) $order->purchaseOrder->empresa_id !== (int) $companyId) {
                $d['codigo'] = DocumentCode::next($companyId, $d['tipo_pedido'] === 'modelo' ? 'PM' : 'PF');
            }
            if (! $existing || ! $order->workOrders()->exists()) {
                $d['peso_por_fundir_kg'] = round($d['cantidad'] * $d['peso_unitario_kg'], 3);
                $d['cantidad_pendiente'] = $d['cantidad'];
            }
            $order->fill($d)->save();
            AuditLog::create(['usuario_id' => $r->user()->id, 'accion' => $existing ? 'pedido.actualizado' : 'pedido.creado', 'entidad' => 'pedidos', 'entidad_id' => $order->id]);
        }, 3);

        return redirect()->route('backlog')->with('success', 'Pedido guardado. La programación solo cambia cuando tú la asignas.');
    }
}
