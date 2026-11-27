<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Company;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class UserController extends Controller
{
    public function index(Request $r)
    {
        abort_unless($r->user()->perfil === 'administrador', 403);

        return view('users.index', ['usuarios' => User::with('company')->orderBy('nombre')->get(), 'empresas' => Company::all(), 'editing' => $r->filled('edit') ? User::findOrFail($r->integer('edit')) : new User]);
    }

    public function save(Request $r, ?int $id = null)
    {
        abort_unless($r->user()->perfil === 'administrador', 403);
        $d = $r->validate(['nombre' => 'required|string|max:255', 'correo' => ['required', 'email', 'max:255', Rule::unique('usuarios')->ignore($id)], 'contrasena' => [$id ? 'nullable' : 'required', 'string', 'min:12', 'confirmed'], 'perfil' => 'required|in:administrador,supervisor,operador,calidad,consulta', 'empresa_id' => 'nullable|exists:empresas,id', 'activo' => 'nullable|boolean']);
        $d['activo'] = $r->boolean('activo');
        if (empty($d['contrasena'])) {
            unset($d['contrasena']);
        }
        if ($id === $r->user()->id && (! $d['activo'] || $d['perfil'] !== 'administrador')) {
            throw ValidationException::withMessages(['user' => 'No puedes desactivar tu propia cuenta ni retirar tu rol administrador.']);
        }
        DB::transaction(function () use ($id, $d, $r) {
            $u = $id ? User::findOrFail($id) : new User;
            $u->fill($d)->save();
            AuditLog::create(['usuario_id' => $r->user()->id, 'accion' => 'usuario.guardado', 'entidad' => 'usuarios', 'entidad_id' => $u->id]);
        });

        return redirect()->route('users.index')->with('success', 'Usuario guardado.');
    }
}
