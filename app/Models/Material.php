<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'materiales';

    protected $guarded = ['id'];

    public function products()
    {
        return $this->hasMany(Product::class, 'material_id');
    }
}
