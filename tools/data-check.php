<?php

use App\Models\Client;
use App\Models\Company;
use App\Models\Material;
use App\Models\Order;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\User;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;

require dirname(__DIR__).'/vendor/autoload.php';
$app = require dirname(__DIR__).'/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();

$result = ['empresas' => Company::count(), 'clientes' => Client::count(), 'materiales' => Material::count(), 'productos' => Product::count(), 'compras' => PurchaseOrder::count(), 'pedidos' => Order::count(), 'modelos' => Order::where('tipo_pedido', 'modelo')->count(), 'sin_programar' => Order::whereNull('inicio_programacion')->count(), 'peso_por_fundir_kg' => Order::sum('peso_por_fundir_kg'), 'usuarios' => User::count()];
$pdo = DB::connection()->getPdo();
$result['legacy_database_exists'] = (bool) $pdo->query("SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='ssmf_db'")->fetchColumn();
if ($result['legacy_database_exists']) {
    $tables = $pdo->query("SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA='ssmf_db'")->fetchAll(PDO::FETCH_COLUMN);
    $result['legacy_tables'] = $tables;
    if (in_array('work_orders', $tables, true)) {
        $result['legacy_work_orders'] = $pdo->query('SELECT COUNT(*) FROM ssmf_db.work_orders')->fetchColumn();
    }
}
echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)."\n";
