import express from 'express';
import cors from 'cors';
import db from './db.js';

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
  progress: row.progress,
  phase: row.phase,
  remainingMinutes: row.remaining_minutes,
  client: row.client,
  quantityKg: row.quantity_kg,
  color: row.color,
  notes: row.notes,
  deliveryDate: row.delivery_date,
  badge: row.badge,
  completedDate: row.completed_date,
  estimatedTime: row.estimated_time,
  realTime: row.real_time,
  createdAt: row.created_at
});

// GET /api/ots - Retrieve all work orders categorized
app.get('/api/ots', (req, res) => {
  try {
    const inProgressRows = db
      .prepare("SELECT * FROM work_orders WHERE status = 'in_progress' ORDER BY created_at DESC")
      .all();
    const completedRows = db
      .prepare("SELECT * FROM work_orders WHERE status = 'completed' ORDER BY created_at DESC")
      .all();

    res.json({
      inProgress: inProgressRows.map(formatOT),
      completed: completedRows.map(formatOT)
    });
  } catch (error) {
    console.error('Error fetching OTs:', error);
    res.status(500).json({ error: error.message });
  }
});

// GET /api/next-folio - Get next available OT number
app.get('/api/next-folio', (req, res) => {
  try {
    const rows = db.prepare('SELECT id FROM work_orders').all();
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

// POST /api/ots - Create a new work order
app.post('/api/ots', (req, res) => {
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

    const insertStmt = db.prepare(`
      INSERT INTO work_orders (
        id, client, material, quantity_kg, delivery_date, furnace_id, furnace_name,
        status, progress, phase, remaining_minutes, color, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 'in_progress', 0, 'Carga inicial (0%)', 180, ?, ?)
    `);

    insertStmt.run(
      id,
      client,
      material,
      quantityKg || 1200,
      deliveryDate || '18 / Nov / 2026',
      furnaceId || 'horno-b',
      furnaceName || 'Horno B',
      color,
      notes || ''
    );

    // If assigned to furnace, update furnace status
    if (furnaceId) {
      db.prepare(`
        UPDATE furnaces
        SET status = 'EN PROCESO', active_ot = ?, current_temp = 1550, enabled = 1
        WHERE id = ?
      `).run(id, furnaceId);
    }

    const createdRow = db.prepare('SELECT * FROM work_orders WHERE id = ?').get(id);
    res.status(201).json(formatOT(createdRow));
  } catch (error) {
    console.error('Error creating OT:', error);
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/ots/:id/progress - Update progress and phase
app.put('/api/ots/:id/progress', (req, res) => {
  try {
    const { id } = req.params;
    const { progress, phase, remainingMinutes } = req.body;

    db.prepare(`
      UPDATE work_orders
      SET progress = ?, phase = ?, remaining_minutes = ?
      WHERE id = ?
    `).run(progress, phase, remainingMinutes, id);

    const updated = db.prepare('SELECT * FROM work_orders WHERE id = ?').get(id);
    res.json(formatOT(updated));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/ots/:id/complete - Complete an OT
app.put('/api/ots/:id/complete', (req, res) => {
  try {
    const { id } = req.params;
    const {
      completedDate = 'Hoy',
      realTime = '3h 30m (¡Éxito en tiempo!)',
      badge = 'LOGRADA EN TIEMPO Y FORMA'
    } = req.body;

    db.prepare(`
      UPDATE work_orders
      SET status = 'completed', progress = 100, phase = 'Colada Completa (100%)',
          remaining_minutes = 0, completed_date = ?, real_time = ?, badge = ?
      WHERE id = ?
    `).run(completedDate, realTime, badge, id);

    // Free up furnace
    const ot = db.prepare('SELECT * FROM work_orders WHERE id = ?').get(id);
    if (ot && ot.furnace_id) {
      db.prepare(`
        UPDATE furnaces
        SET status = 'LIBRE', active_ot = NULL, current_temp = 1450
        WHERE id = ?
      `).run(ot.furnace_id);
    }

    res.json(formatOT(ot));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/furnaces - List furnaces
app.get('/api/furnaces', (req, res) => {
  try {
    const rows = db.prepare('SELECT * FROM furnaces ORDER BY id ASC').all();
    const formatted = rows.map((f) => ({
      id: f.id,
      name: f.name,
      capacity: f.capacity,
      capacityKg: f.capacity_kg,
      status: f.status,
      currentTemp: f.current_temp,
      targetTemp: f.target_temp,
      activeOT: f.active_ot,
      material: f.material,
      enabled: Boolean(f.enabled)
    }));
    res.json(formatted);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/furnaces/:id - Update furnace
app.put('/api/furnaces/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { status, activeOT, currentTemp, enabled } = req.body;

    db.prepare(`
      UPDATE furnaces
      SET status = COALESCE(?, status),
          active_ot = ?,
          current_temp = COALESCE(?, current_temp),
          enabled = COALESCE(?, enabled)
      WHERE id = ?
    `).run(status, activeOT, currentTemp, enabled !== undefined ? (enabled ? 1 : 0) : null, id);

    const updated = db.prepare('SELECT * FROM furnaces WHERE id = ?').get(id);
    res.json(updated);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 SS Metal Foundry API Server running at http://localhost:${PORT}`);
});
