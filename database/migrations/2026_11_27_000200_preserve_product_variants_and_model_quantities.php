<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $t) {
            $t->dropUnique(['internal_code']);
            $t->index('internal_code');
            $t->unique(['internal_code', 'name', 'material_id'], 'products_variant_unique');
        });
        Schema::table('orders', function (Blueprint $t) {
            $t->unsignedInteger('remaining_quantity')->default(0);
        });
        Schema::table('work_orders', function (Blueprint $t) {
            $t->unsignedInteger('quantity')->nullable();
        });
        DB::table('orders')->orderBy('id')->chunkById(200, function ($orders) {
            foreach ($orders as $o) {
                DB::table('orders')->where('id', $o->id)->update(['remaining_quantity' => $o->kind === 'model' ? $o->quantity : ((float) $o->unit_weight_kg > 0 ? min($o->quantity, (int) ceil($o->remaining_weight_kg / $o->unit_weight_kg)) : 0)]);
            }
        });
    }

    public function down(): void
    {
        // Product variants may now share a code; restoring the former unique key would lose information.
        throw new RuntimeException('Migración no reversible automáticamente. Conserva las variantes de producto.');
    }
};
