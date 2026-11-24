-- ========================================================
-- SSMF - SS METAL FOUNDRY
-- Base de Datos MySQL: ssmf_db
-- Compatible con phpMyAdmin, MySQL 5.7+ y MySQL 8.0+ / MariaDB
-- ========================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- 1. Crear Base de Datos si no existe
--
CREATE DATABASE IF NOT EXISTS `ssmf_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `ssmf_db`;

-- --------------------------------------------------------

--
-- 2. Estructura de tabla para `furnaces` (Estado y Telemetría de Hornos)
--
CREATE TABLE IF NOT EXISTS `furnaces` (
  `id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `capacity` varchar(50) NOT NULL,
  `capacity_kg` decimal(10,2) NOT NULL,
  `status` varchar(50) NOT NULL,
  `current_temp` int(11) NOT NULL,
  `target_temp` int(11) NOT NULL,
  `active_ot` varchar(50) DEFAULT NULL,
  `material` varchar(100) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `furnaces`
--
INSERT INTO `furnaces` (`id`, `name`, `capacity`, `capacity_kg`, `status`, `current_temp`, `target_temp`, `active_ot`, `material`, `enabled`) VALUES
('horno-a', 'HORNO A', '1.5 Ton', 1500.00, 'EN PROCESO', 1550, 1550, 'OT-2026-087', 'Acero al Carbón', 1),
('horno-b', 'HORNO B', '1.8 Ton', 1800.00, 'LIBRE', 1450, 0, NULL, 'Residual Acero al Carbón', 1),
('horno-c', 'HORNO C', '2.0 Ton', 2000.00, 'MANTENIMIENTO', 85, 0, NULL, 'Inactivo', 0)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

-- --------------------------------------------------------

--
-- 3. Estructura de tabla para `work_orders` (Órdenes de Trabajo de Fundición)
--
CREATE TABLE IF NOT EXISTS `work_orders` (
  `id` varchar(50) NOT NULL,
  `client` varchar(255) NOT NULL,
  `material` varchar(255) NOT NULL,
  `quantity_kg` decimal(10,2) NOT NULL,
  `delivery_date` varchar(100) DEFAULT NULL,
  `furnace_id` varchar(50) DEFAULT NULL,
  `furnace_name` varchar(100) DEFAULT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'in_progress',
  `progress` int(11) DEFAULT 0,
  `phase` varchar(100) DEFAULT NULL,
  `remaining_minutes` int(11) DEFAULT 180,
  `color` varchar(50) DEFAULT 'orange',
  `notes` text DEFAULT NULL,
  `badge` varchar(100) DEFAULT NULL,
  `completed_date` varchar(100) DEFAULT NULL,
  `estimated_time` varchar(100) DEFAULT NULL,
  `real_time` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `work_orders`
--
INSERT INTO `work_orders` (`id`, `client`, `material`, `quantity_kg`, `delivery_date`, `furnace_id`, `furnace_name`, `status`, `progress`, `phase`, `remaining_minutes`, `color`, `notes`, `badge`, `completed_date`, `estimated_time`, `real_time`, `created_at`) VALUES
('OT-2026-082', 'Fundición Minera Integral', 'Aleación Especial', 1800.00, '10 / Nov / 2026', 'horno-c', 'Horno C', 'completed', 100, 'Colada Completa (100%)', 0, 'green', 'Desgasificado con argón.', 'ENTREGADA A TIEMPO', '10/Nov/2026', '5h', '4h 50m', '2026-11-10 16:00:00'),
('OT-2026-084', 'Metalmecánica del Norte', 'Chatarra de Retorno', 950.00, '11 / Nov / 2026', 'horno-b', 'Horno B', 'completed', 100, 'Colada Completa (100%)', 0, 'green', 'Inoculación completada.', 'ENTREGADA A TIEMPO Y EN FORMA', '11/Nov/2026', '3.5h', '3h 20m', '2026-11-11 15:30:00'),
('OT-2026-085', 'Maquinaria Industrial S.A.', 'Acero al Carbón', 1350.00, '11 / Nov / 2026', 'horno-a', 'Horno A', 'completed', 100, 'Colada Completa (100%)', 0, 'green', 'Calidad óptima.', 'LOGRADA EN TIEMPO Y FORMA', '11/Nov/2026', '4h', '3h 45m (¡Éxito en tiempo!)', '2026-11-11 18:00:00'),
('OT-2026-089', 'Maquinaria Industrial S.A.', 'Acero al Carbón', 1200.00, '18 / Nov / 2026', 'horno-a', 'Horno A', 'in_progress', 85, 'Fusión (85%)', 25, 'orange', 'Monitorear temperatura de vaciado a 1550°C.', NULL, NULL, NULL, NULL, CURRENT_TIMESTAMP),
('OT-2026-090', 'Aceros del Bajío S.A.', 'Acero al Carbón', 1400.00, '19 / Nov / 2026', 'horno-b', 'Horno B', 'in_progress', 75, 'Fusión (85%)', 25, 'red', 'Precalentamiento rápido optimizado.', NULL, NULL, NULL, NULL, CURRENT_TIMESTAMP),
('OT-2026-091', 'Estructuras Pesadas S.A.', 'Acero al Carbón', 1100.00, '20 / Nov / 2026', 'horno-a', 'Horno A', 'in_progress', 85, 'Fusión (85%)', 25, 'red', 'Verificar escoria.', NULL, NULL, NULL, NULL, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE `client`=VALUES(`client`);

COMMIT;
