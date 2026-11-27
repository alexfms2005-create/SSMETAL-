<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Furnace extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'hornos';

    protected $guarded = ['id'];

    public function workOrders()
    {
        return $this->hasMany(WorkOrder::class, 'horno_id');
    }

    public function activeWorkOrder()
    {
        return $this->hasOne(WorkOrder::class, 'horno_id')->where('estado', 'en_proceso');
    }
}
