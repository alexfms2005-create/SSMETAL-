<?php

echo json_encode(['drivers' => PDO::getAvailableDrivers(), 'extension_dir' => ini_get('extension_dir')]);
