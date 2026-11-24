import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import TabAltaOT from './components/TabAltaOT';
import TabProcesoFundicion from './components/TabProcesoFundicion';
import TabOTsTerminadas from './components/TabOTsTerminadas';
import ModalReportes from './components/ModalReportes';
import { initialFurnaces, initialActiveOTs, initialCompletedOTs } from './data/mockData';

export default function App() {
  const [activeTab, setActiveTab] = useState('proceso'); // defaults to 'proceso' or can be switched
  const [furnaces, setFurnaces] = useState(initialFurnaces);
  const [activeOTs, setActiveOTs] = useState(initialActiveOTs);
  const [completedOTs, setCompletedOTs] = useState(initialCompletedOTs);
  const [nextOTCounter, setNextOTCounter] = useState(92);
  const [modalType, setModalType] = useState(null); // 'quality' | 'history' | null
  const [currentTime, setCurrentTime] = useState('');

  // Clock updater with format matching screenshots: DD/Mes/YYYY, HH:mm:ss
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

  // Handler: Generate new OT from Alta de OT form
  const handleGenerateOT = (newOT) => {
    setActiveOTs((prev) => [newOT, ...prev]);
    setNextOTCounter((prev) => prev + 1);

    // If assigned to a furnace, update furnace status
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

    // Automatically transition to 'proceso' tab after 1.2s to show the result
    setTimeout(() => {
      setActiveTab('proceso');
    }, 1200);
  };

  // Handler: Quick assign recommendation (e.g. OT-2026-090 to Horno B)
  const handleAssignRecommendation = (otId, furnaceId) => {
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

    alert(`¡OT ${otId} asignada exitosamente a Horno B aprovechando calor residual y optimizando energía!`);
  };

  // Handler: Start Recommended OT from Continuity tab (OT-2026-092 for Horno A)
  const handleStartRecommendedOT = (otId, furnaceId) => {
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

    setActiveTab('proceso');
  };

  // Handler: Advance OT progress
  const handleAdvanceOT = (otId) => {
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
            // Move to completed OTs
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

          return {
            ...ot,
            progress: newProgress,
            phase: newPhase,
            remainingMinutes: newRemaining
          };
        }
        return ot;
      });
    });
  };

  // Handler: Toggle furnace enabled/state
  const handleToggleFurnace = (furnaceId) => {
    setFurnaces((prev) =>
      prev.map((f) => {
        if (f.id === furnaceId) {
          const newEnabled = !f.enabled;
          return {
            ...f,
            enabled: newEnabled,
            status: newEnabled ? 'LIBRE' : 'MANTENIMIENTO'
          };
        }
        return f;
      })
    );
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
        {activeTab === 'alta' && (
          <TabAltaOT
            furnaces={furnaces}
            onGenerateOT={handleGenerateOT}
            nextOTNumber={`OT-2026-0${nextOTCounter}`}
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
        <div>
          <span>SSMF SS METAL FOUNDRY &copy; 2026</span>
          <span className="mx-2">•</span>
          <span>Planta Fundición de Aceros Especiales</span>
        </div>
        <div className="flex items-center gap-4">
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-green-500 inline-block"></span>
            Telemetría SCADA en línea
          </span>
          <span className="text-gray-400 font-mono">v2.4-PROD</span>
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
