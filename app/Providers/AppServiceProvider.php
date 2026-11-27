<?php

namespace App\Providers;

use App\Database\RepositorioMigraciones;
use Illuminate\Database\MigrationServiceProvider;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->register(MigrationServiceProvider::class);
        $this->app->singleton('migration.repository', fn ($app) => new RepositorioMigraciones($app['db'], 'migraciones'));
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
