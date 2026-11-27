<?php

use App\Database\VistasLaravel;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $mapa = json_decode(file_get_contents(database_path('mapa_espanol.json')), true, 512, JSON_THROW_ON_ERROR);
        foreach ($mapa['tablas'] as $anterior => $nuevo) {
            if (Schema::hasTable($anterior)) {
                if (Schema::hasTable($nuevo)) {
                    throw new RuntimeException("Ya existen $anterior y $nuevo; revisa la migración antes de continuar.");
                }
                Schema::rename($anterior, $nuevo);
            }
        }
        foreach ($mapa['tablas'] as $anterior => $tabla) {
            $campos = $mapa['campos_tecnicos'][$anterior] ?? $mapa['campos_negocio'];
            foreach ($campos as $viejo => $nuevo) {
                if ($viejo !== $nuevo && Schema::hasColumn($tabla, $viejo)) {
                    Schema::table($tabla, fn (Blueprint $t) => $t->renameColumn($viejo, $nuevo));
                }
            }
        }
        $columnas = [
            'usuarios' => ['perfil'], 'pedidos' => ['tipo_pedido'], 'hornos' => ['estado'],
            'ordenes_trabajo' => ['tipo', 'estado'], 'estados_proceso' => ['codigo'],
            'inspecciones_calidad' => ['dictamen'],
        ];
        foreach ($columnas as $tabla => $campos) {
            foreach ($campos as $campo) {
                foreach ($mapa['valores'] as $viejo => $nuevo) {
                    DB::table($tabla)->where($campo, $viejo)->update([$campo => $nuevo]);
                }
            }
        }
        // Los nuevos registros deben usar también los valores por defecto traducidos.
        Schema::table('usuarios', fn (Blueprint $t) => $t->string('perfil', 20)->default('consulta')->change());
        Schema::table('pedidos', fn (Blueprint $t) => $t->string('tipo_pedido', 20)->default('fundicion')->change());
        Schema::table('hornos', fn (Blueprint $t) => $t->string('estado', 30)->default('disponible')->change());
        Schema::table('ordenes_trabajo', fn (Blueprint $t) => $t->string('estado', 30)->default('en_proceso')->change());
        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            foreach ($mapa['tablas'] as $tabla) {
                foreach (Schema::getForeignKeys($tabla) as $foranea) {
                    $nombre = $this->nombreIndice($tabla, $foranea['columns'], 'foranea');
                    if ($foranea['name'] === $nombre) {
                        continue;
                    }
                    Schema::table($tabla, function (Blueprint $t) use ($foranea, $nombre) {
                        $t->dropForeign($foranea['name']);
                        $t->foreign($foranea['columns'], $nombre)->references($foranea['foreign_columns'])->on($foranea['foreign_table'])->onDelete($foranea['on_delete'])->onUpdate($foranea['on_update']);
                    });
                }
                foreach (Schema::getIndexes($tabla) as $indice) {
                    if ($indice['primary']) {
                        continue;
                    }
                    $nombre = $this->nombreIndice($tabla, $indice['columns'], $indice['unique'] ? 'unico' : 'indice');
                    if ($indice['name'] !== $nombre) {
                        // ADD/DROP en el mismo ALTER también funciona en el MariaDB antiguo de XAMPP.
                        $tipo = $indice['unique'] ? 'UNIQUE INDEX' : 'INDEX';
                        $columnas = implode(', ', array_map(fn ($c) => "`$c`", $indice['columns']));
                        DB::statement("ALTER TABLE `$tabla` ADD $tipo `$nombre` ($columnas), DROP INDEX `{$indice['name']}`");
                    }
                }
            }
        }
        foreach (['order.created' => 'pedido.creado', 'order.updated' => 'pedido.actualizado', 'user.saved' => 'usuario.guardado', 'catalog.saved' => 'catalogo.guardado', 'quality.recorded' => 'calidad.registrada', 'work_order.updated' => 'orden_trabajo.actualizada'] as $antes => $despues) {
            DB::table('bitacora_sistema')->where('accion', $antes)->update(['accion' => $despues]);
        }
        foreach ($mapa['tablas'] as $antes => $despues) {
            DB::table('bitacora_sistema')->where('entidad', $antes)->update(['entidad' => $despues]);
        }
        VistasLaravel::crear();
    }

    private function nombreIndice(string $tabla, array $columnas, string $tipo): string
    {
        $nombre = $tabla.'_'.implode('_', $columnas).'_'.$tipo;

        return strlen($nombre) > 64 ? substr($nombre, 0, 54).'_'.substr(sha1($nombre), 0, 9) : $nombre;
    }

    public function down(): void
    {
        throw new RuntimeException('Para regresar a la versión anterior utiliza el respaldo completo previo a la traducción.');
    }
};
