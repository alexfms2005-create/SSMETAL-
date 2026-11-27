<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AuditLog extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'bitacora_sistema';

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['detalles' => 'array'];
    }
}
