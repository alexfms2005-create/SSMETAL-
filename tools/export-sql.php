<?php

use App\Database\VistasLaravel;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;

require dirname(__DIR__).'/vendor/autoload.php';
$app = require dirname(__DIR__).'/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();
$pdo = DB::connection()->getPdo();
$tables = array_column($pdo->query("SHOW FULL TABLES WHERE Table_type='BASE TABLE'")->fetchAll(PDO::FETCH_NUM), 0);
$dataTables = ['migraciones', 'empresas', 'clientes', 'materiales', 'niveles_fundicion', 'estados_proceso', 'productos', 'ordenes_compra', 'pedidos', 'hornos', 'consecutivos_documentos'];
$sql = "-- Steel Fused Solutions and SS Metal Foundry\n-- Esquema y datos iniciales. No contiene usuarios ni contraseñas.\n-- Importar en una base nueva; para actualizar una instalación usa php artisan migrate.\nSET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS=0;\n";
foreach ($tables as $table) {
    $ddl = $pdo->query("SHOW CREATE TABLE `$table`")->fetch(PDO::FETCH_NUM)[1];
    $sql .= str_replace('CREATE TABLE `', 'CREATE TABLE IF NOT EXISTS `', $ddl).";\n\n";
}
foreach ($dataTables as $table) {
    foreach ($pdo->query("SELECT * FROM `$table`")->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $columns = implode(',', array_map(fn ($c) => "`$c`", array_keys($row)));
        $values = implode(',', array_map(fn ($v) => $v === null ? 'NULL' : $pdo->quote((string) $v), array_values($row)));
        $sql .= "INSERT IGNORE INTO `$table` ($columns) VALUES ($values);\n";
    }
    $sql .= "\n";
}
foreach (VistasLaravel::definiciones() as $vista => $definicion) {
    $sql .= VistasLaravel::sentencia($vista, $definicion).";\n";
}
$sql .= "SET FOREIGN_KEY_CHECKS=1;\n";
$folder = database_path('sql');
if (! is_dir($folder)) {
    mkdir($folder, 0777, true);
}
file_put_contents($folder.'/ssmf_laravel.sql', $sql);
echo "SQL exportado sin usuarios ni contraseñas.\n";
