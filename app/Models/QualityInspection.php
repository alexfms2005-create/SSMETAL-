<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QualityInspection extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'inspecciones_calidad';

    protected $guarded = ['id'];

    public function workOrder()
    {
        return $this->belongsTo(WorkOrder::class, 'orden_trabajo_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    protected function casts(): array
    {
        return ['porosidad' => 'boolean'];
    }
}
