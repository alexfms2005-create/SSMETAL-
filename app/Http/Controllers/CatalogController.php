<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\CastingLevel;
use App\Models\Client;
use App\Models\Company;
use App\Models\Material;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Services\DocumentCode;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class CatalogController extends Controller
{
    private function definition(string $catalog): array
    {
        return match ($catalog) {
            'clientes' => [Client::class, 'Clientes', ['nombre' => 'Nombre', 'rfc' => 'RFC', 'correo' => 'Correo']],
            'materiales' => [Material::class, 'Materiales', ['nombre' => 'Nombre', 'descripcion' => 'Descripción']],
            'productos' => [Product::class, 'Productos', ['codigo_interno' => 'Código interno', 'nombre' => 'Nombre del producto', 'material_id' => 'Material', 'peso_unitario_kg' => 'Peso por pieza (kg)', 'requiere_maquinado' => 'Requiere maquinado']],
            'purchases' => [PurchaseOrder::class, 'Órdenes de compra', ['empresa_id' => 'Empresa', 'cliente_id' => 'Cliente', 'numero_interno' => 'Número de compra interior', 'numero_externo' => 'Número de compra exterior', 'fecha_compra' => 'Fecha de compra', 'fecha_compromiso' => 'Fecha de compromiso']],
            'levels' => [CastingLevel::class, 'Niveles de fundición', ['nivel' => 'Nivel', 'nombre' => 'Nombre']],
            default => abort(404),
        };
    }

    public function index(Request $r, string $catalog)
    {
        abort_unless($r->user()->canManage(), 403);
        [$class,$title,$fields] = $this->definition($catalog);
        $editing = $r->filled('edit') ? $class::findOrFail($r->integer('edit')) : new $class;

        return view('catalogs.index', compact('catalog', 'title', 'fields', 'editing') + ['records' => $class::orderByDesc('id')->paginate(30), 'empresas' => Company::all(), 'clientes' => Client::orderBy('nombre')->get(), 'materiales' => Material::orderBy('nombre')->get()]);
    }

    public function save(Request $r, string $catalog, ?int $id = null)
    {
        abort_unless($r->user()->canManage(), 403);
        [$class] = $this->definition($catalog);
        $record = $id ? $class::findOrFail($id) : new $class;
        $rules = match ($catalog) {
            'clientes' => ['nombre' => ['required', 'string', 'max:255', Rule::unique('clientes')->ignore($id)], 'rfc' => 'nullable|string|max:30', 'correo' => 'nullable|email|max:255'],
            'materiales' => ['nombre' => ['required', 'string', 'max:255', Rule::unique('materiales')->ignore($id)], 'descripcion' => 'nullable|string|max:3000'],
            'productos' => ['codigo_interno' => ['required', 'string', 'max:255', Rule::unique('productos')->where('nombre', $r->nombre)->where('material_id', $r->material_id)->ignore($id)], 'nombre' => 'required|string|max:500', 'material_id' => 'required|exists:materiales,id', 'peso_unitario_kg' => 'required|numeric|min:0|max:999999999', 'requiere_maquinado' => 'nullable|boolean'],
            'purchases' => ['empresa_id' => 'required|exists:empresas,id', 'cliente_id' => 'required|exists:clientes,id', 'numero_interno' => ['nullable', 'required_without:external_number', 'string', 'max:255', Rule::unique('ordenes_compra')->where('empresa_id', $r->empresa_id)->ignore($id)], 'numero_externo' => 'nullable|required_without:internal_number|string|max:255', 'fecha_compra' => 'nullable|date', 'fecha_compromiso' => 'nullable|date|after_or_equal:ordered_at'],
            'levels' => ['nivel' => ['required', 'integer', 'between:1,5', Rule::unique('niveles_fundicion')->ignore($id)], 'nombre' => 'required|string|max:255'],
        };
        $data = $r->validate($rules);
        if ($catalog === 'productos') {
            $data['requiere_maquinado'] = $r->boolean('requiere_maquinado');
        }
        DB::transaction(function () use ($record, $data, $catalog, $r) {
            if ($catalog === 'purchases' && $record->exists) {
                $record = PurchaseOrder::lockForUpdate()->findOrFail($record->id);
                $companyChanged = (int) $record->empresa_id !== (int) $data['empresa_id'];
                $identityChanged = $companyChanged || (int) $record->cliente_id !== (int) $data['cliente_id'];
                if ($identityChanged) {
                    $pedidos = $record->orders()->with('workOrders')->lockForUpdate()->get();
                    if ($pedidos->contains(fn ($o) => $o->workOrders->isNotEmpty())) {
                        throw ValidationException::withMessages(['purchase' => 'Una compra con OTs conserva su empresa y cliente para mantener la trazabilidad.']);
                    }
                    if ($companyChanged) {
                        foreach ($pedidos as $order) {
                            $order->update(['codigo' => DocumentCode::next((int) $data['empresa_id'], $order->tipo_pedido === 'modelo' ? 'PM' : 'PF')]);
                        }
                    }
                }
            }
            $record->fill($data)->save();
            AuditLog::create(['usuario_id' => $r->user()->id, 'accion' => 'catalogo.guardado', 'entidad' => $catalog, 'entidad_id' => $record->id]);
        });

        return redirect()->route('catalogs.index', $catalog)->with('success', 'Registro guardado.');
    }
}
