<?php

namespace App\Database;

use Illuminate\Database\Migrations\DatabaseMigrationRepository;

/** Conserva la interfaz de Laravel con columnas físicas nombre/lote. */
class RepositorioMigraciones extends DatabaseMigrationRepository
{
    private function enEspanol(): bool
    {
        return $this->getConnection()->getSchemaBuilder()->hasTable('migraciones');
    }

    private function columna(string $columna): string
    {
        return $this->enEspanol() ? ['migration' => 'nombre', 'batch' => 'lote'][$columna] : $columna;
    }

    protected function table()
    {
        return $this->getConnection()->table($this->enEspanol() ? 'migraciones' : 'migrations')->useWritePdo();
    }

    private function consultaCompatible()
    {
        return $this->table()->select('id', $this->columna('migration').' as migration', $this->columna('batch').' as batch');
    }

    public function getRan()
    {
        return $this->table()->orderBy($this->columna('batch'))->orderBy($this->columna('migration'))->pluck($this->columna('migration'))->all();
    }

    public function getMigrations($steps)
    {
        return $this->consultaCompatible()->where($this->columna('batch'), '>=', 1)->orderByDesc($this->columna('batch'))->orderByDesc($this->columna('migration'))->limit($steps)->get()->all();
    }

    public function getMigrationsByBatch($batch)
    {
        return $this->consultaCompatible()->where($this->columna('batch'), $batch)->orderByDesc($this->columna('migration'))->get()->all();
    }

    public function getLast()
    {
        return $this->getMigrationsByBatch($this->getLastBatchNumber());
    }

    public function getMigrationBatches()
    {
        return $this->table()->orderBy($this->columna('batch'))->orderBy($this->columna('migration'))->pluck($this->columna('batch'), $this->columna('migration'))->all();
    }

    public function log($file, $batch)
    {
        $this->table()->insert([$this->columna('migration') => $file, $this->columna('batch') => $batch]);
    }

    public function delete($migration)
    {
        $this->table()->where($this->columna('migration'), $migration->migration)->delete();
    }

    public function getLastBatchNumber()
    {
        return $this->table()->max($this->columna('batch')) ?? 0;
    }

    public function repositoryExists()
    {
        $schema = $this->getConnection()->getSchemaBuilder();

        return $schema->hasTable('migraciones') || $schema->hasTable('migrations');
    }

    public function createRepository()
    {
        $this->getConnection()->getSchemaBuilder()->create('migraciones', function ($tabla) {
            $tabla->increments('id');
            $tabla->string('nombre');
            $tabla->integer('lote');
        });
    }

    public function deleteRepository()
    {
        $this->getConnection()->getSchemaBuilder()->drop($this->enEspanol() ? 'migraciones' : 'migrations');
    }
}
