<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PurchaseOrder extends Model
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    protected $table = 'ordenes_compra';

    protected $guarded = ['id'];

    public function company()
    {
        return $this->belongsTo(Company::class, 'empresa_id');
    }

    public function client()
    {
        return $this->belongsTo(Client::class, 'cliente_id');
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'orden_compra_id');
    }

    protected function casts(): array
    {
        return ['fecha_compra' => 'date', 'fecha_compromiso' => 'date'];
    }
}
