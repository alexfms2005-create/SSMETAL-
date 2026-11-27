<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\Furnace;
use App\Models\Order;
use App\Models\ProcessStatus;
use App\Models\User;
use App\Models\WorkOrder;
use App\Models\WorkOrderEvent;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class WorkOrderFlow
{
    public function create(array $data, User $user): WorkOrder
    {
        return DB::transaction(function () use ($data, $user) {
            $order = Order::with('purchaseOrder')->lockForUpdate()->findOrFail($data['pedido_id']);
            if ($order->workOrders()->where('estado', 'en_proceso')->exists()) {
                $this->fail('El pedido ya tiene una OT en proceso.');
            }
            $isModel = $order->tipo_pedido === 'modelo';
            if (! $isModel && (float) $order->peso_por_fundir_kg <= 0) {
                $this->fail('El pedido no tiene peso pendiente.');
            }
            $cantidad = $isModel ? (int) ($data['cantidad'] ?? 0) : null;
            if ($isModel && ($cantidad < 1 || $cantidad > $order->cantidad_pendiente)) {
                $this->fail('La cantidad debe estar entre 1 y las piezas pendientes del modelo.');
            }
            $weight = $isModel ? round($cantidad * (float) $order->peso_unitario_kg, 3) : (float) ($data['peso_kg'] ?? 0);
            if (! $isModel && ($weight <= 0 || $weight > (float) $order->peso_por_fundir_kg)) {
                $this->fail('El peso debe ser positivo y no superar el pendiente del pedido.');
            }
            $furnace = null;
            if ($order->tipo_pedido === 'fundicion') {
                if (empty($data['horno_id'])) {
                    $this->fail('Selecciona un horno para el pedido de fundición.');
                }
                if (! $order->modelo_recibido) {
                    $this->fail('El modelo no está disponible; actualiza el pedido antes de fundir.');
                }
                $furnace = Furnace::lockForUpdate()->findOrFail($data['horno_id']);
                if ($furnace->estado !== 'disponible' || $furnace->activeWorkOrder()->exists()) {
                    $this->fail('El horno está ocupado o en mantenimiento.');
                }
                if ($weight > (float) $furnace->capacidad_kg) {
                    $this->fail('El peso supera la capacidad del horno. Divide el pedido en coladas.');
                }
            }
            $ot = WorkOrder::create([
                'codigo' => DocumentCode::next($order->purchaseOrder->empresa_id, $data['tipo'] === 'interna' ? 'OTI' : 'OTE'),
                'pedido_id' => $order->id, 'horno_id' => $furnace?->id, 'creado_por' => $user->id, 'tipo' => $data['tipo'],
                'peso_kg' => $weight, 'cantidad' => $cantidad, 'minutos_estimados' => $data['minutos_estimados'], 'observaciones' => $data['observaciones'] ?? null,
                'avance' => 0, 'estado' => 'en_proceso',
                'iniciado_en' => now(), 'fase' => $order->tipo_pedido === 'modelo' ? 'Preparación de modelo' : 'Carga inicial',
            ]);
            if ($furnace) {
                $furnace->update(['estado' => 'en_proceso']);
            }
            $order->update(['estado_proceso_id' => ProcessStatus::where('codigo', $order->tipo_pedido === 'modelo' ? 'moldeo' : 'fusion')->value('id')]);
            $this->event($ot, $user, 'OT creada');

            return $ot;
        }, 3);
    }

    public function advance(int $id, int $avance, User $user, ?string $observaciones = null): WorkOrder
    {
        return DB::transaction(function () use ($id, $avance, $user, $observaciones) {
            $ot = WorkOrder::lockForUpdate()->findOrFail($id);
            $order = Order::with('purchaseOrder')->lockForUpdate()->findOrFail($ot->pedido_id);
            if ($ot->estado !== 'en_proceso') {
                $this->fail('La OT ya está terminada.');
            }
            if ($avance <= $ot->avance || $avance > 100) {
                $this->fail('El avance debe aumentar y no superar el 100%.');
            }
            $fase = $order->tipo_pedido === 'modelo' ? 'Fabricación de modelo' : ($avance < 30 ? 'Carga' : ($avance < 70 ? 'Fusión' : ($avance < 90 ? 'Afino' : 'Vaciado')));
            $values = ['avance' => $avance, 'fase' => $fase];
            if ($avance === 100) {
                $deadline = $order->purchaseOrder->fecha_compromiso;
                $values += ['estado' => 'terminado', 'fase' => 'Terminada', 'terminado_en' => now(), 'terminado_a_tiempo' => $deadline ? now()->lte($deadline->copy()->endOfDay()) : null];
                $remaining = max(0, round((float) $order->peso_por_fundir_kg - (float) $ot->peso_kg, 3));
                $remainingQuantity = $order->tipo_pedido === 'modelo' ? max(0, $order->cantidad_pendiente - $ot->cantidad) : ((float) $order->peso_unitario_kg > 0 ? min($order->cantidad, (int) ceil($remaining / $order->peso_unitario_kg)) : 0);
                $pending = $order->tipo_pedido === 'modelo' ? $remainingQuantity > 0 : $remaining > 0;
                $next = $pending ? 'pendiente' : ($order->tipo_pedido === 'modelo' ? 'terminado' : ($order->requiere_maquinado ? 'maquinado' : 'acabados'));
                $order->update(['peso_por_fundir_kg' => $remaining, 'cantidad_pendiente' => $remainingQuantity, 'estado_proceso_id' => ProcessStatus::where('codigo', $next)->value('id')]);
                if ($ot->horno_id) {
                    Furnace::whereKey($ot->horno_id)->lockForUpdate()->firstOrFail()->update(['estado' => 'disponible']);
                }
            }
            $ot->update($values);
            $this->event($ot, $user, $observaciones);

            return $ot;
        }, 3);
    }

    private function event(WorkOrder $ot, User $user, ?string $observaciones): void
    {
        WorkOrderEvent::create(['orden_trabajo_id' => $ot->id, 'usuario_id' => $user->id, 'avance' => $ot->avance, 'fase' => $ot->fase, 'observaciones' => $observaciones]);
        AuditLog::create(['usuario_id' => $user->id, 'accion' => 'work_pedido.actualizado', 'entidad' => 'ordenes_trabajo', 'entidad_id' => $ot->id, 'detalles' => ['avance' => $ot->avance, 'estado' => $ot->estado]]);
    }

    private function fail(string $message): never
    {
        throw ValidationException::withMessages(['operation' => $message]);
    }
}
