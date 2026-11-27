-- Steel Fused Solutions and SS Metal Foundry
-- Esquema y datos iniciales. No contiene usuarios ni contraseñas.
-- Importar en una base nueva; para actualizar una instalación usa php artisan migrate.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE IF NOT EXISTS `bitacora_sistema` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `accion` varchar(255) NOT NULL,
  `entidad` varchar(255) NOT NULL,
  `entidad_id` bigint(20) unsigned DEFAULT NULL,
  `detalles` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bitacora_sistema_usuario_id_indice` (`usuario_id`),
  CONSTRAINT `bitacora_sistema_usuario_id_foranea` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bloqueos_cache` (
  `clave` varchar(255) NOT NULL,
  `propietario` varchar(255) NOT NULL,
  `expira_en` bigint(20) NOT NULL,
  PRIMARY KEY (`clave`),
  KEY `bloqueos_cache_expira_en_indice` (`expira_en`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `clientes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `rfc` varchar(255) DEFAULT NULL,
  `correo` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `clientes_nombre_unico` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `consecutivos_documentos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `empresa_id` bigint(20) unsigned NOT NULL,
  `serie` varchar(20) NOT NULL,
  `anio` smallint(5) unsigned NOT NULL,
  `ultimo_numero` bigint(20) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `consecutivos_documentos_empresa_id_serie_anio_unico` (`empresa_id`,`serie`,`anio`),
  CONSTRAINT `consecutivos_documentos_empresa_id_foranea` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `datos_cache` (
  `clave` varchar(255) NOT NULL,
  `valor` mediumtext NOT NULL,
  `expira_en` bigint(20) NOT NULL,
  PRIMARY KEY (`clave`),
  KEY `datos_cache_expira_en_indice` (`expira_en`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `empresas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `empresas_codigo_unico` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `estados_proceso` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `posicion` smallint(5) unsigned NOT NULL DEFAULT 0,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `estados_proceso_codigo_unico` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `historial_ordenes_trabajo` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `orden_trabajo_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `avance` tinyint(3) unsigned NOT NULL,
  `fase` varchar(255) NOT NULL,
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `historial_ordenes_trabajo_orden_trabajo_id_indice` (`orden_trabajo_id`),
  KEY `historial_ordenes_trabajo_usuario_id_indice` (`usuario_id`),
  CONSTRAINT `historial_ordenes_trabajo_orden_trabajo_id_foranea` FOREIGN KEY (`orden_trabajo_id`) REFERENCES `ordenes_trabajo` (`id`),
  CONSTRAINT `historial_ordenes_trabajo_usuario_id_foranea` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `hornos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `capacidad_kg` decimal(12,3) NOT NULL,
  `estado` varchar(30) NOT NULL DEFAULT 'disponible',
  `temperatura_actual` int(10) unsigned DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hornos_nombre_unico` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `inspecciones_calidad` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `orden_trabajo_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `carbono` decimal(7,4) DEFAULT NULL,
  `silicio` decimal(7,4) DEFAULT NULL,
  `manganeso` decimal(7,4) DEFAULT NULL,
  `fosforo` decimal(7,4) DEFAULT NULL,
  `azufre` decimal(7,4) DEFAULT NULL,
  `porosidad` tinyint(1) NOT NULL DEFAULT 0,
  `dictamen` varchar(30) NOT NULL,
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `inspecciones_calidad_orden_trabajo_id_indice` (`orden_trabajo_id`),
  KEY `inspecciones_calidad_usuario_id_indice` (`usuario_id`),
  CONSTRAINT `inspecciones_calidad_orden_trabajo_id_foranea` FOREIGN KEY (`orden_trabajo_id`) REFERENCES `ordenes_trabajo` (`id`),
  CONSTRAINT `inspecciones_calidad_usuario_id_foranea` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lotes_trabajos` (
  `id` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `total_trabajos` int(11) NOT NULL,
  `trabajos_pendientes` int(11) NOT NULL,
  `trabajos_fallidos` int(11) NOT NULL,
  `ids_trabajos_fallidos` longtext NOT NULL,
  `opciones` mediumtext DEFAULT NULL,
  `cancelado_en` int(11) DEFAULT NULL,
  `creado_en` int(11) NOT NULL,
  `terminado_en` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `materiales` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `materiales_nombre_unico` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `migraciones` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `lote` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `niveles_fundicion` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nivel` tinyint(3) unsigned NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `niveles_fundicion_nivel_unico` (`nivel`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ordenes_compra` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `empresa_id` bigint(20) unsigned NOT NULL,
  `cliente_id` bigint(20) unsigned NOT NULL,
  `numero_interno` varchar(255) DEFAULT NULL,
  `numero_externo` varchar(255) DEFAULT NULL,
  `fecha_compra` date DEFAULT NULL,
  `fecha_compromiso` date DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ordenes_compra_empresa_id_numero_interno_unico` (`empresa_id`,`numero_interno`),
  KEY `ordenes_compra_cliente_id_indice` (`cliente_id`),
  KEY `ordenes_compra_empresa_id_numero_externo_indice` (`empresa_id`,`numero_externo`),
  CONSTRAINT `ordenes_compra_cliente_id_foranea` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  CONSTRAINT `ordenes_compra_empresa_id_foranea` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ordenes_trabajo` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(255) NOT NULL,
  `pedido_id` bigint(20) unsigned NOT NULL,
  `horno_id` bigint(20) unsigned DEFAULT NULL,
  `creado_por` bigint(20) unsigned NOT NULL,
  `tipo` varchar(20) NOT NULL,
  `estado` varchar(30) NOT NULL DEFAULT 'en_proceso',
  `avance` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `fase` varchar(255) NOT NULL DEFAULT '''Carga inicial''',
  `peso_kg` decimal(14,3) NOT NULL,
  `minutos_estimados` int(10) unsigned NOT NULL DEFAULT 180,
  `iniciado_en` timestamp NULL DEFAULT NULL,
  `terminado_en` timestamp NULL DEFAULT NULL,
  `terminado_a_tiempo` tinyint(1) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  `cantidad` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ordenes_trabajo_codigo_unico` (`codigo`),
  KEY `ordenes_trabajo_creado_por_indice` (`creado_por`),
  KEY `ordenes_trabajo_horno_id_indice` (`horno_id`),
  KEY `ordenes_trabajo_pedido_id_indice` (`pedido_id`),
  KEY `ordenes_trabajo_estado_tipo_indice` (`estado`,`tipo`),
  CONSTRAINT `ordenes_trabajo_creado_por_foranea` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `ordenes_trabajo_horno_id_foranea` FOREIGN KEY (`horno_id`) REFERENCES `hornos` (`id`),
  CONSTRAINT `ordenes_trabajo_pedido_id_foranea` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `pedidos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(255) NOT NULL,
  `clave_origen` varchar(255) DEFAULT NULL,
  `orden_compra_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `material_id` bigint(20) unsigned NOT NULL,
  `nivel_fundicion_id` bigint(20) unsigned DEFAULT NULL,
  `estado_proceso_id` bigint(20) unsigned NOT NULL,
  `tipo_pedido` varchar(20) NOT NULL DEFAULT 'fundicion',
  `cantidad` int(10) unsigned NOT NULL,
  `peso_unitario_kg` decimal(12,3) NOT NULL,
  `peso_por_fundir_kg` decimal(14,3) NOT NULL,
  `requiere_maquinado` tinyint(1) NOT NULL DEFAULT 0,
  `modelo_recibido` tinyint(1) NOT NULL DEFAULT 1,
  `anio_programacion` smallint(5) unsigned DEFAULT NULL,
  `semana_programacion` tinyint(3) unsigned DEFAULT NULL,
  `inicio_programacion` date DEFAULT NULL,
  `fin_programacion` date DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  `cantidad_pendiente` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pedidos_codigo_unico` (`codigo`),
  UNIQUE KEY `pedidos_clave_origen_unico` (`clave_origen`),
  KEY `pedidos_tipo_pedido_inicio_programacion_indice` (`tipo_pedido`,`inicio_programacion`),
  KEY `pedidos_estado_proceso_id_fin_programacion_indice` (`estado_proceso_id`,`fin_programacion`),
  KEY `pedidos_material_id_indice` (`material_id`),
  KEY `pedidos_nivel_fundicion_id_indice` (`nivel_fundicion_id`),
  KEY `pedidos_orden_compra_id_indice` (`orden_compra_id`),
  KEY `pedidos_producto_id_indice` (`producto_id`),
  CONSTRAINT `pedidos_estado_proceso_id_foranea` FOREIGN KEY (`estado_proceso_id`) REFERENCES `estados_proceso` (`id`),
  CONSTRAINT `pedidos_material_id_foranea` FOREIGN KEY (`material_id`) REFERENCES `materiales` (`id`),
  CONSTRAINT `pedidos_nivel_fundicion_id_foranea` FOREIGN KEY (`nivel_fundicion_id`) REFERENCES `niveles_fundicion` (`id`),
  CONSTRAINT `pedidos_orden_compra_id_foranea` FOREIGN KEY (`orden_compra_id`) REFERENCES `ordenes_compra` (`id`),
  CONSTRAINT `pedidos_producto_id_foranea` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `productos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `codigo_interno` varchar(255) NOT NULL,
  `nombre` varchar(500) NOT NULL,
  `material_id` bigint(20) unsigned NOT NULL,
  `peso_unitario_kg` decimal(12,3) NOT NULL DEFAULT 0.000,
  `requiere_maquinado` tinyint(1) NOT NULL DEFAULT 0,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `productos_codigo_interno_nombre_material_id_unico` (`codigo_interno`,`nombre`,`material_id`),
  KEY `productos_material_id_indice` (`material_id`),
  KEY `productos_codigo_interno_indice` (`codigo_interno`),
  CONSTRAINT `productos_material_id_foranea` FOREIGN KEY (`material_id`) REFERENCES `materiales` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sesiones` (
  `id` varchar(255) NOT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `direccion_ip` varchar(45) DEFAULT NULL,
  `agente_usuario` text DEFAULT NULL,
  `contenido` longtext NOT NULL,
  `ultima_actividad` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sesiones_ultima_actividad_indice` (`ultima_actividad`),
  KEY `sesiones_usuario_id_indice` (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tokens_recuperacion_contrasena` (
  `correo` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trabajos_cola` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cola` varchar(255) NOT NULL,
  `contenido` longtext NOT NULL,
  `intentos` tinyint(3) unsigned NOT NULL,
  `reservado_en` int(10) unsigned DEFAULT NULL,
  `disponible_en` int(10) unsigned NOT NULL,
  `creado_en` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `trabajos_cola_cola_indice` (`cola`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trabajos_fallidos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `conexion` text NOT NULL,
  `cola` text NOT NULL,
  `contenido` longtext NOT NULL,
  `excepcion` longtext NOT NULL,
  `fallido_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `trabajos_fallidos_uuid_unico` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `correo` varchar(255) NOT NULL,
  `correo_verificado_en` timestamp NULL DEFAULT NULL,
  `contrasena` varchar(255) NOT NULL,
  `token_recordar` varchar(100) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT NULL,
  `empresa_id` bigint(20) unsigned DEFAULT NULL,
  `perfil` varchar(20) NOT NULL DEFAULT 'consulta',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuarios_correo_unico` (`correo`),
  KEY `usuarios_empresa_id_indice` (`empresa_id`),
  CONSTRAINT `usuarios_empresa_id_foranea` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `migraciones` (`id`,`nombre`,`lote`) VALUES ('1','0001_01_01_000000_create_users_table','1');
INSERT IGNORE INTO `migraciones` (`id`,`nombre`,`lote`) VALUES ('2','0001_01_01_000001_create_cache_table','1');
INSERT IGNORE INTO `migraciones` (`id`,`nombre`,`lote`) VALUES ('3','0001_01_01_000002_create_jobs_table','1');
INSERT IGNORE INTO `migraciones` (`id`,`nombre`,`lote`) VALUES ('4','2026_11_27_000100_create_foundry_tables','1');
INSERT IGNORE INTO `migraciones` (`id`,`nombre`,`lote`) VALUES ('5','2026_11_27_000200_preserve_product_variants_and_model_quantities','2');
INSERT IGNORE INTO `migraciones` (`id`,`nombre`,`lote`) VALUES ('6','2026_11_27_000300_traducir_base_de_datos_al_espanol','3');

INSERT IGNORE INTO `empresas` (`id`,`codigo`,`nombre`,`creado_en`,`actualizado_en`) VALUES ('1','SSMF','SS Metal Foundry','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `empresas` (`id`,`codigo`,`nombre`,`creado_en`,`actualizado_en`) VALUES ('2','SFS','Steel Fused Solutions','2026-11-27 11:26:06','2026-11-27 11:26:06');

INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('1','TRITURACIÓN',NULL,NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('2','CHISPAS',NULL,NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('3','LA GUITARRA',NULL,NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('4','TRITURACIÓN Y DISEÑO',NULL,NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('5','BLACO. RENT',NULL,NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('6','ELIZABETH',NULL,NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('7','CRIBAMEX',NULL,NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('8','ZILAR',NULL,NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('9','LA CONCHA',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('10','MARTÍN QUINTERO',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('11','XANIK',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('12','BOLAÑITOS',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('13','CARLOS OCAMPO',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('14','AGASSINI',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('15','FABRICA DE EQUIPOS',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('16','GUITARRA',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('17','IMISA',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('18','ENGRANES NACIONALES',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `clientes` (`id`,`nombre`,`rfc`,`correo`,`creado_en`,`actualizado_en`) VALUES ('19','PINGUICO',NULL,NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');

INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('1','Acero al Carbón',NULL,'2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('2','Chatarra de Retorno',NULL,'2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('3','Ferroaleaciones',NULL,'2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('4','Aleación Especial',NULL,'2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('5','Hierro Gris',NULL,'2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('6','Hierro Nodular',NULL,'2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('7','Acero Inoxidable 316',NULL,'2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('8','NI HARD 3B M',NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('9','AC MN SS17',NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('10','AC MN SS14',NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('11','HG',NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('12','NI HARD 3AM',NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('13','410',NULL,'2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('14','4140',NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('15','WCB',NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('16','NI HARD 3B',NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('17','MADERA',NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('18','NODULAR',NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `materiales` (`id`,`nombre`,`descripcion`,`creado_en`,`actualizado_en`) VALUES ('19','ALUMINIO',NULL,'2026-11-27 11:26:08','2026-11-27 11:26:08');

INSERT IGNORE INTO `niveles_fundicion` (`id`,`nivel`,`nombre`,`creado_en`,`actualizado_en`) VALUES ('1','1','Nivel 1','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `niveles_fundicion` (`id`,`nivel`,`nombre`,`creado_en`,`actualizado_en`) VALUES ('2','2','Nivel 2','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `niveles_fundicion` (`id`,`nivel`,`nombre`,`creado_en`,`actualizado_en`) VALUES ('3','3','Nivel 3','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `niveles_fundicion` (`id`,`nivel`,`nombre`,`creado_en`,`actualizado_en`) VALUES ('4','4','Nivel 4','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `niveles_fundicion` (`id`,`nivel`,`nombre`,`creado_en`,`actualizado_en`) VALUES ('5','5','Nivel 5','2026-11-27 11:26:06','2026-11-27 11:26:06');

INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('1','pendiente','Por fundir / pendiente','0','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('2','modelo_pendiente','Modelo faltante','1','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('3','moldeo','Modelado / moldeo','2','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('4','programado','Programado','3','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('5','fusion','Fundición en proceso','4','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('6','tratamiento_termico','Tratamiento térmico','5','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('7','maquinado','Maquinado','6','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('8','acabados','Acabados','7','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('9','calidad','Inspección de calidad','8','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `estados_proceso` (`id`,`codigo`,`nombre`,`posicion`,`creado_en`,`actualizado_en`) VALUES ('10','terminado','Terminado','9','2026-11-27 11:26:06','2026-11-27 11:26:06');

INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('1','QLLX6412-A-47M','LISTÓN PARA QUEB. DE LISTONES GENÉRICA SIN NÚMERO','8','390.000','0','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('2','QMMMC106-A-17','MUELA MÓVIL METSO C106 3/6','9','1080.000','0','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('3','QCEC3-A-17','PLATO DISTRIBUIDOR PARA QUEB. SYMONS 3 FT SH','10','302.000','1','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('4','110926001-A-10','BUJE CÓNICO B1310-5M','11','35.000','0','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('5','QLLAMC13-A-45 M','LISTÓN EXTEC C-13','12','285.000','0','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('6','LEGACY-B45-04','CUCHARAS ESCOREADORAS CON MANGO (SOLDADAS)','13','10.000','0','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('7','DEL CLIENTE','CUÑA PARA MUELA MÓVIL','10','20.000','0','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('8','QMFP2436-F-17','MUELA FIJA PETTIBONE 24X36 PERFIL GRUESO','9','815.000','0','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('9','QMMP2436-F-17','MUELA MÓVIL PETTIBONE 24X36 PERFIL GRUESO','9','870.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('10','311025001-A-22','BUJE BALERO DE CRIBA','14','190.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('11','QMFMC80-B-17','MUELA FIJA METSO C80','9','590.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('12','QMFMC106-A-17','MUELA FIJA METSO C106 4/6','9','1050.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('13','QMAMC106-B-14','BLINDAJE INFERIOR IZQUIERDO PARA METSO C106 4/6','10','70.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('14','QMTMC106-A-22','TOGGLE PARA METSO C106 4/6','14','120.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('15','LEGACY-B46-10','CUÑA PARA LISTÓN DE IMPACTOR 1','10','6.250','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('16','LEGACY-B46-11','CUCHARAS ESCOREADORAS CON MANGO (SOLDADAS)','13','10.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('17','40029-A','PTE 12-150','15','16.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('18','QLLX4040-A-17','LISTÓN PARA QUEBRADORA 4040','9','90.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('19','160323001-A-13','CUADROS DE DESGASTE','9','20.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('20','MMN107-B-47','LAINA MÓVIL JCT 105 (SMOOTH)','16','15.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('21','LEGACY-B47-04','PANTALLA IMPACTOR HARTL 1060 IC/ROSCA P/TORNILLO DE 15/16','9','70.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('22','XO-MF-30X42','MODELO MUELA FIJA PERFIL MEDIO GRUESO PARA QUEB. TELSMITH 30X42','17','0.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('23','QMDMC106-A-14','BLINDAJE SUP DERECHO PARA METSO C106 5/6','10','90.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('24','QMZMC106-A-14','BLINDAJE SUP IZQUIERDO PARA METSO C106 5/6','10','90.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('25','QMDMC106-B-14','BLINDAJE INFERIOR DERECHO PARA METSO C106 5/6','10','70.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('26','QMZMC106-B-14','BLINDAJE INFERIOR IZQUIERDO PARA METSO C106 5/6','10','70.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('27','LEGACY-B47-13','PARRILLA DE TRITURACIÓN DE CALIZA SISTEMA I Y II','9','825.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('28','SP70914','CARCAZA AM','11','4.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('29','SP70367','CARCAZA AP','11','10.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('30','2 BANDAS 10 HP','POLEA DE 2 BANDAS (10 HP)','11','15.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('31','41450','CPO 12-300','15','192.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('32','42305','DCO 12-300','15','105.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('33','41482','VTE 24\"','15','25.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('34','41483','BUJE 24\"','15','7.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('35','41425','PTE 2, 3-1500','15','15.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('36','QMFX1030-A-17','MUELA FIJA 10X36','9','280.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('37','QMMX1030-A-17','MUELA MÓVIL 10X36','9','305.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('38','QMDX1030-A-17','BLINDAJE 10X36','10','45.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('39','BLVBXHD100-A-47','VOLUTA PARA BOMBA GOULDS XHD 100','16','150.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('40','BLPBXHD100-A-47','PLATO DE SUCCIÓN BOMBA GOULDS XHD 100','16','80.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('41','BLIBXCH100-A-47','IMPULSOR BOMBA GOULDS XHD 100','16','60.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('42','BLVBXHD80-A-47','VOLUTA PARA BOMBA GOULDS XHD 80','16','60.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('43','BLPBXHD80-A-47','PLATO DE SUCCIÓN PARA BOMBA XHD 80','16','26.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('44','BLIBXHD80-A-47','IMPULSOR PARA BOMBA XHD 80','16','25.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('45','41928','VTE 10\" CIEGO','15','3.300','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('46','24532','BUJE IMPACTOR 16\" DIAM.','15','60.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('47','24531','VTE 16\" HEX','15','14.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('48','QLPD5048-A-17','PLACA 16 x 11 x 1 1/2 C/4 BARRENOS STD 3/4\" IMPACTOR 50X48','9','35.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('49','Z=80','ENGRANE Z=80','18','660.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('50','QMST3042-B-17','CUÑA WEDGE FOR SWING JAW DIE (LH) IZQ PARA QUEB. TRIO 30X42','9','26.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('51','QMST3042-A-17','CUÑA WEDGE FOR SWING JAW DIE (RH) DER PARA QUEB. TRIO 30X42','9','26.000','0','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('52','BLVW86-A-47','VOLUTA PARA QUEB. WARMAN 8X6','19','250.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('53','BLPW86-A-47','PLATO DE SUCCIÓN PARA QUEB. WARMAN 8X6','19','115.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('54','BLLW86-A-47','FRAME PLATE WARMAN 8X6','19','82.000','1','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('55','QMMMC106-A-17','MUELA MÓVIL METSO C106 4/6','9','1080.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('56','QMFMC106-A-17','MUELA FIJA METSO C106 5/6','9','1050.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('57','QMMMC106-A-17','MUELA MÓVIL METSO C106 5/6','9','1080.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('58','QMTMC106-A-22','TOGGLE PARA METSO C106 5/6','14','120.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('59','41450','BTE 12-300','15','192.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('60','QMFMC106-A-17','MUELA FIJA METSO C106 6/6','9','1050.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('61','QMMMC106-A-17','MUELA MÓVIL METSO C106 6/6','9','1080.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('62','QMDMC106-A-14','BLINDAJE SUP DERECHO PARA METSO C106 6/6','10','90.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('63','QMZMC106-A-14','BLINDAJE SUP IZQUIERDO PARA METSO C106 6/6','10','90.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('64','QMDMC106-B-14','BLINDAJE INFERIOR DERECHO PARA METSO C106 6/6','10','70.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('65','QMZMC106-B-14','BLINDAJE INFERIOR IZQUIERDO PARA METSO C106 6/6','10','70.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('66','QMTMC106-A-22','TOGGLE PARA METSO C106 6/6','14','120.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');
INSERT IGNORE INTO `productos` (`id`,`codigo_interno`,`nombre`,`material_id`,`peso_unitario_kg`,`requiere_maquinado`,`creado_en`,`actualizado_en`) VALUES ('67','XO-MF-30X42','MUELA FIJA PERFIL MEDIO GRUESO PARA QUEB. TELSMITH 30X42','9','1120.000','0','2026-11-27 11:30:02','2026-11-27 11:30:02');

INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('1','1','1',NULL,'REP. OC130','2026-09-24','2026-10-05','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('2','1','2','250626-137','26097','2026-06-25','2026-08-14','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('3','1','3','091026-223','4133','2026-10-09','2026-11-29','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('4','1','4','090926-203','090926-203','2026-09-09','2026-09-30','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('5','1','5','090926-204','090926-204','2026-09-09','2026-10-12','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('6','1','6','280926-215','26469','2026-09-28','2026-11-01','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('7','1','7','301026-243','301026-243','2026-10-30','2026-11-12','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('8','1','8','071026-221','4200002021','2026-10-07','2026-11-09','2026-11-27 11:26:07','2026-11-27 11:26:07');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('9','1','9','061026-222','061026-221','2026-10-06','2026-11-16','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('10','1','2','161026-231','27611','2026-10-16','2026-11-13','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('11','1','10','240926-212','240926-212','2026-09-23','2026-10-23','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('12','1','11','301026-237','45921-2','2026-10-30','2026-11-09','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('13','1','7','300926-217-300926-218','300926-217','2026-09-30','2026-11-02','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('14','1','7','290926-216','290926-216','2026-09-29','2026-10-30','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('15','1','12','031126-241','906167','2026-11-03','2026-11-16','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('16','1','13','301026-239','301026-239','2026-10-30','2026-11-19','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('17','1','13','141026-225','141026-225','2026-10-14','2026-11-16','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('18','1','14','161026-230','P00431','2026-10-16','2026-11-19','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('19','1','15','141026-226','53152','2026-10-14','2026-11-09','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('20','1','15','211026-233','53195','2026-10-21','2026-11-18','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('21','1','11','260826-194','44466-2','2026-08-25','2026-10-02','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('22','1','11','230926-209','45024-1','2026-09-23','2026-10-23','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('23','1','11','061026-220','45383-1','2026-10-06','2026-11-06','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('24','1','13','211026-232','211026-232','2026-10-21','2026-11-04','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('25','1','16','031126-242','X ENVIAR','2026-11-03','2026-11-26','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('26','1','11','141026-227','45550-1','2026-10-14','2026-11-09','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('27','1','11','141026-228','45502-2','2026-10-14','2026-11-09','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('28','1','11','161026-229','45600-2','2026-10-16','2026-11-13','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('29','1','15','271026-235','53305','2026-10-27','2026-11-27','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('30','1','17','291026-236','291026-236','2026-10-29','2026-11-27','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('31','1','18','231026-234','19373','2026-10-23','2026-11-20','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('32','1','19','301026-238','120597','2026-11-06','2026-12-03','2026-11-27 11:26:08','2026-11-27 11:26:08');
INSERT IGNORE INTO `ordenes_compra` (`id`,`empresa_id`,`cliente_id`,`numero_interno`,`numero_externo`,`fecha_compra`,`fecha_compromiso`,`creado_en`,`actualizado_en`) VALUES ('33','1','12',NULL,'GEISH','2026-05-25','2026-07-10','2026-11-27 11:26:08','2026-11-27 11:26:08');

INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('1','SSMF-PF-2026-00001','B44-01','1','1','8',NULL,'1','fundicion','3','390.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 44. Estado original: 2 OK, 1 PENDIENTE. La programación queda pendiente de asignación manual.','2026-11-27 11:26:07','2026-11-27 11:26:07','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('2','SSMF-PF-2026-00002','B44-02','2','2','9',NULL,'1','fundicion','1','1080.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 44. Estado original: 03/11/2026. La programación queda pendiente de asignación manual.','2026-11-27 11:26:07','2026-11-27 11:26:07','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('3','SSMF-PF-2026-00003','B45-01','3','3','10',NULL,'7','fundicion','1','302.000','0.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 45. Estado original: MAQUINADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:07','2026-11-27 11:26:07','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('4','SSMF-PF-2026-00004','B45-02','4','4','11',NULL,'8','fundicion','2','35.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 45. Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:07','2026-11-27 11:26:07','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('5','SSMF-PF-2026-00005','B45-03','5','5','12',NULL,'8','fundicion','4','285.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 45. Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:07','2026-11-27 11:26:07','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('6','SSMF-PF-2026-00006','B45-04','6','6','13',NULL,'8','fundicion','50','10.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 45. Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:07','2026-11-27 11:26:07','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('7','SSMF-PF-2026-00007','B46-01','7','7','10',NULL,'8','fundicion','1','20.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:07','2026-11-27 11:26:07','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('8','SSMF-PF-2026-00008','B46-02','8','8','9',NULL,'4','fundicion','1','815.000','815.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:07','2026-11-27 11:26:07','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('9','SSMF-PF-2026-00009','B46-03','8','9','9',NULL,'4','fundicion','1','870.000','870.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('10','SSMF-PF-2026-00010','B46-04','9','10','14',NULL,'8','fundicion','1','190.000','0.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('11','SSMF-PF-2026-00011','B46-05','10','11','9',NULL,'4','fundicion','3','590.000','1770.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','3');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('12','SSMF-PF-2026-00012','B46-06','2','12','9',NULL,'1','fundicion','1','1050.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: EN ESPERA. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('13','SSMF-PF-2026-00013','B46-07','2','55','9',NULL,'1','fundicion','1','1080.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: EN ESPERA. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('14','SSMF-PF-2026-00014','B46-08','2','13','10',NULL,'8','fundicion','1','70.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('15','SSMF-PF-2026-00015','B46-09','2','14','14',NULL,'8','fundicion','1','120.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('16','SSMF-PF-2026-00016','B46-10','11','15','10',NULL,'4','fundicion','8','6.250','50.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','8');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('17','SSMF-PF-2026-00017','B46-11','6','16','13',NULL,'8','fundicion','50','10.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('18','SSMF-PF-2026-00018','B46-12','12','17','15',NULL,'8','fundicion','2','16.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 46 (ACTIVA). Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('19','SSMF-PF-2026-00019','B47-01','13','18','9',NULL,'8','fundicion','8','90.000','540.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: 2 ACABADOS, 4 PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','6');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('20','SSMF-PF-2026-00020','B47-02','14','19','9',NULL,'3','fundicion','22','20.000','440.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: MOLDEO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','22');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('21','SSMF-PF-2026-00021','B47-03','15','20','16',NULL,'4','fundicion','2','15.000','30.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('22','SSMF-PF-2026-00022','B47-04','16','21','9',NULL,'1','fundicion','2','70.000','140.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PENDIENTE. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('23','SSMF-PM-2026-00001','B47-05','17','22','17',NULL,'2','modelo','1','0.000','0.000','0','0',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: MODELO FALTANTE. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('24','SSMF-PF-2026-00024','B47-06','2','56','9',NULL,'4','fundicion','1','1050.000','1050.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROGRAMAR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('25','SSMF-PF-2026-00025','B47-07','2','57','9',NULL,'4','fundicion','1','1080.000','1080.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROGRAMAR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('26','SSMF-PF-2026-00026','B47-08','2','23','10',NULL,'4','fundicion','1','90.000','90.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROGRAMAR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('27','SSMF-PF-2026-00027','B47-09','2','24','10',NULL,'4','fundicion','1','90.000','90.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROGRAMAR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('28','SSMF-PF-2026-00028','B47-10','2','25','10',NULL,'4','fundicion','1','70.000','70.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROGRAMAR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('29','SSMF-PF-2026-00029','B47-11','2','26','10',NULL,'4','fundicion','1','70.000','70.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROGRAMAR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('30','SSMF-PF-2026-00030','B47-12','2','58','14',NULL,'4','fundicion','1','120.000','120.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROGRAMAR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('31','SSMF-PF-2026-00031','B47-13','18','27','9',NULL,'3','fundicion','2','825.000','1650.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: MOLDEO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('32','SSMF-PF-2026-00032','B47-14','19','28','11',NULL,'3','fundicion','10','4.000','40.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: MOLDEO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','10');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('33','SSMF-PF-2026-00033','B47-15','19','29','11',NULL,'3','fundicion','10','10.000','100.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: MOLDEO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','10');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('34','SSMF-PF-2026-00034','B47-16','20','30','11',NULL,'3','fundicion','6','15.000','90.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: MOLDEO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','6');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('35','SSMF-PF-2026-00035','B47-17','21','31','15',NULL,'4','fundicion','1','192.000','192.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('36','SSMF-PF-2026-00036','B47-18','21','59','15',NULL,'8','fundicion','1','192.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('37','SSMF-PF-2026-00037','B47-19','21','32','15',NULL,'8','fundicion','1','105.000','0.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: ACABADOS. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','0');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('38','SSMF-PF-2026-00038','B47-20','22','33','15',NULL,'4','fundicion','10','25.000','250.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','10');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('39','SSMF-PF-2026-00039','B47-21','22','34','15',NULL,'4','fundicion','10','7.000','70.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','10');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('40','SSMF-PF-2026-00040','B47-22','23','35','15',NULL,'4','fundicion','4','15.000','60.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 47. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','4');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('41','SSMF-PF-2026-00041','B48-01','24','36','9',NULL,'1','fundicion','1','280.000','280.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('42','SSMF-PF-2026-00042','B48-02','24','37','9',NULL,'1','fundicion','1','305.000','305.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('43','SSMF-PF-2026-00043','B48-03','24','38','10',NULL,'1','fundicion','2','45.000','90.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('44','SSMF-PF-2026-00044','B48-04','2','60','9',NULL,'1','fundicion','1','1050.000','1050.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('45','SSMF-PF-2026-00045','B48-05','2','61','9',NULL,'1','fundicion','1','1080.000','1080.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('46','SSMF-PF-2026-00046','B48-06','2','62','10',NULL,'1','fundicion','1','90.000','90.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('47','SSMF-PF-2026-00047','B48-07','2','63','10',NULL,'1','fundicion','1','90.000','90.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('48','SSMF-PF-2026-00048','B48-08','2','64','10',NULL,'1','fundicion','1','70.000','70.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('49','SSMF-PF-2026-00049','B48-09','2','65','10',NULL,'1','fundicion','1','70.000','70.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('50','SSMF-PF-2026-00050','B48-10','2','66','14',NULL,'1','fundicion','1','120.000','120.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('51','SSMF-PF-2026-00051','B48-11','17','67','9',NULL,'2','fundicion','1','1120.000','1120.000','0','0',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: MODELO FALTANTE. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:30:02','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('52','SSMF-PF-2026-00052','B48-12','25','39','16',NULL,'7','fundicion','2','150.000','300.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: MAQUINADO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('53','SSMF-PF-2026-00053','B48-13','25','40','16',NULL,'7','fundicion','2','80.000','160.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: MAQUINADO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('54','SSMF-PF-2026-00054','B48-14','25','41','16',NULL,'7','fundicion','2','60.000','120.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: MAQUINADO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('55','SSMF-PF-2026-00055','B48-15','25','42','16',NULL,'7','fundicion','2','60.000','120.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: MAQUINADO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('56','SSMF-PF-2026-00056','B48-16','25','43','16',NULL,'7','fundicion','2','26.000','52.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: MAQUINADO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('57','SSMF-PF-2026-00057','B48-17','25','44','16',NULL,'7','fundicion','2','25.000','50.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: MAQUINADO. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('58','SSMF-PF-2026-00058','B48-18','26','35','15',NULL,'4','fundicion','2','15.000','30.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('59','SSMF-PF-2026-00059','B48-19','27','45','15',NULL,'4','fundicion','50','3.300','165.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','50');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('60','SSMF-PF-2026-00060','B48-20','28','46','15',NULL,'4','fundicion','10','60.000','600.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','10');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('61','SSMF-PF-2026-00061','B48-21','28','47','15',NULL,'4','fundicion','10','14.000','140.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: PROG 46. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','10');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('62','SSMF-PF-2026-00062','B48-22','29','28','11',NULL,'1','fundicion','5','4.000','20.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','5');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('63','SSMF-PF-2026-00063','B48-23','29','29','11',NULL,'1','fundicion','5','10.000','50.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','5');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('64','SSMF-PF-2026-00064','B48-24','30','48','9',NULL,'1','fundicion','5','35.000','175.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','5');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('65','SSMF-PF-2026-00065','B48-25','31','49','18',NULL,'1','fundicion','1','660.000','660.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 48. Estado original: PRIORIDAD ALTA. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('66','SSMF-PF-2026-00066','B49-01','32','50','9',NULL,'1','fundicion','2','26.000','52.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 49. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('67','SSMF-PF-2026-00067','B49-02','32','51','9',NULL,'1','fundicion','2','26.000','52.000','0','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: SEMANA 49. Estado original: POR FUNDIR. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','2');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('68','SSMF-PF-2026-00068','BSP-01','33','52','19',NULL,'1','fundicion','1','250.000','250.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: PEDIDOS ESPECIALES / GEISH. Estado original: ESPECIAL GEISH. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('69','SSMF-PF-2026-00069','BSP-02','33','53','19',NULL,'1','fundicion','1','115.000','115.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: PEDIDOS ESPECIALES / GEISH. Estado original: ESPECIAL GEISH. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');
INSERT IGNORE INTO `pedidos` (`id`,`codigo`,`clave_origen`,`orden_compra_id`,`producto_id`,`material_id`,`nivel_fundicion_id`,`estado_proceso_id`,`tipo_pedido`,`cantidad`,`peso_unitario_kg`,`peso_por_fundir_kg`,`requiere_maquinado`,`modelo_recibido`,`anio_programacion`,`semana_programacion`,`inicio_programacion`,`fin_programacion`,`observaciones`,`creado_en`,`actualizado_en`,`cantidad_pendiente`) VALUES ('70','SSMF-PF-2026-00070','BSP-03','33','54','19',NULL,'1','fundicion','1','82.000','82.000','1','1',NULL,NULL,NULL,NULL,'Importado del archivo original. Grupo de origen: PEDIDOS ESPECIALES / GEISH. Estado original: ESPECIAL GEISH. La programación queda pendiente de asignación manual.','2026-11-27 11:26:08','2026-11-27 11:26:08','1');

INSERT IGNORE INTO `hornos` (`id`,`nombre`,`capacidad_kg`,`estado`,`temperatura_actual`,`observaciones`,`creado_en`,`actualizado_en`) VALUES ('1','HORNO A','1500.000','disponible',NULL,'Temperatura pendiente de captura manual. Sin conexión a sensores.','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `hornos` (`id`,`nombre`,`capacidad_kg`,`estado`,`temperatura_actual`,`observaciones`,`creado_en`,`actualizado_en`) VALUES ('2','HORNO B','1800.000','disponible',NULL,'Temperatura pendiente de captura manual. Sin conexión a sensores.','2026-11-27 11:26:06','2026-11-27 11:26:06');
INSERT IGNORE INTO `hornos` (`id`,`nombre`,`capacidad_kg`,`estado`,`temperatura_actual`,`observaciones`,`creado_en`,`actualizado_en`) VALUES ('3','HORNO C','2000.000','mantenimiento',NULL,'Temperatura pendiente de captura manual. Sin conexión a sensores.','2026-11-27 11:26:07','2026-11-27 11:26:07');

INSERT IGNORE INTO `consecutivos_documentos` (`id`,`empresa_id`,`serie`,`anio`,`ultimo_numero`) VALUES ('1','1','PF','2026','70');
INSERT IGNORE INTO `consecutivos_documentos` (`id`,`empresa_id`,`serie`,`anio`,`ultimo_numero`) VALUES ('71','1','PM','2026','1');

CREATE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW `adaptador_sesiones` AS SELECT `id` AS `id`, `usuario_id` AS `user_id`, `direccion_ip` AS `ip_address`, `agente_usuario` AS `user_agent`, `contenido` AS `payload`, `ultima_actividad` AS `last_activity` FROM `sesiones`;
CREATE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW `adaptador_tokens_recuperacion_contrasena` AS SELECT `correo` AS `email`, `token` AS `token`, `creado_en` AS `created_at` FROM `tokens_recuperacion_contrasena`;
CREATE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW `adaptador_datos_cache` AS SELECT `clave` AS `key`, `valor` AS `value`, `expira_en` AS `expiration` FROM `datos_cache`;
CREATE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW `adaptador_bloqueos_cache` AS SELECT `clave` AS `key`, `propietario` AS `owner`, `expira_en` AS `expiration` FROM `bloqueos_cache`;
CREATE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW `adaptador_trabajos_cola` AS SELECT `id` AS `id`, `cola` AS `queue`, `contenido` AS `payload`, `intentos` AS `attempts`, `reservado_en` AS `reserved_at`, `disponible_en` AS `available_at`, `creado_en` AS `created_at` FROM `trabajos_cola`;
CREATE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW `adaptador_lotes_trabajos` AS SELECT `id` AS `id`, `nombre` AS `name`, `total_trabajos` AS `total_jobs`, `trabajos_pendientes` AS `pending_jobs`, `trabajos_fallidos` AS `failed_jobs`, `ids_trabajos_fallidos` AS `failed_job_ids`, `opciones` AS `options`, `cancelado_en` AS `cancelled_at`, `creado_en` AS `created_at`, `terminado_en` AS `finished_at` FROM `lotes_trabajos`;
CREATE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW `adaptador_trabajos_fallidos` AS SELECT `id` AS `id`, `uuid` AS `uuid`, `conexion` AS `connection`, `cola` AS `queue`, `contenido` AS `payload`, `excepcion` AS `exception`, `fallido_en` AS `failed_at` FROM `trabajos_fallidos`;
SET FOREIGN_KEY_CHECKS=1;
