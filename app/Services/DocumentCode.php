<?php

namespace App\Services;

use App\Models\Company;
use Illuminate\Support\Facades\DB;

class DocumentCode
{
    // Caller must hold a transaction. A company lock serializes first-use and increments.
    public static function next(int $companyId, string $serie): string
    {
        $company = Company::whereKey($companyId)->lockForUpdate()->firstOrFail();
        $key = ['empresa_id' => $companyId, 'serie' => $serie, 'anio' => now()->year];
        DB::table('consecutivos_documentos')->insertOrIgnore($key + ['ultimo_numero' => 0]);
        $sequence = DB::table('consecutivos_documentos')->where($key)->lockForUpdate()->first();
        $number = $sequence->ultimo_numero + 1;
        DB::table('consecutivos_documentos')->where('id', $sequence->id)->update(['ultimo_numero' => $number]);

        return sprintf('%s-%s-%d-%05d', $company->codigo, $serie, now()->year, $number);
    }
}
