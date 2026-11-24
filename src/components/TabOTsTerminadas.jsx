import React, { useState } from 'react';
import { CheckCircle2, Flame, Award, FileText, History, Zap, Sparkles } from 'lucide-react';

export default function TabOTsTerminadas({
  completedOTs,
  onStartRecommendedOT,
  onOpenQualityModal,
  onOpenHistoryModal
}) {
  const [selectedOTId, setSelectedOTId] = useState('OT-2026-085');

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      {/* 3 Columns Layout matching the screenshot */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">

        {/* ================= COL 1: ÓRDENES DE TRABAJO (OTs) TERMINADAS ================= */}
        <div className="space-y-4">
          <h2 className="text-sm font-bold tracking-wider text-gray-200 uppercase flex items-center gap-2 border-b border-[#252b36] pb-2">
            Órdenes de Trabajo (OTs) Terminadas
          </h2>

          <div className="space-y-3.5">
            {completedOTs.map((ot) => {
              const isSelected = selectedOTId === ot.id;

              return (
                <div
                  key={ot.id}
                  onClick={() => setSelectedOTId(ot.id)}
                  className={`bg-[#181b20] border rounded-xl p-4 space-y-3 shadow-md cursor-pointer transition ${
                    isSelected
                      ? 'border-[#2e7d32] bg-[#1a211d] shadow-[0_0_15px_rgba(46,125,50,0.25)]'
                      : 'border-[#282e38] hover:border-[#3a4454]'
                  }`}
                >
                  {/* OT title & material */}
                  <div className="font-bold text-white text-sm tracking-wide">
                    {ot.id} ({ot.material})
                  </div>

                  {/* Green badge if active/top */}
                  {ot.badge && (
                    <div className="bg-[#1e3423] border border-[#2e7d32] text-green-400 text-xs font-bold px-3 py-1.5 rounded-full flex items-center gap-2 w-fit">
                      <CheckCircle2 className="w-4 h-4 text-green-400" />
                      <span>{ot.badge}</span>
                    </div>
                  )}

                  {/* Metadata */}
                  <div className="text-xs text-gray-300 space-y-1 pt-1 font-medium">
                    <div>Completada el: {ot.completedDate}</div>
                    {ot.estimatedTime && <div>Tiempo estimado: {ot.estimatedTime}</div>}
                    {ot.realTime && (
                      <div className="text-gray-200">
                        Tiempo real: <span className="text-green-400 font-semibold">{ot.realTime}</span>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* ================= COL 2: RECOMENDACIONES DE CONTINUIDAD ================= */}
        <div className="space-y-4">
          <h2 className="text-sm font-bold tracking-wider text-gray-200 uppercase flex items-center gap-2 border-b border-[#252b36] pb-2">
            Recomendaciones de Continuidad
          </h2>

          <div className="space-y-4">
            <p className="text-xs text-gray-300 leading-relaxed font-normal">
              Sugiere qué órdenes de trabajo pendientes arrancar a continuación para maximizar la eficiencia energética y la compatibilidad.
            </p>

            {/* Main Orange Glowing Recommendation Card */}
            <div className="bg-[#1f1a15] border-2 border-[#e65100] rounded-xl p-5 space-y-4 shadow-[0_0_18px_rgba(230,81,0,0.25)]">
              <div>
                <span className="text-xs text-gray-400 block mb-1">
                  Siguiente OT recomendada por el sistema:
                </span>
                <span className="text-sm font-bold text-white block">
                  OT-2026-092 (Acero al Carbón) para Horno A
                </span>
              </div>

              <p className="text-xs text-gray-300 leading-relaxed font-normal">
                El Horno A está caliente (1450°C) y libre tras la OT-2026-085. Iniciar esta orden <span className="text-orange-400 font-semibold">ahorrará 30% de energía</span> en recalentamiento y es compatible con el residuo del material anterior.
              </p>

              <button
                onClick={() => onStartRecommendedOT('OT-2026-092', 'horno-a')}
                className="w-full bg-gradient-to-r from-[#e65100] via-[#f57c00] to-[#e53935] hover:from-[#d84315] hover:to-[#d32f2f] text-white text-xs font-bold uppercase tracking-wider py-3 rounded-lg shadow-[0_4px_12px_rgba(245,124,0,0.4)] transition transform active:scale-98 flex items-center justify-center gap-2"
              >
                <Zap className="w-4 h-4 fill-white" />
                <span>INICIAR OT-2026-092</span>
              </button>
            </div>

            {/* Recommendation for Horno B */}
            <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-4 space-y-1 shadow-md">
              <span className="text-xs text-gray-400 block">
                Recomendación para Horno B:
              </span>
              <span className="text-xs font-bold text-gray-200 block">
                OT-2026-095 (Chatarra de Retorno)
              </span>
            </div>
          </div>
        </div>

        {/* ================= COL 3: MÉTRICAS DE DESEMPEÑO Y HISTÓRICO ================= */}
        <div className="space-y-4">
          <h2 className="text-sm font-bold tracking-wider text-gray-200 uppercase flex items-center gap-2 border-b border-[#252b36] pb-2">
            Métricas de Desempeño y Histórico
          </h2>

          <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-5 space-y-6 shadow-md">
            
            {/* Donut Chart section */}
            <div className="space-y-3">
              <h3 className="text-xs font-bold text-gray-300 uppercase tracking-wide">
                Efectividad de cumplimiento
              </h3>

              <div className="flex items-center gap-4">
                {/* SVG Donut Chart 94% */}
                <div className="relative w-24 h-24 shrink-0 flex items-center justify-center">
                  <svg className="w-full h-full transform -rotate-90" viewBox="0 0 36 36">
                    {/* Background circle */}
                    <path
                      className="text-[#2a313d]"
                      strokeWidth="4"
                      stroke="currentColor"
                      fill="none"
                      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    />
                    {/* Stroke filled 94% */}
                    <path
                      className="text-gray-300"
                      strokeDasharray="94, 100"
                      strokeWidth="4"
                      strokeLinecap="round"
                      stroke="currentColor"
                      fill="none"
                      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    />
                  </svg>
                </div>

                <div className="text-xs text-gray-200 leading-snug">
                  Efectividad de <strong className="text-white font-bold text-sm">94%</strong> a tiempo y en forma
                </div>
              </div>
            </div>

            {/* Quality Summary / Alertas */}
            <div className="space-y-2.5 pt-2 border-t border-[#252b36]">
              <h3 className="text-xs font-bold text-gray-300 uppercase tracking-wide">
                Alertas / Resumen de Calidad
              </h3>

              <ul className="text-xs space-y-2 text-gray-300">
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-red-500 shadow-[0_0_6px_rgba(239,68,68,0.8)]" />
                  <span>0 moldes porosos reportados hoy</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-orange-500 shadow-[0_0_6px_rgba(249,115,22,0.8)]" />
                  <span>3 de 3 OTs completadas en tiempo</span>
                </li>
              </ul>
            </div>

            {/* Red action buttons */}
            <div className="space-y-2.5 pt-4">
              <button
                onClick={onOpenQualityModal}
                className="w-full bg-[#d32f2f] hover:bg-[#b71c1c] text-white text-xs font-bold uppercase tracking-wider py-2.5 rounded-lg transition shadow-md flex items-center justify-center gap-2 active:scale-98"
              >
                <FileText className="w-4 h-4" />
                <span>VER REPORTES DE CALIDAD</span>
              </button>

              <button
                onClick={onOpenHistoryModal}
                className="w-full bg-[#d32f2f] hover:bg-[#b71c1c] text-white text-xs font-bold uppercase tracking-wider py-2.5 rounded-lg transition shadow-md flex items-center justify-center gap-2 active:scale-98"
              >
                <History className="w-4 h-4" />
                <span>HISTÓRICO COMPLETO</span>
              </button>
            </div>

          </div>
        </div>

      </div>
    </div>
  );
}
