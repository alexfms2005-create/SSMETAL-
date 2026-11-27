<?php

namespace App\Database;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/** Vistas simples y actualizables: Laravel usa sus alias; los datos se guardan en español. */
class VistasLaravel
{
    public static function definiciones(): array
    {
        $mapa = json_decode(file_get_contents(database_path('mapa_espanol.json')), true, 512, JSON_THROW_ON_ERROR);
        $vistas = [];
        foreach ($mapa['campos_tecnicos'] as $original => $campos) {
            if ($original === 'migrations') {
                continue;
            }
            $tabla = $mapa['tablas'][$original];
            $vistas['adaptador_'.$tabla] = ['tabla' => $tabla, 'campos' => $campos];
        }

        return $vistas;
    }

    public static function sentencia(string $vista, array $definicion): string
    {
        $seleccion = [];
        $inverso = array_flip($definicion['campos']);
        foreach (Schema::getColumnListing($definicion['tabla']) as $columna) {
            $alias = $inverso[$columna] ?? $columna;
            $seleccion[] = "`$columna` AS `$alias`";
        }
        $opciones = in_array(DB::getDriverName(), ['mysql', 'mariadb'], true) ? 'ALGORITHM=MERGE SQL SECURITY INVOKER ' : '';

        return "CREATE {$opciones}VIEW `$vista` AS SELECT ".implode(', ', $seleccion)." FROM `{$definicion['tabla']}`";
    }

    public static function crear(): void
    {
        foreach (self::definiciones() as $vista => $definicion) {
            DB::statement("DROP VIEW IF EXISTS `$vista`");
            DB::statement(self::sentencia($vista, $definicion));
            // La aplicación usa MySQL. En SQLite los tests de negocio no escriben por estas vistas.
        }
    }
}
