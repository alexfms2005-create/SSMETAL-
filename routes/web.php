<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BacklogController;
use App\Http\Controllers\CatalogController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\WorkOrderController;
use App\Http\Middleware\ActiveUser;
use Illuminate\Support\Facades\Route;

Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'show'])->name('login');
    Route::post('/login', [AuthController::class, 'login'])->name('login.submit');
});
Route::middleware(['auth', ActiveUser::class])->group(function () {
    Route::redirect('/', '/backlog');
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
    Route::get('/backlog', [BacklogController::class, 'index'])->name('backlog');
    Route::get('/pedidos/nuevo', [BacklogController::class, 'create'])->name('orders.create');
    Route::post('/pedidos', [BacklogController::class, 'store'])->name('orders.store');
    Route::get('/pedidos/{order}/editar', [BacklogController::class, 'edit'])->name('orders.edit');
    Route::put('/pedidos/{order}', [BacklogController::class, 'update'])->name('orders.update');
    Route::get('/ots/nueva', [WorkOrderController::class, 'create'])->name('work-orders.create');
    Route::post('/ots', [WorkOrderController::class, 'store'])->name('work-orders.store');
    Route::get('/proceso', [WorkOrderController::class, 'process'])->name('process');
    Route::put('/ots/{workOrder}/avance', [WorkOrderController::class, 'advance'])->name('work-orders.advance');
    Route::put('/hornos/{furnace}', [WorkOrderController::class, 'furnace'])->name('furnaces.update');
    Route::get('/terminadas', [WorkOrderController::class, 'completed'])->name('terminado');
    Route::get('/catalogos/{catalog}', [CatalogController::class, 'index'])->name('catalogs.index');
    Route::post('/catalogos/{catalog}/{id?}', [CatalogController::class, 'save'])->whereNumber('id')->name('catalogs.save');
    Route::get('/usuarios', [UserController::class, 'index'])->name('users.index');
    Route::post('/usuarios/{id?}', [UserController::class, 'save'])->whereNumber('id')->name('users.save');
    Route::get('/reportes', [ReportController::class, 'index'])->name('reports.index');
    Route::get('/reportes/csv', [ReportController::class, 'csv'])->name('reports.csv');
    Route::get('/reportes/imprimir', [ReportController::class, 'print'])->name('reports.print');
    Route::post('/ots/{workOrder}/calidad', [ReportController::class, 'inspect'])->name('quality.store');
});
