<?php

use App\Models\User;
use Illuminate\Contracts\Console\Kernel;

require dirname(__DIR__).'/vendor/autoload.php';
$app = require dirname(__DIR__).'/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();
if (User::where('perfil', 'administrador')->exists()) {
    echo "Administrador existente conservado.\n";
    exit;
}
$contrasena = bin2hex(random_bytes(12));
$correo = 'admin@ssmetal.local';
User::create(['nombre' => 'Administrador', 'correo' => $correo, 'contrasena' => $contrasena, 'perfil' => 'administrador', 'activo' => true]);
$path = storage_path('app/acceso-local.txt');
file_put_contents($path, "Acceso local inicial\nURL: ".config('app.url')."\nCorreo: $correo\nContraseña: $contrasena\nCambia la contraseña desde Usuarios después de entrar.\n");
echo "Administrador creado. Credenciales en storage/app/acceso-local.txt (excluido de Git).\n";
