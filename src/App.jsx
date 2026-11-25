import React, { useState, useEffect, useCallback } from 'react';
import Header from './components/Header';
import TabPrioridades from './components/TabPrioridades';
import TabAltaOT from './components/TabAltaOT';
import TabProcesoFundicion from './components/TabProcesoFundicion';
import TabOTsTerminadas from './components/TabOTsTerminadas';
import ModalReportes from './components/ModalReportes';
import { initialFurnaces, initialActiveOTs, initialCompletedOTs } from './data/mockData';

export default function App() {
  const [activeTab, setActiveTab] = useState('prioridades');
  const [prefilledOTData, setPrefilledOTData] = useState(null);
  const [furnaces, setFurnaces] = useState(initialFurnaces);
  const [activeOTs, setActiveOTs] = useState(initialActiveOTs);
  const [completedOTs, setCompletedOTs] = useState(initialCompletedOTs);
  const [nextOTFolio, setNextOTFolio] = useState('OT-2026-092');
  const [modalType, setModalType] = useState(null);
  const [currentTime, setCurrentTime] = useState('');
  const [dbConnected, setDbConnected] = useState(false);

  // Fetch all data from SQLite database API
  const loadDatabaseData = useCallback(async () => {
    try {
      const [otsRes, furnacesRes, folioRes] = await Promise.all([
        fetch('/api/ots').catch(() => null),
        fetch('/api/furnaces').catch(() => null),
        fetch('/api/next-folio').catch(() => null)
      ]);

      if (otsRes && otsRes.ok) {
        const otsData = await otsRes.json();
        if (otsData.inProgress && otsData.completed) {
          setActiveOTs(otsData.inProgress);
          setCompletedOTs(otsData.completed);
          setDbConnected(true);
        }
      }

      if (furnacesRes && furnacesRes.ok) {
        const furnacesData = await furnacesRes.json();
        if (Array.isArray(furnacesData) && furnacesData.length > 0) {
          setFurnaces(furnacesData);
        }
      }

      if (folioRes && folioRes.ok) {
        const folioData = await folioRes.json();
        if (folioData.nextFolio) {
          setNextOTFolio(folioData.nextFolio);
        }
      }
    } catch (err) {
      console.warn('Working in local mode (API offline):', err);
    }
  }, []);

  useEffect(() => {
    loadDatabaseData();
  }, [loadDatabaseData]);

  // Real-time clock updater
  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      const day = String(now.getDate()).padStart(2, '0');
      const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      const month = months[now.getMonth()];
      const year = now.getFullYear();
      const hours = String(now.getHours()).padStart(2, '0');
      const minutes = String(now.getMinutes()).padStart(2, '0');
      const seconds = String(now.getSeconds()).padStart(2, '0');
      setCurrentTime(`${day}/${month}/${year}, ${hours}:${minutes}:${seconds}`);
    };

    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  // Handler: Generate new OT and persist to SQLite Database
  const handleGenerateOT = async (newOT) => {
    // Optimistic UI update
    setActiveOTs((prev) => [newOT, ...prev]);

    // Update furnace
    setFurnaces((prev) =>
      prev.map((f) => {
        if (f.id === newOT.furnaceId) {
          return {
            ...f,
            status: 'EN PROCESO',
            activeOT: newOT.id,
            currentTemp: 1550,
            enabled: true
          };
        }
        return f;
      })
    );

    // Persist to SQLite Database via POST /api/ots
    try {
      const res = await fetch('/api/ots', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newOT)
      });

      if (res.ok) {
        // Refresh folio and data
        loadDatabaseData();
      }
    } catch (err) {
      console.error('Error saving OT to database:', err);
    }

    // Automatically transition to 'proceso' tab
    setTimeout(() => {
      setActiveTab('proceso');
    }, 1200);
  };

  // Handler: Quick assign recommendation (e.g. OT-2026-090 to Horno B)
  const handleAssignRecommendation = async (otId, furnaceId) => {
    setActiveOTs((prev) =>
      prev.map((ot) => {
        if (ot.id === otId) {
          return {
            ...ot,
            furnaceId: furnaceId,
            furnaceName: 'Horno B',
            progress: 80,
            phase: 'Fusión iniciada (80%)'
          };
        }
        return ot;
      })
    );

    setFurnaces((prev) =>
      prev.map((f) => {
        if (f.id === furnaceId) {
          return {
            ...f,
            status: 'EN PROCESO',
            activeOT: otId,
            currentTemp: 1510
          };
        }
        return f;
      })
    );

    try {
      await fetch(`/api/ots/${otId}/progress`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ progress: 80, phase: 'Fusión iniciada (80%)', remainingMinutes: 20 })
      });
      await fetch(`/api/furnaces/${furnaceId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'EN PROCESO', activeOT: otId, currentTemp: 1510 })
      });
    } catch (err) {
      console.warn('Sync error:', err);
    }

    alert(`¡OT ${otId} asignada exitosamente a Horno B aprovechando calor residual y optimizando energía!`);
  };

  // Handler: Start Recommended OT from Continuity tab (OT-2026-092 for Horno A)
  const handleStartRecommendedOT = async (otId, furnaceId) => {
    const newOT = {
      id: otId,
      furnaceId: furnaceId,
      furnaceName: 'Horno A',
      material: 'Acero al Carbón',
      progress: 20,
      phase: 'Carga caliente (20%)',
      remainingMinutes: 110,
      client: 'Maquinaria Industrial S.A.',
      quantityKg: 1300,
      color: 'orange'
    };

    setActiveOTs((prev) => [newOT, ...prev]);
    setFurnaces((prev) =>
      prev.map((f) => {
        if (f.id === furnaceId) {
          return {
            ...f,
            status: 'EN PROCESO',
            activeOT: otId,
            currentTemp: 1480
          };
        }
        return f;
      })
    );

    try {
      await fetch('/api/ots', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newOT)
      });
    } catch (err) {
      console.warn('Database save error:', err);
    }

    setActiveTab('proceso');
  };

  // Handler: Advance OT progress with DB sync
  const handleAdvanceOT = async (otId) => {
    let updatedOT = null;
    let isCompleted = false;

    setActiveOTs((prev) => {
      return prev.map((ot) => {
        if (ot.id === otId) {
          const newProgress = Math.min(100, ot.progress + 10);
          let newPhase = ot.phase;
          let newRemaining = Math.max(0, ot.remainingMinutes - 10);

          if (newProgress >= 90 && newProgress < 100) {
            newPhase = 'Vaciado a Crisol (90%)';
            newRemaining = 10;
          } else if (newProgress >= 100) {
            newPhase = 'Colada Completa (100%)';
            newRemaining = 0;
            isCompleted = true;

            setTimeout(() => {
              setCompletedOTs((comp) => [
                {
                  id: ot.id,
                  material: ot.material,
                  badge: 'LOGRADA EN TIEMPO Y FORMA',
                  completedDate: 'Hoy',
                  estimatedTime: '3.8h',
                  realTime: '3h 30m (¡Éxito en tiempo!)',
                  furnace: ot.furnaceName,
                  client: ot.client,
                  quantityKg: ot.quantityKg,
                  porosityReported: 0
                },
                ...comp
              ]);
              setActiveOTs((active) => active.filter((item) => item.id !== ot.id));
            }, 600);
          } else {
            newPhase = `Fusión (${newProgress}%)`;
          }

          updatedOT = {
            ...ot,
            progress: newProgress,
            phase: newPhase,
            remainingMinutes: newRemaining
          };
          return updatedOT;
        }
        return ot;
      });
    });

    // Sync to SQLite Database
    try {
      if (isCompleted) {
        await fetch(`/api/ots/${otId}/complete`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            completedDate: 'Hoy',
            realTime: '3h 30m (¡Éxito en tiempo!)',
            badge: 'LOGRADA EN TIEMPO Y FORMA'
          })
        });
      } else if (updatedOT) {
        await fetch(`/api/ots/${otId}/progress`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            progress: updatedOT.progress,
            phase: updatedOT.phase,
            remainingMinutes: updatedOT.remainingMinutes
          })
        });
      }
    } catch (err) {
      console.warn('Database sync error:', err);
    }
  };

  // Handler: Toggle furnace enabled/state
  const handleToggleFurnace = async (furnaceId) => {
    let nextEnabled = true;
    let nextStatus = 'LIBRE';

    setFurnaces((prev) =>
      prev.map((f) => {
        if (f.id === furnaceId) {
          nextEnabled = !f.enabled;
          nextStatus = nextEnabled ? 'LIBRE' : 'MANTENIMIENTO';
          return {
            ...f,
            enabled: nextEnabled,
            status: nextStatus
          };
        }
        return f;
      })
    );

    try {
      await fetch(`/api/furnaces/${furnaceId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ enabled: nextEnabled, status: nextStatus })
      });
    } catch (err) {
      console.warn('Sync furnace error:', err);
    }
  };

  // Handler: Pre-fill OT form from Backlog / Prioridades row
  const handleSelectForOT = (item) => {
    setPrefilledOTData({
      client: item.cliente,
      material: item.material,
      quantityKg: item.porFundir > 0 ? item.porFundir : (item.porPedido || 1000),
      notes: `Importado de Backlog (${item.semanaTitle || 'Semana'}). OC Externa: ${item.ocExterna || 'N/A'}, OC Interna: ${item.ocInterna || 'N/A'}. Pieza: ${item.descripcion}. Cantidad: ${item.cant} ${item.un}. Cód: ${item.codInterno || 'N/A'}. Estatus: ${item.estatus || 'N/A'}.`
    });
    setActiveTab('alta');
  };

  return (
    <div className="min-h-screen bg-[#111317] text-gray-200 flex flex-col font-sans">
      {/* Top Header */}
      <Header
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        currentTime={currentTime}
      />

      {/* Main Tab Views */}
      <main className="flex-1 overflow-x-hidden">
        {activeTab === 'prioridades' && (
          <TabPrioridades onSelectForOT={handleSelectForOT} />
        )}

        {activeTab === 'alta' && (
          <TabAltaOT
            furnaces={furnaces}
            onGenerateOT={handleGenerateOT}
            nextOTNumber={nextOTFolio}
            prefilledData={prefilledOTData}
          />
        )}

        {activeTab === 'proceso' && (
          <TabProcesoFundicion
            activeOTs={activeOTs}
            furnaces={furnaces}
            onAssignRecommendation={handleAssignRecommendation}
            onAdvanceOT={handleAdvanceOT}
            onToggleFurnace={handleToggleFurnace}
          />
        )}

        {activeTab === 'terminadas' && (
          <TabOTsTerminadas
            completedOTs={completedOTs}
            onStartRecommendedOT={handleStartRecommendedOT}
            onOpenQualityModal={() => setModalType('quality')}
            onOpenHistoryModal={() => setModalType('history')}
          />
        )}
      </main>

      {/* Footer bar */}
      <footer className="bg-[#0e1014] border-t border-[#1e232b] px-6 py-2 text-[11px] text-gray-500 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span>SSMF SS METAL FOUNDRY &copy; 2026</span>
          <span className="mx-2">•</span>
          <span>Planta Fundición de Aceros Especiales</span>
          <span className="mx-2">•</span>
          <span className="flex items-center gap-1 text-gray-400">
            <span className={`w-2 h-2 rounded-full ${dbConnected ? 'bg-green-500 shadow-[0_0_6px_rgba(34,197,94,0.8)]' : 'bg-orange-500'}`} />
            Base de Datos MySQL: <strong className={dbConnected ? 'text-green-400 font-normal' : 'text-orange-400 font-normal'}>{dbConnected ? 'Conectada (ssmf_db)' : 'En espera'}</strong>
          </span>
        </div>
        <div className="flex items-center gap-4">
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-green-500 inline-block"></span>
            Telemetría SCADA en línea
          </span>
          <span className="text-gray-400 font-mono">v2.5-PROD</span>
        </div>
      </footer>

      {/* Modal for Reports / History */}
      <ModalReportes
        type={modalType}
        isOpen={Boolean(modalType)}
        onClose={() => setModalType(null)}
      />
    </div>
  );
}
