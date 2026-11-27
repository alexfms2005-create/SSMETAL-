<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'empresas';

    protected $guarded = ['id'];

    public function purchases()
    {
        return $this->hasMany(PurchaseOrder::class, 'empresa_id');
    }
}
