<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Validator;

class CreateAdmin extends Command
{
    protected $signature = 'foundry:admin {correo?} {--nombre=Administrador}';

    protected $descripcion = 'Crea el primer administrador; solicita la contraseña sin mostrarla.';

    public function handle(): int
    {
        $correo = $this->argument('correo') ?: $this->ask('Correo del administrador');
        if (User::where('correo', $correo)->exists()) {
            $this->error('El usuario ya existe. No se modificó.');

            return self::FAILURE;
        }
        $contrasena = $this->secret('Contraseña (mínimo 12 caracteres)');
        $validator = Validator::make(compact('correo', 'contrasena'), ['correo' => 'required|email', 'contrasena' => 'required|string|min:12']);
        if ($validator->fails()) {
            $this->error($validator->errors()->first());

            return self::FAILURE;
        }
        User::create(['nombre' => $this->option('nombre'), 'correo' => $correo, 'contrasena' => $contrasena, 'perfil' => 'administrador', 'activo' => true]);
        $this->info('Administrador creado.');

        return self::SUCCESS;
    }
}
