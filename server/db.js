import { DatabaseSync } from 'node:sqlite';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dbPath = path.join(__dirname, 'foundry.sqlite');
const db = new DatabaseSync(dbPath);

// Enable WAL mode for performance and concurrent readers
db.exec('PRAGMA journal_mode = WAL;');

// Initialize tables
db.exec(`
  CREATE TABLE IF NOT EXISTS work_orders (
    id TEXT PRIMARY KEY,
    client TEXT NOT NULL,
    material TEXT NOT NULL,
    quantity_kg REAL NOT NULL,
    delivery_date TEXT,
    furnace_id TEXT,
    furnace_name TEXT,
    status TEXT NOT NULL DEFAULT 'in_progress', -- 'in_progress' or 'completed'
    progress INTEGER DEFAULT 0,
    phase TEXT,
    remaining_minutes INTEGER DEFAULT 180,
    color TEXT DEFAULT 'orange',
    notes TEXT,
    badge TEXT,
    completed_date TEXT,
    estimated_time TEXT,
    real_time TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS furnaces (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    capacity TEXT NOT NULL,
    capacity_kg REAL NOT NULL,
    status TEXT NOT NULL,
    current_temp INTEGER NOT NULL,
    target_temp INTEGER NOT NULL,
    active_ot TEXT,
    material TEXT,
    enabled INTEGER DEFAULT 1
  );
`);

// Check if seeding is needed
const countStmt = db.prepare('SELECT COUNT(*) as count FROM work_orders');
const { count } = countStmt.get();

if (count === 0) {
  console.log('🌱 Seeding initial foundry database records...');

  const insertFurnace = db.prepare(`
    INSERT INTO furnaces (id, name, capacity, capacity_kg, status, current_temp, target_temp, active_ot, material, enabled)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  insertFurnace.run('horno-a', 'HORNO A', '1.5 Ton', 1500, 'EN PROCESO', 1550, 1550, 'OT-2026-087', 'Acero al Carbón', 1);
  insertFurnace.run('horno-b', 'HORNO B', '1.8 Ton', 1800, 'LIBRE', 1450, 0, null, 'Residual Acero al Carbón', 1);
  insertFurnace.run('horno-c', 'HORNO C', '2.0 Ton', 2000, 'MANTENIMIENTO', 85, 0, null, 'Inactivo', 0);

  const insertOT = db.prepare(`
    INSERT INTO work_orders (
      id, client, material, quantity_kg, delivery_date, furnace_id, furnace_name,
      status, progress, phase, remaining_minutes, color, notes, badge,
      completed_date, estimated_time, real_time
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  // Active OTs
  insertOT.run(
    'OT-2026-089',
    'Maquinaria Industrial S.A.',
    'Acero al Carbón',
    1200,
    '18 / Nov / 2026',
    'horno-a',
    'Horno A',
    'in_progress',
    85,
    'Fusión (85%)',
    25,
    'orange',
    'Monitorear temperatura de vaciado a 1550°C.',
    null,
    null,
    null,
    null
  );

  insertOT.run(
    'OT-2026-090',
    'Aceros del Bajío S.A.',
    'Acero al Carbón',
    1400,
    '19 / Nov / 2026',
    'horno-b',
    'Horno B',
    'in_progress',
    75,
    'Fusión (85%)',
    25,
    'red',
    'Precalentamiento rápido optimizado.',
    null,
    null,
    null,
    null
  );

  insertOT.run(
    'OT-2026-091',
    'Estructuras Pesadas S.A.',
    'Acero al Carbón',
    1100,
    '20 / Nov / 2026',
    'horno-a',
    'Horno A',
    'in_progress',
    85,
    'Fusión (85%)',
    25,
    'red',
    'Verificar escoria.',
    null,
    null,
    null,
    null
  );

  // Completed OTs
  insertOT.run(
    'OT-2026-085',
    'Maquinaria Industrial S.A.',
    'Acero al Carbón',
    1350,
    '11 / Nov / 2026',
    'horno-a',
    'Horno A',
    'completed',
    100,
    'Colada Completa (100%)',
    0,
    'green',
    'Calidad óptima.',
    'LOGRADA EN TIEMPO Y FORMA',
    '11/Nov/2026',
    '4h',
    '3h 45m (¡Éxito en tiempo!)'
  );

  insertOT.run(
    'OT-2026-084',
    'Metalmecánica del Norte',
    'Chatarra de Retorno',
    950,
    '11 / Nov / 2026',
    'horno-b',
    'Horno B',
    'completed',
    100,
    'Colada Completa (100%)',
    0,
    'green',
    'Inoculación completada.',
    'ENTREGADA A TIEMPO Y EN FORMA',
    '11/Nov/2026',
    '3.5h',
    '3h 20m'
  );

  insertOT.run(
    'OT-2026-082',
    'Fundición Minera Integral',
    'Aleación Especial',
    1800,
    '10 / Nov / 2026',
    'horno-c',
    'Horno C',
    'completed',
    100,
    'Colada Completa (100%)',
    0,
    'green',
    'Desgasificado con argón.',
    'ENTREGADA A TIEMPO',
    '10/Nov/2026',
    '5h',
    '4h 50m'
  );

  console.log('✅ Base de datos inicializada exitosamente.');
}

export default db;
