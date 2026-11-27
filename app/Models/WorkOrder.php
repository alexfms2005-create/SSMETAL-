<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WorkOrder extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'ordenes_trabajo';

    protected $guarded = ['id'];

    public function order()
    {
        return $this->belongsTo(Order::class, 'pedido_id');
    }

    public function furnace()
    {
        return $this->belongsTo(Furnace::class, 'horno_id');
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'creado_por');
    }

    public function events()
    {
        return $this->hasMany(WorkOrderEvent::class, 'orden_trabajo_id');
    }

    public function inspections()
    {
        return $this->hasMany(QualityInspection::class, 'orden_trabajo_id');
    }

    protected function casts(): array
    {
        return ['iniciado_en' => 'datetime', 'terminado_en' => 'datetime', 'terminado_a_tiempo' => 'boolean'];
    }
}
