import React from 'react';
import { Flame, Sliders, AlertTriangle, Play, CheckCircle, Clock } from 'lucide-react';

export default function TabProcesoFundicion({
  activeOTs,
  furnaces,
  onAssignRecommendation,
  onAdvanceOT,
  onToggleFurnace
}) {
  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      {/* 3 Columns Layout matching the screenshot */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* ================= COL 1: PROGRESO DE LAS ORDENES DE TRABAJO (OT) ================= */}
        <div className="space-y-4">
          <h2 className="text-sm font-bold tracking-wider text-gray-200 uppercase flex items-center gap-2 border-b border-[#252b36] pb-2">
            Progreso de las Ordenes de Trabajo (OT)
          </h2>

          <div className="space-y-3.5">
            {activeOTs.map((ot) => (
              <div
                key={ot.id}
                className="bg-[#181b20] border border-[#282e38] rounded-xl p-4 space-y-3 shadow-md hover:border-[#384252] transition"
              >
                {/* Header row: OT number and Furnace */}
                <div className="flex items-center justify-between">
                  <span className="font-bold text-white text-sm tracking-wide">
                    {ot.id}
                  </span>
                  <span className="text-xs text-gray-300 font-semibold bg-[#222731] px-2.5 py-0.5 rounded border border-[#2e3746]">
                    {ot.furnaceName}
                  </span>
                </div>

                {/* Material description */}
                <div className="text-xs text-gray-300 font-medium">
                  {ot.material}
                </div>

                {/* Progress bar with percentage */}
                <div className="space-y-1">
                  <div className="w-full bg-[#121418] rounded-full h-3.5 p-0.5 overflow-hidden border border-[#252a33]">
                    <div
                      className={`h-full rounded-full transition-all duration-500 flex items-center justify-end pr-1 text-[10px] font-bold text-white ${
                        ot.color === 'orange'
                          ? 'bg-gradient-to-r from-[#e65100] to-[#ff9800]'
                          : 'bg-gradient-to-r from-[#b71c1c] to-[#e53935]'
                      }`}
                      style={{ width: `${Math.max(15, ot.progress)}%` }}
                    >
                      {ot.progress}%
                    </div>
                  </div>
                </div>

                {/* Phase and Remaining Time */}
                <div className="flex items-center justify-between text-[11px] text-gray-400 font-medium pt-0.5">
                  <span>Fase: {ot.phase}</span>
                  <span className="flex items-center gap-1">
                    <Clock className="w-3 h-3 text-gray-400" />
                    Tiempo restante: {ot.remainingMinutes} min
                  </span>
                </div>

                {/* Interactive quick advance simulation button */}
                <div className="pt-1 flex justify-end">
                  <button
                    onClick={() => onAdvanceOT(ot.id)}
                    className="text-[11px] text-gray-400 hover:text-white bg-[#222731] hover:bg-[#2c3442] px-2 py-1 rounded transition border border-[#323b4b]"
                  >
                    Avanzar Colada (+10%)
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ================= COL 2: ESTADO DE LOS HORNOS ================= */}
        <div className="space-y-4">
          <h2 className="text-sm font-bold tracking-wider text-gray-200 uppercase flex items-center gap-2 border-b border-[#252b36] pb-2">
            Estado de los Hornos
          </h2>

          <div className="space-y-3.5">
            {furnaces.map((furnace) => {
              const isOccupied = furnace.status === 'EN PROCESO';
              const isFree = furnace.status === 'LIBRE';
              const isMaintenance = furnace.status === 'MANTENIMIENTO';

              return (
                <div
                  key={furnace.id}
                  className={`bg-[#181b20] border rounded-xl p-4 space-y-3 shadow-md relative overflow-hidden transition ${
                    isOccupied
                      ? 'border-l-4 border-l-[#e53935] border-t-[#282e38] border-r-[#282e38] border-b-[#282e38]'
                      : 'border-[#282e38]'
                  }`}
                >
                  {/* Furnace Header: Name and Toggle/Status Indicator */}
                  <div className="flex items-center justify-between">
                    <div className="font-bold text-white text-sm tracking-wide">
                      {furnace.name} ({furnace.capacity})
                    </div>
                    {isOccupied ? (
                      <span className="w-3.5 h-3.5 rounded-full bg-red-600 shadow-[0_0_8px_rgba(239,68,68,1)] animate-ping" />
                    ) : (
                      <button
                        onClick={() => onToggleFurnace(furnace.id)}
                        className={`w-9 h-5 rounded-full p-0.5 transition-colors duration-200 flex items-center ${
                          furnace.enabled
                            ? 'bg-[#f57c00] justify-end'
                            : 'bg-[#2c333f] justify-start'
                        }`}
                      >
                        <div className="w-4 h-4 rounded-full bg-white shadow-sm" />
                      </button>
                    )}
                  </div>

                  {/* Active OT if any */}
                  {furnace.activeOT && (
                    <div className="text-xs text-gray-300 font-mono">
                      {furnace.activeOT}
                    </div>
                  )}

                  {/* Status Badge */}
                  <div>
                    {isOccupied && (
                      <span className="inline-block bg-[#3a1b1b] text-red-400 text-[10px] font-bold px-2 py-0.5 rounded border border-red-900 tracking-wider">
                        EN PROCESO
                      </span>
                    )}
                    {isFree && (
                      <span className="inline-block bg-[#332213] text-orange-400 text-[10px] font-bold px-2 py-0.5 rounded border border-orange-900 tracking-wider">
                        LIBRE
                      </span>
                    )}
                    {isMaintenance && (
                      <span className="inline-block bg-[#222731] text-gray-400 text-[10px] font-bold px-2 py-0.5 rounded border border-gray-700 tracking-wider">
                        MANTENIMIENTO
                      </span>
                    )}
                  </div>

                  {/* Capacity & Live Temperature Curve */}
                  <div className="flex items-end justify-between pt-1">
                    <div className="text-xs text-gray-300 font-semibold flex items-center gap-1.5">
                      <span className="text-gray-400">⚖️</span>
                      <span>{furnace.capacity}</span>
                    </div>

                    {/* SVG Temperature Curve Graph */}
                    <div className="flex items-center gap-2">
                      <div className="w-32 h-14 bg-[#121418] border border-[#252b36] rounded p-1 relative overflow-hidden">
                        {isOccupied && (
                          <svg className="w-full h-full overflow-visible" viewBox="0 0 100 40">
                            <defs>
                              <linearGradient id={`grad-${furnace.id}`} x1="0" y1="0" x2="0" y2="1">
                                <stop offset="0%" stopColor="#e53935" stopOpacity="0.5" />
                                <stop offset="100%" stopColor="#e53935" stopOpacity="0.0" />
                              </linearGradient>
                            </defs>
                            <path
                              d="M 0 35 Q 30 35, 50 15 T 100 5 L 100 40 L 0 40 Z"
                              fill={`url(#grad-${furnace.id})`}
                            />
                            <path
                              d="M 0 35 Q 30 35, 50 15 T 100 5"
                              fill="none"
                              stroke="#e53935"
                              strokeWidth="2"
                            />
                            <circle cx="100" cy="5" r="3" fill="#ff5252" className="animate-pulse" />
                          </svg>
                        )}
                        {isFree && (
                          <svg className="w-full h-full overflow-visible" viewBox="0 0 100 40">
                            <defs>
                              <linearGradient id={`grad-free-${furnace.id}`} x1="0" y1="0" x2="0" y2="1">
                                <stop offset="0%" stopColor="#f57c00" stopOpacity="0.4" />
                                <stop offset="100%" stopColor="#f57c00" stopOpacity="0.0" />
                              </linearGradient>
                            </defs>
                            <path
                              d="M 0 12 L 30 14 L 60 17 L 100 20 L 100 40 L 0 40 Z"
                              fill={`url(#grad-free-${furnace.id})`}
                            />
                            <path
                              d="M 0 12 L 30 14 L 60 17 L 100 20"
                              fill="none"
                              stroke="#f57c00"
                              strokeWidth="2"
                            />
                          </svg>
                        )}
                        {isMaintenance && (
                          <div className="h-full flex items-center justify-center text-[10px] text-gray-500 font-mono">
                            STANDBY (85°C)
                          </div>
                        )}
                      </div>
                      <span className="text-xs font-bold text-gray-200 font-mono min-w-[55px]">
                        {furnace.currentTemp}°C
                      </span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* ================= COL 3: ASISTENTE DE RECOMENDACIONES Y ALERTAS ================= */}
        <div className="space-y-4">
          <h2 className="text-sm font-bold tracking-wider text-gray-200 uppercase flex items-center gap-2 border-b border-[#252b36] pb-2">
            Asistente de Recomendaciones y Alertas (Lógica de Fundición)
          </h2>

          <div className="space-y-4">
            {/* Box 1: Siguiente OT Recomendada */}
            <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-4 space-y-3 shadow-md">
              <div className="flex items-center justify-between text-gray-200">
                <span className="font-bold text-xs uppercase tracking-wide">
                  Siguiente OT Recomendada
                </span>
                <Sliders className="w-4 h-4 text-orange-400" />
              </div>
              <p className="text-xs text-gray-400">
                Sugerencias automáticas de OTs iniciar:
              </p>

              {/* Orange recommendation card */}
              <div className="bg-[#211a14] border border-[#e65100] rounded-lg p-3.5 space-y-3 shadow-[0_0_12px_rgba(230,81,0,0.2)]">
                <p className="text-xs text-gray-200 leading-relaxed font-medium">
                  <strong className="text-orange-400">RECOMENDADA:</strong> OT-2026-090 (Material: Acero al Carbón en Horno B) - Optimiza temperatura residual y compatibilidad.
                </p>

                <div className="flex items-center justify-between pt-1">
                  <span className="text-[11px] text-gray-400">Asignar a acción rápida:</span>
                  <button
                    onClick={() => onAssignRecommendation('OT-2026-090', 'horno-b')}
                    className="bg-gradient-to-r from-[#d32f2f] to-[#e53935] hover:from-[#b71c1c] hover:to-[#d32f2f] text-white text-xs font-bold px-3 py-1.5 rounded transition shadow-md active:scale-95"
                  >
                    Asignar a Horno B
                  </button>
                </div>
              </div>
            </div>

            {/* Box 2: Alertas de Incompatibilidad (Prevención de porosidad) */}
            <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-4 space-y-3 shadow-md">
              <div className="text-xs font-bold text-gray-200 uppercase tracking-wide">
                Alertas de Incompatibilidad (Prevención de porosidad)
              </div>

              {/* Red warning alert card */}
              <div className="bg-[#261616] border border-[#b71c1c] rounded-lg p-3.5 space-y-2 shadow-[0_0_15px_rgba(183,28,28,0.25)]">
                <div className="flex items-start gap-2">
                  <AlertTriangle className="w-4 h-4 text-red-400 shrink-0 mt-0.5" />
                  <div className="text-xs text-gray-200 leading-relaxed">
                    <strong className="text-red-400">ALERTA:</strong> No programar OT-2026-091 (Aleación especial) en Horno B inmediatamente después de acero. Riesgo de contaminación y moldes porosos. Se requiere limpieza o cambio de horno.
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  );
}
