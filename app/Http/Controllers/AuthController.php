<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function show()
    {
        return view('auth.login');
    }

    public function login(Request $r)
    {
        $data = $r->validate(['correo' => 'required|email', 'contrasena' => 'required|string']);
        $key = mb_strtolower($data['correo']).'|'.$r->ip();
        if (RateLimiter::tooManyAttempts($key, 5)) {
            throw ValidationException::withMessages(['correo' => 'Demasiados intentos. Espera '.RateLimiter::availableIn($key).' segundos.']);
        }
        if (! Auth::attempt(['correo' => $data['correo'], 'password' => $data['contrasena'], 'activo' => true])) {
            RateLimiter::hit($key, 60);
            throw ValidationException::withMessages(['correo' => 'Credenciales incorrectas o usuario inactivo.']);
        }
        RateLimiter::clear($key);
        $r->session()->regenerate();

        return redirect()->intended(route('backlog'));
    }

    public function logout(Request $r)
    {
        Auth::logout();
        $r->session()->invalidate();
        $r->session()->regenerateToken();

        return redirect()->route('login');
    }
}
