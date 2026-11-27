<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    public const CREATED_AT = 'creado_en';

    public const UPDATED_AT = 'actualizado_en';

    use HasFactory, Notifiable;

    protected $table = 'usuarios';

    protected $fillable = ['nombre', 'correo', 'contrasena', 'perfil', 'activo', 'empresa_id'];

    protected $hidden = ['contrasena', 'token_recordar'];

    protected function casts(): array
    {
        return ['contrasena' => 'hashed', 'activo' => 'boolean', 'correo_verificado_en' => 'datetime'];
    }

    public function company()
    {
        return $this->belongsTo(Company::class, 'empresa_id');
    }

    public function canManage(): bool
    {
        return $this->activo && in_array($this->perfil, ['administrador', 'supervisor'], true);
    }

    public function canOperate(): bool
    {
        return $this->activo && in_array($this->perfil, ['administrador', 'supervisor', 'operador'], true);
    }

    public function canInspect(): bool
    {
        return $this->activo && in_array($this->perfil, ['administrador', 'supervisor', 'calidad'], true);
    }

    protected $rememberTokenName = 'token_recordar';

    public function getAuthPasswordName(): string
    {
        return 'contrasena';
    }

    public function getEmailForPasswordReset(): string
    {
        return $this->correo;
    }

    public function getEmailForVerification(): string
    {
        return $this->correo;
    }

    public function routeNotificationForMail($notification = null): string
    {
        return $this->correo;
    }
}
