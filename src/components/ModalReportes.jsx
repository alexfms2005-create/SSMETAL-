import React from 'react';
import { X, CheckCircle, ShieldCheck, Download, Printer, AlertTriangle } from 'lucide-react';

export default function ModalReportes({ type, isOpen, onClose }) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/75 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-[#181b20] border border-[#2e3644] w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden animate-fade-in text-gray-200">
        
        {/* Header */}
        <div className="bg-[#13151a] px-6 py-4 border-b border-[#252a33] flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            {type === 'quality' ? (
              <ShieldCheck className="w-5 h-5 text-green-400" />
            ) : (
              <ShieldCheck className="w-5 h-5 text-red-400" />
            )}
            <h3 className="font-bold text-white text-base tracking-wide">
              {type === 'quality'
                ? 'Reporte Integral de Calidad Metalúrgica'
                : 'Histórico Completo de Producción y Coladas'}
            </h3>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white p-1 rounded-lg hover:bg-[#252a33] transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-5 max-h-[70vh] overflow-y-auto">
          {type === 'quality' ? (
            <>
              <div className="grid grid-cols-3 gap-3">
                <div className="bg-[#1e2229] border border-[#2d3440] p-3 rounded-lg text-center">
                  <div className="text-xl font-bold text-green-400">0</div>
                  <div className="text-[11px] text-gray-400">Moldes Porosos</div>
                </div>
                <div className="bg-[#1e2229] border border-[#2d3440] p-3 rounded-lg text-center">
                  <div className="text-xl font-bold text-white">99.2%</div>
                  <div className="text-[11px] text-gray-400">Pureza Espectral</div>
                </div>
                <div className="bg-[#1e2229] border border-[#2d3440] p-3 rounded-lg text-center">
                  <div className="text-xl font-bold text-orange-400">1550°C</div>
                  <div className="text-[11px] text-gray-400">Promedio Vaciado</div>
                </div>
              </div>

              <div className="space-y-2">
                <h4 className="text-xs font-bold uppercase tracking-wider text-gray-300">
                  Ensayos de Espectrometría y Dureza
                </h4>
                <div className="bg-[#13161c] border border-[#262c36] rounded-lg overflow-hidden text-xs">
                  <table className="w-full text-left">
                    <thead className="bg-[#1a1d24] text-gray-400 border-b border-[#262c36]">
                      <tr>
                        <th className="p-2.5">OT</th>
                        <th className="p-2.5">Material</th>
                        <th className="p-2.5">Carbono (C)</th>
                        <th className="p-2.5">Silicio (Si)</th>
                        <th className="p-2.5">Dictamen</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-[#232934] text-gray-300">
                      <tr>
                        <td className="p-2.5 font-mono text-white">OT-2026-085</td>
                        <td className="p-2.5">Acero al Carbón</td>
                        <td className="p-2.5">0.24%</td>
                        <td className="p-2.5">0.38%</td>
                        <td className="p-2.5 text-green-400 font-semibold">Aprobado ✓</td>
                      </tr>
                      <tr>
                        <td className="p-2.5 font-mono text-white">OT-2026-084</td>
                        <td className="p-2.5">Chatarra Retorno</td>
                        <td className="p-2.5">0.28%</td>
                        <td className="p-2.5">0.42%</td>
                        <td className="p-2.5 text-green-400 font-semibold">Aprobado ✓</td>
                      </tr>
                      <tr>
                        <td className="p-2.5 font-mono text-white">OT-2026-082</td>
                        <td className="p-2.5">Aleación Especial</td>
                        <td className="p-2.5">0.18%</td>
                        <td className="p-2.5">0.55%</td>
                        <td className="p-2.5 text-green-400 font-semibold">Aprobado ✓</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </>
          ) : (
            <div className="space-y-3">
              <div className="bg-[#13161c] border border-[#262c36] rounded-lg overflow-hidden text-xs">
                <table className="w-full text-left">
                  <thead className="bg-[#1a1d24] text-gray-400 border-b border-[#262c36]">
                    <tr>
                      <th className="p-2.5">Folio OT</th>
                      <th className="p-2.5">Cliente</th>
                      <th className="p-2.5">Horno</th>
                      <th className="p-2.5">Material</th>
                      <th className="p-2.5">Duración</th>
                      <th className="p-2.5">Estado</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-[#232934] text-gray-300">
                    <tr>
                      <td className="p-2.5 font-mono text-white">OT-2026-085</td>
                      <td className="p-2.5">Maquinaria Industrial S.A.</td>
                      <td className="p-2.5">Horno A</td>
                      <td className="p-2.5">Acero al Carbón</td>
                      <td className="p-2.5">3h 45m</td>
                      <td className="p-2.5 text-green-400 font-semibold">A Tiempo</td>
                    </tr>
                    <tr>
                      <td className="p-2.5 font-mono text-white">OT-2026-084</td>
                      <td className="p-2.5">Metalmecánica del Norte</td>
                      <td className="p-2.5">Horno B</td>
                      <td className="p-2.5">Chatarra Retorno</td>
                      <td className="p-2.5">3h 20m</td>
                      <td className="p-2.5 text-green-400 font-semibold">A Tiempo</td>
                    </tr>
                    <tr>
                      <td className="p-2.5 font-mono text-white">OT-2026-082</td>
                      <td className="p-2.5">Fundición Minera Integral</td>
                      <td className="p-2.5">Horno C</td>
                      <td className="p-2.5">Aleación Especial</td>
                      <td className="p-2.5">4h 50m</td>
                      <td className="p-2.5 text-green-400 font-semibold">A Tiempo</td>
                    </tr>
                    <tr>
                      <td className="p-2.5 font-mono text-white">OT-2026-080</td>
                      <td className="p-2.5">Aceros y Perfiles MX</td>
                      <td className="p-2.5">Horno A</td>
                      <td className="p-2.5">Hierro Gris</td>
                      <td className="p-2.5">4h 10m</td>
                      <td className="p-2.5 text-green-400 font-semibold">A Tiempo</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="bg-[#13151a] px-6 py-3 border-t border-[#252a33] flex items-center justify-between">
          <span className="text-xs text-gray-500 font-mono">SSMF Sistema de Trazabilidad 2026</span>
          <div className="flex gap-2">
            <button
              onClick={() => alert('Exportando reporte en formato PDF...')}
              className="bg-[#252b36] hover:bg-[#323947] text-gray-200 text-xs px-3 py-1.5 rounded-lg flex items-center gap-1.5 transition border border-[#3b4455]"
            >
              <Download className="w-3.5 h-3.5" />
              <span>Exportar</span>
            </button>
            <button
              onClick={onClose}
              className="bg-[#e53935] hover:bg-[#c62828] text-white text-xs px-4 py-1.5 rounded-lg font-semibold transition"
            >
              Cerrar
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}
