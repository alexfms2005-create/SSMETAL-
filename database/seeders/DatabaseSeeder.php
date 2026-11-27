<?php

namespace Database\Seeders;

use App\Models\CastingLevel;
use App\Models\Company;
use App\Models\Furnace;
use App\Models\Material;
use App\Models\ProcessStatus;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        Company::firstOrCreate(['codigo' => 'SSMF'], ['nombre' => 'SS Metal Foundry']);
        Company::firstOrCreate(['codigo' => 'SFS'], ['nombre' => 'Steel Fused Solutions']);
        for ($n = 1; $n <= 5; $n++) {
            CastingLevel::firstOrCreate(['nivel' => $n], ['nombre' => 'Nivel '.$n]);
        }
        $statuses = ['pendiente' => 'Por fundir / pendiente', 'modelo_pendiente' => 'Modelo faltante', 'moldeo' => 'Modelado / moldeo', 'programado' => 'Programado', 'fusion' => 'Fundición en proceso', 'tratamiento_termico' => 'Tratamiento térmico', 'maquinado' => 'Maquinado', 'acabados' => 'Acabados', 'calidad' => 'Inspección de calidad', 'terminado' => 'Terminado'];
        foreach (array_keys($statuses) as $n => $codigo) {
            ProcessStatus::firstOrCreate(['codigo' => $codigo], ['nombre' => $statuses[$codigo], 'posicion' => $n]);
        }
        foreach (['Acero al Carbón', 'Chatarra de Retorno', 'Ferroaleaciones', 'Aleación Especial', 'Hierro Gris', 'Hierro Nodular', 'Acero Inoxidable 316'] as $nombre) {
            Material::firstOrCreate(['nombre' => $nombre]);
        }
        foreach (['A' => 1500, 'B' => 1800, 'C' => 2000] as $letter => $kg) {
            Furnace::firstOrCreate(['nombre' => 'HORNO '.$letter], ['capacidad_kg' => $kg, 'estado' => $letter === 'C' ? 'mantenimiento' : 'disponible', 'observaciones' => 'Temperatura pendiente de captura manual. Sin conexión a sensores.']);
        }
    }
}
