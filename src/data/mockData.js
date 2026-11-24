export const initialFurnaces = [
  {
    id: 'horno-a',
    name: 'HORNO A',
    capacity: '1.5 Ton',
    capacityKg: 1500,
    status: 'EN PROCESO', // EN PROCESO, LIBRE, MANTENIMIENTO
    currentTemp: 1550,
    targetTemp: 1550,
    activeOT: 'OT-2026-087',
    material: 'Acero al Carbón',
    enabled: true,
    curveData: [350, 600, 950, 1200, 1380, 1490, 1540, 1550]
  },
  {
    id: 'horno-b',
    name: 'HORNO B',
    capacity: '1.8 Ton',
    capacityKg: 1800,
    status: 'LIBRE',
    currentTemp: 1450,
    targetTemp: 0,
    activeOT: null,
    material: 'Residual Acero al Carbón',
    enabled: true,
    curveData: [1520, 1500, 1480, 1465, 1455, 1450, 1445, 1440]
  },
  {
    id: 'horno-c',
    name: 'HORNO C',
    capacity: '2.0 Ton',
    capacityKg: 2000,
    status: 'MANTENIMIENTO',
    currentTemp: 85,
    targetTemp: 0,
    activeOT: null,
    material: 'Inactivo',
    enabled: false,
    curveData: [90, 88, 87, 86, 85, 85, 84, 85]
  }
];

export const initialActiveOTs = [
  {
    id: 'OT-2026-089',
    furnaceId: 'horno-a',
    furnaceName: 'Horno A',
    material: 'Acero al Carbón',
    progress: 85,
    phase: 'Fusión (85%)',
    remainingMinutes: 25,
    client: 'Maquinaria Industrial S.A.',
    quantityKg: 1200,
    color: 'orange'
  },
  {
    id: 'OT-2026-090',
    furnaceId: 'horno-b',
    furnaceName: 'Horno B',
    material: 'Acero al Carbón',
    progress: 75,
    phase: 'Fusión (85%)',
    remainingMinutes: 25,
    client: 'Aceros del Bajío S.A.',
    quantityKg: 1400,
    color: 'red'
  },
  {
    id: 'OT-2026-091',
    furnaceId: 'horno-a',
    furnaceName: 'Horno A',
    material: 'Acero al Carbón',
    progress: 85,
    phase: 'Fusión (85%)',
    remainingMinutes: 25,
    client: 'Estructuras Pesadas S.A.',
    quantityKg: 1100,
    color: 'red'
  }
];

export const initialCompletedOTs = [
  {
    id: 'OT-2026-085',
    material: 'Acero al Carbón',
    badge: 'LOGRADA EN TIEMPO Y FORMA',
    completedDate: '11/Nov/2026',
    estimatedTime: '4h',
    realTime: '3h 45m (¡Éxito en tiempo!)',
    furnace: 'Horno A',
    client: 'Maquinaria Industrial S.A.',
    quantityKg: 1350,
    porosityReported: 0
  },
  {
    id: 'OT-2026-084',
    material: 'Chatarra de Retorno',
    badge: 'ENTREGADA A TIEMPO Y EN FORMA',
    completedDate: '11/Nov/2026',
    estimatedTime: '3.5h',
    realTime: '3h 20m',
    furnace: 'Horno B',
    client: 'Metalmecánica del Norte',
    quantityKg: 950,
    porosityReported: 0
  },
  {
    id: 'OT-2026-082',
    material: 'Aleación Especial',
    badge: 'ENTREGADA A TIEMPO',
    completedDate: '10/Nov/2026',
    estimatedTime: '5h',
    realTime: '4h 50m',
    furnace: 'Horno C',
    client: 'Fundición Minera Integral',
    quantityKg: 1800,
    porosityReported: 0
  }
];

export const availableMaterials = [
  'Acero al Carbón',
  'Chatarra de Retorno',
  'Ferroaleaciones',
  'Aleación Especial',
  'Hierro Gris',
  'Hierro Nodular',
  'Acero Inoxidable 316'
];
