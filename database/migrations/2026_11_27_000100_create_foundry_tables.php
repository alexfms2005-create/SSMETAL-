<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('companies', function (Blueprint $t) {
            $t->id();
            $t->string('code', 10)->unique();
            $t->string('name');
            $t->timestamps();
        });
        Schema::table('users', function (Blueprint $t) {
            $t->foreignId('company_id')->nullable()->constrained()->restrictOnDelete();
            $t->string('role', 20)->default('viewer');
            $t->boolean('active')->default(true);
        });
        Schema::create('clients', function (Blueprint $t) {
            $t->id();
            $t->string('name')->unique();
            $t->string('tax_id')->nullable();
            $t->string('email')->nullable();
            $t->timestamps();
        });
        Schema::create('materials', function (Blueprint $t) {
            $t->id();
            $t->string('name')->unique();
            $t->text('description')->nullable();
            $t->timestamps();
        });
        Schema::create('casting_levels', function (Blueprint $t) {
            $t->id();
            $t->unsignedTinyInteger('level')->unique();
            $t->string('name');
            $t->timestamps();
        });
        Schema::create('process_statuses', function (Blueprint $t) {
            $t->id();
            $t->string('code')->unique();
            $t->string('name');
            $t->unsignedSmallInteger('position')->default(0);
            $t->timestamps();
        });
        Schema::create('products', function (Blueprint $t) {
            $t->id();
            $t->string('internal_code')->unique();
            $t->string('name', 500);
            $t->foreignId('material_id')->constrained()->restrictOnDelete();
            $t->decimal('unit_weight_kg', 12, 3)->default(0);
            $t->boolean('requires_machining')->default(false);
            $t->timestamps();
        });
        Schema::create('purchase_orders', function (Blueprint $t) {
            $t->id();
            $t->foreignId('company_id')->constrained()->restrictOnDelete();
            $t->foreignId('client_id')->constrained()->restrictOnDelete();
            $t->string('internal_number')->nullable();
            $t->string('external_number')->nullable();
            $t->date('ordered_at')->nullable();
            $t->date('commitment_at')->nullable();
            $t->timestamps();
            $t->unique(['company_id', 'internal_number']);
            $t->index(['company_id', 'external_number']);
        });
        Schema::create('orders', function (Blueprint $t) {
            $t->id();
            $t->string('code')->unique();
            $t->string('source_key')->nullable()->unique();
            $t->foreignId('purchase_order_id')->constrained()->restrictOnDelete();
            $t->foreignId('product_id')->constrained()->restrictOnDelete();
            $t->foreignId('material_id')->constrained()->restrictOnDelete();
            $t->foreignId('casting_level_id')->nullable()->constrained()->restrictOnDelete();
            $t->foreignId('process_status_id')->constrained()->restrictOnDelete();
            $t->string('kind', 20)->default('foundry');
            $t->unsignedInteger('quantity');
            $t->decimal('unit_weight_kg', 12, 3);
            $t->decimal('remaining_weight_kg', 14, 3);
            $t->boolean('requires_machining')->default(false);
            $t->boolean('model_available')->default(true);
            $t->unsignedSmallInteger('scheduled_year')->nullable();
            $t->unsignedTinyInteger('scheduled_week')->nullable();
            $t->date('scheduled_start')->nullable();
            $t->date('scheduled_end')->nullable();
            $t->text('notes')->nullable();
            $t->timestamps();
            $t->index(['kind', 'scheduled_start']);
            $t->index(['process_status_id', 'scheduled_end']);
        });
        Schema::create('furnaces', function (Blueprint $t) {
            $t->id();
            $t->string('name')->unique();
            $t->decimal('capacity_kg', 12, 3);
            $t->string('status', 30)->default('available');
            $t->unsignedInteger('current_temp')->nullable();
            $t->text('notes')->nullable();
            $t->timestamps();
        });
        Schema::create('document_sequences', function (Blueprint $t) {
            $t->id();
            $t->foreignId('company_id')->constrained()->restrictOnDelete();
            $t->string('series', 20);
            $t->unsignedSmallInteger('year');
            $t->unsignedBigInteger('last_number')->default(0);
            $t->unique(['company_id', 'series', 'year']);
        });
        Schema::create('work_orders', function (Blueprint $t) {
            $t->id();
            $t->string('code')->unique();
            $t->foreignId('order_id')->constrained()->restrictOnDelete();
            $t->foreignId('furnace_id')->nullable()->constrained()->restrictOnDelete();
            $t->foreignId('created_by')->constrained('users')->restrictOnDelete();
            $t->string('type', 20);
            $t->string('status', 30)->default('in_progress');
            $t->unsignedTinyInteger('progress')->default(0);
            $t->string('phase')->default('Carga inicial');
            $t->decimal('weight_kg', 14, 3);
            $t->unsignedInteger('estimated_minutes')->default(180);
            $t->timestamp('started_at')->nullable();
            $t->timestamp('completed_at')->nullable();
            $t->boolean('completed_on_time')->nullable();
            $t->text('notes')->nullable();
            $t->timestamps();
            $t->index(['status', 'type']);
        });
        Schema::create('work_order_events', function (Blueprint $t) {
            $t->id();
            $t->foreignId('work_order_id')->constrained()->restrictOnDelete();
            $t->foreignId('user_id')->constrained()->restrictOnDelete();
            $t->unsignedTinyInteger('progress');
            $t->string('phase');
            $t->text('notes')->nullable();
            $t->timestamps();
        });
        Schema::create('quality_inspections', function (Blueprint $t) {
            $t->id();
            $t->foreignId('work_order_id')->constrained()->restrictOnDelete();
            $t->foreignId('user_id')->constrained()->restrictOnDelete();
            foreach (['carbon', 'silicon', 'manganese', 'phosphorus', 'sulfur'] as $e) {
                $t->decimal($e, 7, 4)->nullable();
            } $t->boolean('porosity')->default(false);
            $t->string('verdict', 30);
            $t->text('notes')->nullable();
            $t->timestamps();
        });
        Schema::create('audit_logs', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->nullable()->constrained()->restrictOnDelete();
            $t->string('action');
            $t->string('entity');
            $t->unsignedBigInteger('entity_id')->nullable();
            $t->json('details')->nullable();
            $t->timestamps();
        });
    }

    public function down(): void
    {
        foreach (['audit_logs', 'quality_inspections', 'work_order_events', 'work_orders', 'document_sequences', 'furnaces', 'orders', 'purchase_orders', 'products', 'process_statuses', 'casting_levels', 'materials', 'clients'] as $name) {
            Schema::dropIfExists($name);
        }
        Schema::table('users', function (Blueprint $t) {
            $t->dropConstrainedForeignId('company_id');
            $t->dropColumn(['role', 'active']);
        });
        Schema::dropIfExists('companies');
    }
};
