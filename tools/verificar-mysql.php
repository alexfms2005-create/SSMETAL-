<?php

use App\Database\VistasLaravel;
use App\Models\Furnace;
use App\Models\Order;
use App\Models\User;
use App\Services\WorkOrderFlow;
use Illuminate\Bus\BatchRepository;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Session\DatabaseSessionHandler;
use Illuminate\Support\Facades\Bus;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

require dirname(__DIR__).'/vendor/autoload.php';
$app = require dirname(__DIR__).'/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();

if (! in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
    throw new RuntimeException('Esta comprobación requiere MySQL/MariaDB.');
}
$comprobar = function (bool $correcto, string $mensaje): void {
    if (! $correcto) {
        throw new RuntimeException($mensaje);
    }
    echo "OK: $mensaje\n";
};
$mapa = json_decode(file_get_contents(database_path('mapa_espanol.json')), true, 512, JSON_THROW_ON_ERROR);
foreach ($mapa['tablas'] as $anterior => $tabla) {
    $comprobar(Schema::hasTable($tabla), "Tabla $tabla");
    $columnas = Schema::getColumnListing($tabla);
    foreach (($mapa['campos_tecnicos'][$anterior] ?? $mapa['campos_negocio']) as $antes => $despues) {
        if ($antes !== $despues && in_array($antes, $columnas, true)) {
            throw new RuntimeException("Columna pendiente de traducir: $tabla.$antes");
        }
    }
}
$comprobar(count(VistasLaravel::definiciones()) === 7, 'Siete vistas de compatibilidad');
$comprobar(count($app['migration.repository']->getRan()) >= 6, 'Historial de migraciones en español');

$conexion = DB::connection();
$conexion->beginTransaction();
try {
    $clave = 'prueba_esquema_'.Str::random(16);
    $sesiones = new DatabaseSessionHandler($conexion, config('session.table'), 120, $app);
    $sesiones->write($clave, 'sesion de prueba');
    $comprobar($sesiones->read($clave) === 'sesion de prueba', 'Escritura y lectura de sesiones');
    $sesiones->destroy($clave);

    $cache = Cache::store('database');
    $cache->put($clave, ['dato' => 1], 60);
    $comprobar($cache->get($clave) === ['dato' => 1], 'Caché en base de datos');
    $cache->put($clave, 4, 60);
    $comprobar($cache->increment($clave, 2) === 6, 'Incremento atómico de caché');
    $bloqueo = $cache->lock($clave.'_bloqueo', 10);
    $comprobar($bloqueo->get(), 'Adquisición de bloqueo de caché');
    $comprobar($bloqueo->release(), 'Liberación de bloqueo de caché');
    $cache->forget($clave);

    $cola = Queue::connection('database');
    $id = $cola->pushRaw(json_encode(['uuid' => (string) Str::uuid(), 'displayName' => 'Comprobacion', 'job' => 'Prueba@handle', 'data' => []]), $clave);
    $trabajo = $cola->pop($clave);
    $comprobar($trabajo !== null && (int) $trabajo->getJobId() === (int) $id, 'Inserción, ID y reserva en cola');
    $trabajo->delete();

    $repositorio = $app->make(BatchRepository::class);
    $lote = $repositorio->store(Bus::batch([])->name('Comprobación de esquema'));
    $repositorio->incrementTotalJobs($lote->id, 2);
    $comprobar($repositorio->find($lote->id)->totalJobs === 2, 'Registro y actualización de lotes');
    $repositorio->delete($lote->id);

    $fallidos = $app['queue.failer'];
    $uuid = $fallidos->log('database', $clave, json_encode(['uuid' => (string) Str::uuid()]), new RuntimeException('Comprobación local'));
    $comprobar($fallidos->find($uuid) !== null, 'Registro de trabajos fallidos');
    $fallidos->forget($uuid);

    $usuario = User::where('perfil', 'administrador')->firstOrFail();
    $token = Password::broker()->createToken($usuario);
    $comprobar(Password::broker()->tokenExists($usuario, $token), 'Tokens de recuperación de contraseña');
    Password::broker()->deleteToken($usuario);

    $pedido = Order::where('tipo_pedido', 'fundicion')->where('modelo_recibido', true)->where('peso_por_fundir_kg', '>', 0)->whereDoesntHave('workOrders', fn ($q) => $q->where('estado', 'en_proceso'))->firstOrFail();
    $horno = Furnace::where('estado', 'disponible')->firstOrFail();
    $antes = (float) $pedido->peso_por_fundir_kg;
    $peso = min(10, $antes, (float) $horno->capacidad_kg);
    $flujo = new WorkOrderFlow;
    $ot = $flujo->create(['pedido_id' => $pedido->id, 'tipo' => 'interna', 'horno_id' => $horno->id, 'peso_kg' => $peso, 'minutos_estimados' => 180], $usuario);
    $flujo->advance($ot->id, 100, $usuario);
    $comprobar($ot->fresh()->estado === 'terminado' && $horno->fresh()->estado === 'disponible' && abs((float) $pedido->fresh()->peso_por_fundir_kg - ($antes - $peso)) < 0.001, 'Ciclo de OT, peso pendiente y horno');
} finally {
    $conexion->rollBack();
}
echo "Comprobación terminada; los movimientos de prueba se revirtieron.\n";
