<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'productos';

    protected $guarded = ['id'];

    public function material()
    {
        return $this->belongsTo(Material::class, 'material_id');
    }
}
