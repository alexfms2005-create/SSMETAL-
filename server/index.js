import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import pool from './db.js';

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Helper to format DB work order rows to frontend model
const formatOT = (row) => ({
  id: row.id,
  furnaceId: row.furnace_id,
  furnaceName: row.furnace_name,
  material: row.material,
  progress: Number(row.progress) || 0,
  phase: row.phase,
  remainingMinutes: Number(row.remaining_minutes) || 0,
  client: row.client,
  quantityKg: Number(row.quantity_kg) || 0,
  color: row.color,
  notes: row.notes,
  deliveryDate: row.delivery_date,
  badge: row.badge,
  completedDate: row.completed_date,
  estimatedTime: row.estimated_time,
  realTime: row.real_time,
  createdAt: row.created_at
});

// GET /api/ots - Retrieve all work orders categorized from MySQL
app.get('/api/ots', async (req, res) => {
  try {
    const [inProgressRows] = await pool.query(
      "SELECT * FROM work_orders WHERE status = 'in_progress' ORDER BY created_at DESC"
    );
    const [completedRows] = await pool.query(
      "SELECT * FROM work_orders WHERE status = 'completed' ORDER BY created_at DESC"
    );

    res.json({
      inProgress: inProgressRows.map(formatOT),
      completed: completedRows.map(formatOT)
    });
  } catch (error) {
    console.error('Error fetching OTs:', error);
    res.status(500).json({ error: error.message });
  }
});

// GET /api/next-folio - Get next available OT number from MySQL
app.get('/api/next-folio', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id FROM work_orders');
    let maxNum = 91;
    for (const r of rows) {
      const match = r.id.match(/OT-\d{4}-(\d+)/);
      if (match) {
        const n = parseInt(match[1], 10);
        if (n > maxNum) maxNum = n;
      }
    }
    const nextNum = maxNum + 1;
    const nextFolio = `OT-2026-${String(nextNum).padStart(3, '0')}`;
    res.json({ nextFolio });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/ots - Create a new work order in MySQL
app.post('/api/ots', async (req, res) => {
  try {
    const {
      id,
      client,
      material,
      quantityKg,
      deliveryDate,
      furnaceId,
      furnaceName,
      notes,
      color = 'orange'
    } = req.body;

    if (!id || !client || !material) {
      return res.status(400).json({ error: 'Faltan campos obligatorios (id, client, material)' });
    }

    await pool.query(
      `INSERT INTO work_orders (
        id, client, material, quantity_kg, delivery_date, furnace_id, furnace_name,
        status, progress, phase, remaining_minutes, color, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 'in_progress', 0, 'Carga inicial (0%)', 180, ?, ?)
      ON DUPLICATE KEY UPDATE client=VALUES(client), material=VALUES(material)`,
      [
        id,
        client,
        material,
        quantityKg || 1200,
        deliveryDate || '18 / Nov / 2026',
        furnaceId || 'horno-b',
        furnaceName || 'Horno B',
        color,
        notes || ''
      ]
    );

    // If assigned to furnace, update furnace status in MySQL
    if (furnaceId) {
      await pool.query(
        `UPDATE furnaces
         SET status = 'EN PROCESO', active_ot = ?, current_temp = 1550, enabled = 1
         WHERE id = ?`,
        [id, furnaceId]
      );
    }

    const [createdRows] = await pool.query('SELECT * FROM work_orders WHERE id = ?', [id]);
    res.status(201).json(formatOT(createdRows[0]));
  } catch (error) {
    console.error('Error creating OT:', error);
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/ots/:id/progress - Update progress and phase in MySQL
app.put('/api/ots/:id/progress', async (req, res) => {
  try {
    const { id } = req.params;
    const { progress, phase, remainingMinutes } = req.body;

    await pool.query(
      `UPDATE work_orders
       SET progress = ?, phase = ?, remaining_minutes = ?
       WHERE id = ?`,
      [progress, phase, remainingMinutes, id]
    );

    const [updatedRows] = await pool.query('SELECT * FROM work_orders WHERE id = ?', [id]);
    res.json(formatOT(updatedRows[0]));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/ots/:id/complete - Complete an OT in MySQL
app.put('/api/ots/:id/complete', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      completedDate = 'Hoy',
      realTime = '3h 30m (¡Éxito en tiempo!)',
      badge = 'LOGRADA EN TIEMPO Y FORMA'
    } = req.body;

    await pool.query(
      `UPDATE work_orders
       SET status = 'completed', progress = 100, phase = 'Colada Completa (100%)',
           remaining_minutes = 0, completed_date = ?, real_time = ?, badge = ?
       WHERE id = ?`,
      [completedDate, realTime, badge, id]
    );

    // Free up furnace
    const [rows] = await pool.query('SELECT * FROM work_orders WHERE id = ?', [id]);
    const ot = rows[0];
    if (ot && ot.furnace_id) {
      await pool.query(
        `UPDATE furnaces
         SET status = 'LIBRE', active_ot = NULL, current_temp = 1450
         WHERE id = ?`,
        [ot.furnace_id]
      );
    }

    res.json(formatOT(ot));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/furnaces - List furnaces from MySQL
app.get('/api/furnaces', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM furnaces ORDER BY id ASC');
    const formatted = rows.map((f) => ({
      id: f.id,
      name: f.name,
      capacity: f.capacity,
      capacityKg: Number(f.capacity_kg),
      status: f.status,
      currentTemp: Number(f.current_temp),
      targetTemp: Number(f.target_temp),
      activeOT: f.active_ot,
      material: f.material,
      enabled: Boolean(f.enabled)
    }));
    res.json(formatted);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/furnaces/:id - Update furnace in MySQL
app.put('/api/furnaces/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { status, activeOT, currentTemp, enabled } = req.body;

    await pool.query(
      `UPDATE furnaces
       SET status = COALESCE(?, status),
           active_ot = ?,
           current_temp = COALESCE(?, current_temp),
           enabled = COALESCE(?, enabled)
       WHERE id = ?`,
      [status, activeOT, currentTemp, enabled !== undefined ? (enabled ? 1 : 0) : null, id]
    );

    const [updatedRows] = await pool.query('SELECT * FROM furnaces WHERE id = ?', [id]);
    res.json(updatedRows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 SS Metal Foundry API Server running on port ${PORT} connected to MySQL database \`ssmf_db\``);
});
