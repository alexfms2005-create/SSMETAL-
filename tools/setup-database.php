<?php

require dirname(__DIR__).'/vendor/autoload.php';
Dotenv\Dotenv::createImmutable(dirname(__DIR__))->load();
$nombre = $_ENV['DB_DATABASE'] ?? 'ssmf_laravel';
if (! preg_match('/^[a-zA-Z0-9_]+$/', $nombre)) {
    throw new RuntimeException('Nombre de base inválido.');
}
if (! in_array('mysql', PDO::getAvailableDrivers(), true)) {
    throw new RuntimeException('Habilita pdo_mysql en PHP.');
}
$pdo = new PDO('mysql:host='.$_ENV['DB_HOST'].';port='.$_ENV['DB_PORT'], $_ENV['DB_USERNAME'], $_ENV['DB_PASSWORD'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$pdo->exec("CREATE DATABASE IF NOT EXISTS `$nombre` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
echo "Base preparada: $nombre\n";
