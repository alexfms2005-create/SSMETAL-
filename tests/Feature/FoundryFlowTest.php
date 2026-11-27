<?php

namespace Tests\Feature;

use App\Models\Client;
use App\Models\Company;
use App\Models\Furnace;
use App\Models\Material;
use App\Models\Order;
use App\Models\ProcessStatus;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\User;
use App\Models\WorkOrder;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FoundryFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private function user(string $perfil = 'administrador'): User
    {
        return User::create(['nombre' => 'Prueba', 'correo' => uniqid().'@example.test', 'contrasena' => 'A-test-password-123', 'perfil' => $perfil, 'activo' => true]);
    }

    private function order(string $company = 'SSMF', string $tipo_pedido = 'fundicion'): Order
    {
        $material = Material::first();
        $client = Client::create(['nombre' => uniqid('Cliente ')]);
        $product = Product::create(['codigo_interno' => uniqid('COD'), 'nombre' => 'Pieza de prueba', 'material_id' => $material->id, 'peso_unitario_kg' => 100]);
        $purchase = PurchaseOrder::create(['empresa_id' => Company::where('codigo', $company)->value('id'), 'cliente_id' => $client->id, 'numero_interno' => uniqid('OCI'), 'numero_externo' => 'EXT-25', 'fecha_compra' => today(), 'fecha_compromiso' => today()->addDays(2)]);

        return Order::create(['codigo' => uniqid('PED'), 'orden_compra_id' => $purchase->id, 'producto_id' => $product->id, 'material_id' => $material->id, 'estado_proceso_id' => ProcessStatus::where('codigo', 'pendiente')->value('id'), 'tipo_pedido' => $tipo_pedido, 'cantidad' => 20, 'cantidad_pendiente' => 20, 'peso_unitario_kg' => 100, 'peso_por_fundir_kg' => 2000, 'modelo_recibido' => true]);
    }

    private function payload(Order $order, array $overrides = []): array
    {
        return array_replace(['pedido_id' => $order->id, 'tipo' => 'interna', 'horno_id' => Furnace::where('nombre', 'HORNO A')->value('id'), 'peso_kg' => 1000, 'minutos_estimados' => 180], $overrides);
    }

    public function test_guests_are_redirected_and_login_works(): void
    {
        $this->get('/backlog')->assertRedirect('/login');
        $u = $this->user();
        $this->post('/login', ['correo' => $u->correo, 'contrasena' => 'A-test-password-123'])->assertRedirect('/backlog');
        $this->assertAuthenticatedAs($u);
    }

    public function test_all_pages_render_with_database_data(): void
    {
        $u = $this->user();
        $order = $this->order();
        $this->actingAs($u);
        foreach (['/backlog', '/pedidos/nuevo', '/pedidos/'.$order->id.'/editar', '/ots/nueva', '/proceso', '/terminadas', '/reportes', '/reportes/imprimir', '/usuarios', '/catalogos/clientes', '/catalogos/materiales', '/catalogos/productos', '/catalogos/purchases', '/catalogos/levels'] as $url) {
            $this->get($url)->assertOk();
        }
        $this->get('/backlog')->assertSee('Steel Fused Solutions and SS Metal Foundry')->assertSee('Sin asignar');
    }

    public function test_partial_casting_completes_atomically_and_preserves_pending_weight(): void
    {
        $this->actingAs($this->user());
        $order = $this->order();
        $payload = $this->payload($order);
        $this->post('/ots', $payload)->assertSessionHasNoErrors()->assertRedirect('/proceso');
        $ot = WorkOrder::sole();
        $this->assertStringStartsWith('SSMF-OTI-', $ot->codigo);
        $this->assertSame('en_proceso', $ot->furnace->estado);
        $this->put('/ots/'.$ot->id.'/avance', ['avance' => 100])->assertSessionHasNoErrors();
        $this->assertSame('terminado', $ot->fresh()->estado);
        $this->assertSame('disponible', $ot->furnace->fresh()->estado);
        $this->assertEquals(1000, $order->fresh()->peso_por_fundir_kg);
        $this->assertCount(2, $ot->events);
        $this->assertTrue($ot->fresh()->terminado_a_tiempo);
        $this->get('/reportes')->assertOk()->assertSee($ot->codigo);
        $this->get('/reportes/imprimir')->assertOk()->assertSee($ot->codigo);
        $this->get('/reportes/csv')->assertOk()->assertDownload();
        $this->post('/ots', $payload)->assertSessionHasNoErrors();
        $this->assertSame(2, WorkOrder::count());
        $this->assertCount(2, WorkOrder::pluck('codigo')->unique());
    }

    public function test_capacity_and_duplicate_active_orders_are_rejected_without_partial_writes(): void
    {
        $this->actingAs($this->user());
        $order = $this->order();
        $this->post('/ots', $this->payload($order, ['peso_kg' => 1600]))->assertSessionHasErrors();
        $this->assertDatabaseCount('ordenes_trabajo', 0);
        $this->assertSame('disponible', Furnace::where('nombre', 'HORNO A')->first()->estado);
        $this->post('/ots', $this->payload($order))->assertSessionHasNoErrors();
        $this->post('/ots', $this->payload($order))->assertSessionHasErrors();
        $this->assertDatabaseCount('ordenes_trabajo', 1);
    }

    public function test_maintenance_and_missing_models_cannot_be_assigned(): void
    {
        $this->actingAs($this->user());
        $order = $this->order();
        $this->post('/ots', $this->payload($order, ['horno_id' => Furnace::where('nombre', 'HORNO C')->value('id')]))->assertSessionHasErrors();
        $order->update(['modelo_recibido' => false]);
        $this->post('/ots', $this->payload($order))->assertSessionHasErrors();
        $this->assertDatabaseCount('ordenes_trabajo', 0);
    }

    public function test_external_model_order_gets_its_company_series_without_using_a_furnace(): void
    {
        $this->actingAs($this->user());
        $order = $this->order('SFS', 'modelo');
        $order->update(['peso_unitario_kg' => 0, 'peso_por_fundir_kg' => 0]);
        $this->post('/ots', $this->payload($order, ['tipo' => 'externa', 'horno_id' => null, 'peso_kg' => null, 'cantidad' => 2]))->assertSessionHasNoErrors();
        $ot = WorkOrder::sole();
        $this->assertStringStartsWith('SFS-OTE-', $ot->codigo);
        $this->assertNull($ot->horno_id);
        $this->assertEquals(0, $ot->peso_kg);
        $this->put('/ots/'.$ot->id.'/avance', ['avance' => 100])->assertSessionHasNoErrors();
        $this->assertEquals(18, $order->fresh()->cantidad_pendiente);
    }

    public function test_new_orders_remain_unassigned_and_manual_schedule_filters_by_date_range(): void
    {
        $this->actingAs($this->user());
        $source = $this->order();
        $d = $source->only(['orden_compra_id', 'producto_id', 'material_id', 'estado_proceso_id', 'tipo_pedido', 'cantidad', 'peso_unitario_kg']) + ['modelo_recibido' => 1];
        $this->post('/pedidos', $d)->assertSessionHasNoErrors();
        $order = Order::latest('id')->first();
        $this->assertNull($order->inicio_programacion);
        $this->assertStringStartsWith('SSMF-PF-', $order->codigo);
        $this->put('/pedidos/'.$order->id, $d + ['anio_programacion' => 2026, 'semana_programacion' => 48])->assertSessionHasNoErrors();
        $this->assertSame('2026-11-23', $order->fresh()->inicio_programacion->toDateString());
        $this->get('/backlog?from=2026-11-23&to=2026-11-29')->assertOk()->assertSee($order->codigo)->assertDontSee($source->codigo);
        $this->get('/backlog?assignment=unassigned')->assertSee($source->codigo)->assertDontSee($order->codigo);
    }

    public function test_roles_and_inactive_sessions_are_enforced(): void
    {
        $viewer = $this->user('consulta');
        $this->actingAs($viewer);
        $this->get('/usuarios')->assertForbidden();
        $this->post('/ots', [])->assertForbidden();
        $this->post('/pedidos', [])->assertForbidden();
        $viewer->update(['activo' => false]);
        $this->get('/backlog')->assertRedirect('/login');
    }

    public function test_reclassifying_a_purchase_updates_company_prefixes_before_work_starts(): void
    {
        $this->actingAs($this->user());
        $order = $this->order();
        $purchase = $order->purchaseOrder;
        $data = $purchase->only(['cliente_id', 'numero_interno', 'numero_externo']) + ['empresa_id' => Company::where('codigo', 'SFS')->value('id')];
        $this->post('/catalogos/purchases/'.$purchase->id, $data)->assertSessionHasNoErrors();
        $this->assertStringStartsWith('SFS-PF-', $order->fresh()->codigo);
        $this->post('/ots', $this->payload($order))->assertSessionHasNoErrors();
        $this->assertStringStartsWith('SFS-OTI-', WorkOrder::sole()->codigo);
        $data['empresa_id'] = Company::where('codigo', 'SSMF')->value('id');
        $this->post('/catalogos/purchases/'.$purchase->id, $data)->assertSessionHasErrors();
        $this->assertSame('SFS', $purchase->fresh()->company->codigo);
    }

    public function test_changing_order_kind_regenerates_the_series_before_any_ot_exists(): void
    {
        $this->actingAs($this->user());
        $order = $this->order();
        $data = $order->only(['orden_compra_id', 'producto_id', 'material_id', 'estado_proceso_id', 'cantidad', 'peso_unitario_kg']) + ['tipo_pedido' => 'modelo', 'modelo_recibido' => 1];
        $this->put('/pedidos/'.$order->id, $data)->assertSessionHasNoErrors();
        $this->assertStringStartsWith('SSMF-PM-', $order->fresh()->codigo);
    }

    public function test_quality_reports_use_actual_inspections_and_operator_cannot_approve(): void
    {
        $admin = $this->user();
        $this->actingAs($admin);
        $order = $this->order();
        $this->post('/ots', $this->payload($order));
        $ot = WorkOrder::sole();
        $this->put('/ots/'.$ot->id.'/avance', ['avance' => 100]);
        $data = ['carbono' => 0.24, 'silicio' => 0.38, 'dictamen' => 'aprobado'];
        $this->actingAs($this->user('operador'))->post('/ots/'.$ot->id.'/calidad', $data)->assertForbidden();
        $this->actingAs($admin)->post('/ots/'.$ot->id.'/calidad', $data)->assertSessionHasNoErrors();
        $this->assertDatabaseHas('inspecciones_calidad', ['orden_trabajo_id' => $ot->id, 'usuario_id' => $admin->id, 'dictamen' => 'aprobado']);
        $this->get('/reportes')->assertSee('Aprobado')->assertSee('0.24');
    }

    public function test_import_is_idempotent_and_keeps_all_seventy_rows_unassigned(): void
    {
        $this->artisan('foundry:import-backlog')->assertSuccessful();
        $this->artisan('foundry:import-backlog')->assertSuccessful();
        $this->assertDatabaseCount('pedidos', 70);
        $this->assertSame(0, Order::whereNotNull('inicio_programacion')->count());
        $this->assertSame(0, Order::whereNotNull('nivel_fundicion_id')->count());
        $this->assertSame(1, Order::where('tipo_pedido', 'modelo')->count());
        $a = Order::where('clave_origen', 'B47-17')->first();
        $b = Order::where('clave_origen', 'B47-18')->first();
        $this->assertNotSame($a->producto_id, $b->producto_id);
    }
}
