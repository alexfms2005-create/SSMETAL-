<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'pedidos';

    protected $guarded = ['id'];

    public function purchaseOrder()
    {
        return $this->belongsTo(PurchaseOrder::class, 'orden_compra_id');
    }

    public function product()
    {
        return $this->belongsTo(Product::class, 'producto_id');
    }

    public function material()
    {
        return $this->belongsTo(Material::class, 'material_id');
    }

    public function castingLevel()
    {
        return $this->belongsTo(CastingLevel::class, 'nivel_fundicion_id');
    }

    public function processStatus()
    {
        return $this->belongsTo(ProcessStatus::class, 'estado_proceso_id');
    }

    public function workOrders()
    {
        return $this->hasMany(WorkOrder::class, 'pedido_id');
    }

    protected function casts(): array
    {
        return ['inicio_programacion' => 'date', 'fin_programacion' => 'date', 'requiere_maquinado' => 'boolean', 'modelo_recibido' => 'boolean'];
    }
}
