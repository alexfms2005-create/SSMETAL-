<?php

namespace App\Console\Commands;

use App\Models\Client;
use App\Models\Company;
use App\Models\Material;
use App\Models\Order;
use App\Models\ProcessStatus;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Services\DocumentCode;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class ImportBacklog extends Command
{
    protected $signature = 'foundry:import-backlog {--company=SSMF} {--reconcile}';

    protected $descripcion = 'Importa las 70 partidas originales sin asignar semana y sin duplicarlas.';

    public function handle(): int
    {
        $company = Company::where('codigo', $this->option('company'))->firstOrFail();
        $rows = json_decode(file_get_contents(database_path('data/backlog.json')), true, 512, JSON_THROW_ON_ERROR);
        $count = 0;
        DB::transaction(function () use ($rows, $company, &$count) {
            foreach ($rows as $week) {
                foreach ($week['items'] as $item) {
                    $existing = Order::where('clave_origen', $item['id'])->first();
                    if ($existing && (! $this->option('reconcile') || $existing->workOrders()->exists())) {
                        continue;
                    }
                    $client = Client::firstOrCreate(['nombre' => $item['cliente']]);
                    $material = Material::firstOrCreate(['nombre' => $item['material'] ?: 'Sin especificar']);
                    $codigo = trim($item['codInterno'] ?? '');
                    if (! $codigo || in_array($codigo, ['NA', '-', 'X'])) {
                        $codigo = 'LEGACY-'.$item['id'];
                    }
                    $product = Product::firstOrCreate(['codigo_interno' => $codigo, 'nombre' => $item['descripcion'], 'material_id' => $material->id], ['peso_unitario_kg' => $item['pesoUnit'], 'requiere_maquinado' => $item['maq'] === 'MAQ']);
                    $internal = trim($item['ocInterna'] ?? '');
                    if (in_array($internal, ['', 'NA', '-'])) {
                        $internal = null;
                    }
                    $external = trim($item['ocExterna'] ?? '');
                    if (in_array($external, ['', 'NA', '-'])) {
                        $external = null;
                    }
                    $key = ['empresa_id' => $company->id, 'numero_interno' => $internal];
                    if (! $internal) {
                        $key += ['cliente_id' => $client->id, 'numero_externo' => $external, 'fecha_compra' => $this->date($item['fOc'])];
                    }
                    $purchase = PurchaseOrder::firstOrCreate($key, ['cliente_id' => $client->id, 'numero_externo' => $external, 'fecha_compra' => $this->date($item['fOc']), 'fecha_compromiso' => $this->date($item['fEntrega'])]);
                    $legacy = mb_strtoupper($item['estatus'] ?? '');
                    $estado = match (true) {
                        str_contains($legacy, 'MODELO FALTANTE') => 'modelo_pendiente',str_contains($legacy, 'ACABAD') => 'acabados',str_contains($legacy, 'MAQUIN') => 'maquinado',str_contains($legacy, 'MOLDEO') => 'moldeo',str_contains($legacy, 'PROG') => 'programado',default => 'pendiente'
                    };
                    $tipo_pedido = $item['material'] === 'MADERA' || str_starts_with(mb_strtoupper($item['descripcion']), 'MODELO ') ? 'modelo' : 'fundicion';
                    if ($existing) {
                        $changes = ['producto_id' => $product->id, 'tipo_pedido' => $tipo_pedido, 'cantidad_pendiente' => $tipo_pedido === 'modelo' ? (int) $item['cant'] : ($item['pesoUnit'] > 0 ? min((int) $item['cant'], (int) ceil($item['porFundir'] / $item['pesoUnit'])) : 0)];
                        if ($existing->tipo_pedido !== $tipo_pedido) {
                            $changes['codigo'] = DocumentCode::next($company->id, $tipo_pedido === 'modelo' ? 'PM' : 'PF');
                        } $existing->update($changes);
                        $count++;

                        continue;
                    }
                    Order::create(['codigo' => DocumentCode::next($company->id, $tipo_pedido === 'modelo' ? 'PM' : 'PF'), 'clave_origen' => $item['id'], 'orden_compra_id' => $purchase->id, 'producto_id' => $product->id, 'material_id' => $material->id, 'estado_proceso_id' => ProcessStatus::where('codigo', $estado)->value('id'), 'tipo_pedido' => $tipo_pedido, 'cantidad_pendiente' => $tipo_pedido === 'modelo' ? (int) $item['cant'] : ($item['pesoUnit'] > 0 ? min((int) $item['cant'], (int) ceil($item['porFundir'] / $item['pesoUnit'])) : 0), 'cantidad' => max(1, (int) $item['cant']), 'peso_unitario_kg' => $item['pesoUnit'], 'peso_por_fundir_kg' => $item['porFundir'], 'requiere_maquinado' => $item['maq'] === 'MAQ', 'modelo_recibido' => $item['modelo'] !== 'X', 'observaciones' => 'Importado del archivo original. Grupo de origen: '.$week['title'].'. Estado original: '.$legacy.'. La programación queda pendiente de asignación manual.']);
                    $count++;
                }
            }
        });
        $this->info("Partidas importadas: $count. No se asignaron semanas ni niveles de fundición.");

        return self::SUCCESS;
    }

    private function date(?string $value): ?string
    {
        try {
            return Carbon::createFromFormat('!d/m/Y', trim($value ?? ''))->format('Y-m-d');
        } catch (\Throwable) {
            return null;
        }
    }
}
