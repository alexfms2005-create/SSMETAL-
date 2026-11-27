<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="csrf-token" content="{{ csrf_token() }}"><title>@yield('title','SSMF · SFS | Control de producción')</title><link rel="icon" href="{{ asset('Imagenes/Logo.png') }}"><link rel="stylesheet" href="{{ asset('css/foundry.css') }}"><script defer src="{{ asset('js/foundry.js') }}"></script></head>
<body><header class="topbar"><a class="brand" href="{{ route('backlog') }}"><img src="{{ asset('Imagenes/Logo.png') }}" alt="SS Metal Foundry"><span>SSMF <b> / </b> SFS<small>CONTROL DE PRODUCCIÓN</small></span></a>
@auth<nav>
@foreach(['backlog'=>'Backlog','work-orders.create'=>'Alta de OT','process'=>'Proceso de fundición','terminado'=>'OTs terminadas','reports.index'=>'Reportes'] as $route=>$label)@if($route!=='work-orders.create' || auth()->user()->canOperate())<a class="{{ request()->routeIs($route)?'activo':'' }}" href="{{ route($route) }}">{{ $label }}</a>@endif @endforeach
@if(auth()->user()->canManage())<a class="{{ request()->routeIs('catalogs.*')?'activo':'' }}" href="{{ route('catalogs.index','clientes') }}">Catálogos</a>@endif
@if(auth()->user()->perfil==='administrador')<a class="{{ request()->routeIs('users.*')?'activo':'' }}" href="{{ route('users.index') }}">Usuarios</a>@endif
</nav><div class="account"><span>{{ auth()->user()->nombre }}<small>{{ ['administrador'=>'Administrador','supervisor'=>'Supervisor','operador'=>'Operador','calidad'=>'Calidad','consulta'=>'Consulta'][auth()->user()->perfil] }}</small></span><form method="post" action="{{ route('logout') }}">@csrf<button class="btn small secondary">Salir</button></form></div>@endauth</header>
<main>
@if(session('success'))<div class="notice success" role="status">{{ session('success') }}</div>@endif
@if($errors->any())<div class="notice error" role="alert"><strong>Revisa lo siguiente:</strong><ul>@foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul></div>@endif
@yield('content')
</main><footer><span>Steel Fused Solutions and SS Metal Foundry · {{ now()->year }}</span><span>Registro manual de producción · <time id="clock">{{ now()->format('d/m/Y H:i') }}</time></span></footer></body></html>
