<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WorkOrderEvent extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'historial_ordenes_trabajo';

    protected $guarded = ['id'];

    public function user()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function workOrder()
    {
        return $this->belongsTo(WorkOrder::class, 'orden_trabajo_id');
    }
}
