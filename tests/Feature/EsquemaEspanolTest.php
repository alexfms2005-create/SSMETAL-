<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class EsquemaEspanolTest extends TestCase
{
    use RefreshDatabase;

    public function test_las_tablas_y_columnas_fisicas_estan_en_espanol(): void
    {
        $mapa = json_decode(file_get_contents(database_path('mapa_espanol.json')), true, 512, JSON_THROW_ON_ERROR);
        foreach ($mapa['tablas'] as $original => $tabla) {
            $this->assertTrue(Schema::hasTable($tabla), $tabla);
            $columnas = Schema::getColumnListing($tabla);
            foreach (($mapa['campos_tecnicos'][$original] ?? $mapa['campos_negocio']) as $antes => $despues) {
                if ($antes !== $despues) {
                    $this->assertNotContains($antes, $columnas, "$tabla.$antes");
                }
            }
        }
        $this->assertGreaterThanOrEqual(6, count($this->app['migration.repository']->getRan()));
    }

    public function test_factory_y_autenticacion_utilizan_las_columnas_traducidas(): void
    {
        $usuario = User::factory()->create(['contrasena' => 'Contrasena-prueba-2026', 'activo' => true]);
        $this->assertTrue(Hash::check('Contrasena-prueba-2026', $usuario->contrasena));
        $this->post('/login', ['correo' => $usuario->correo, 'contrasena' => 'Contrasena-prueba-2026'])->assertRedirect('/backlog');
        $this->assertAuthenticatedAs($usuario);
    }
}
