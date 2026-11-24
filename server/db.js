import 'dotenv/config';
import mysql from 'mysql2/promise';

const DB_HOST = process.env.DB_HOST || '127.0.0.1';
const DB_PORT = Number(process.env.DB_PORT) || 3306;
const DB_USER = process.env.DB_USER || 'root';
const DB_PASSWORD = process.env.DB_PASSWORD || '';
const DB_NAME = process.env.DB_NAME || 'ssmf_db';

// 1. Ensure database exists in MySQL
const initConnection = await mysql.createConnection({
  host: DB_HOST,
  port: DB_PORT,
  user: DB_USER,
  password: DB_PASSWORD
});

await initConnection.query(`CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
await initConnection.end();

// 2. Create connection pool to the specified database
const pool = mysql.createPool({
  host: DB_HOST,
  port: DB_PORT,
  user: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// 3. Create tables if not exists
await pool.query(`
  CREATE TABLE IF NOT EXISTS work_orders (
    id VARCHAR(50) PRIMARY KEY,
    client VARCHAR(255) NOT NULL,
    material VARCHAR(255) NOT NULL,
    quantity_kg DECIMAL(10, 2) NOT NULL,
    delivery_date VARCHAR(100),
    furnace_id VARCHAR(50),
    furnace_name VARCHAR(100),
    status VARCHAR(50) NOT NULL DEFAULT 'in_progress',
    progress INT DEFAULT 0,
    phase VARCHAR(100),
    remaining_minutes INT DEFAULT 180,
    color VARCHAR(50) DEFAULT 'orange',
    notes TEXT,
    badge VARCHAR(100),
    completed_date VARCHAR(100),
    estimated_time VARCHAR(100),
    real_time VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
`);

await pool.query(`
  CREATE TABLE IF NOT EXISTS furnaces (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    capacity VARCHAR(50) NOT NULL,
    capacity_kg DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    current_temp INT NOT NULL,
    target_temp INT NOT NULL,
    active_ot VARCHAR(50),
    material VARCHAR(100),
    enabled TINYINT(1) DEFAULT 1
  );
`);

// 4. Seed initial records if empty
const [countRows] = await pool.query('SELECT COUNT(*) as count FROM work_orders');
if (countRows[0].count === 0) {
  console.log(`🌱 Seeding initial records into MySQL database \`${DB_NAME}\`...`);

  // Furnaces
  await pool.query(`
    INSERT INTO furnaces (id, name, capacity, capacity_kg, status, current_temp, target_temp, active_ot, material, enabled)
    VALUES 
      ('horno-a', 'HORNO A', '1.5 Ton', 1500, 'EN PROCESO', 1550, 1550, 'OT-2026-087', 'Acero al Carbón', 1),
      ('horno-b', 'HORNO B', '1.8 Ton', 1800, 'LIBRE', 1450, 0, NULL, 'Residual Acero al Carbón', 1),
      ('horno-c', 'HORNO C', '2.0 Ton', 2000, 'MANTENIMIENTO', 85, 0, NULL, 'Inactivo', 0)
    ON DUPLICATE KEY UPDATE name=VALUES(name);
  `);

  // Active work orders
  await pool.query(`
    INSERT INTO work_orders (
      id, client, material, quantity_kg, delivery_date, furnace_id, furnace_name,
      status, progress, phase, remaining_minutes, color, notes
    ) VALUES
      ('OT-2026-089', 'Maquinaria Industrial S.A.', 'Acero al Carbón', 1200, '18 / Nov / 2026', 'horno-a', 'Horno A', 'in_progress', 85, 'Fusión (85%)', 25, 'orange', 'Monitorear temperatura de vaciado a 1550°C.'),
      ('OT-2026-090', 'Aceros del Bajío S.A.', 'Acero al Carbón', 1400, '19 / Nov / 2026', 'horno-b', 'Horno B', 'in_progress', 75, 'Fusión (85%)', 25, 'red', 'Precalentamiento rápido optimizado.'),
      ('OT-2026-091', 'Estructuras Pesadas S.A.', 'Acero al Carbón', 1100, '20 / Nov / 2026', 'horno-a', 'Horno A', 'in_progress', 85, 'Fusión (85%)', 25, 'red', 'Verificar escoria.')
    ON DUPLICATE KEY UPDATE client=VALUES(client);
  `);

  // Completed work orders
  await pool.query(`
    INSERT INTO work_orders (
      id, client, material, quantity_kg, delivery_date, furnace_id, furnace_name,
      status, progress, phase, remaining_minutes, color, notes, badge,
      completed_date, estimated_time, real_time
    ) VALUES
      ('OT-2026-085', 'Maquinaria Industrial S.A.', 'Acero al Carbón', 1350, '11 / Nov / 2026', 'horno-a', 'Horno A', 'completed', 100, 'Colada Completa (100%)', 0, 'green', 'Calidad óptima.', 'LOGRADA EN TIEMPO Y FORMA', '11/Nov/2026', '4h', '3h 45m (¡Éxito en tiempo!)'),
      ('OT-2026-084', 'Metalmecánica del Norte', 'Chatarra de Retorno', 950, '11 / Nov / 2026', 'horno-b', 'Horno B', 'completed', 100, 'Colada Completa (100%)', 0, 'green', 'Inoculación completada.', 'ENTREGADA A TIEMPO Y EN FORMA', '11/Nov/2026', '3.5h', '3h 20m'),
      ('OT-2026-082', 'Fundición Minera Integral', 'Aleación Especial', 1800, '10 / Nov / 2026', 'horno-c', 'Horno C', 'completed', 100, 'Colada Completa (100%)', 0, 'green', 'Desgasificado con argón.', 'ENTREGADA A TIEMPO', '10/Nov/2026', '5h', '4h 50m')
    ON DUPLICATE KEY UPDATE client=VALUES(client);
  `);

  console.log(`✅ Base de datos MySQL \`${DB_NAME}\` inicializada y cargada con éxito.`);
}

export default pool;
