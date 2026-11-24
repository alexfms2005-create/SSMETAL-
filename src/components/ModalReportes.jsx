import React, { useState } from 'react';
import { X, ShieldCheck, Download, Printer, FileSpreadsheet, FileText, CheckCircle2 } from 'lucide-react';

export default function ModalReportes({ type, isOpen, onClose }) {
  if (!isOpen) return null;

  const [downloadSuccess, setDownloadSuccess] = useState(false);

  // Quality report data
  const qualityData = [
    { ot: 'OT-2026-085', client: 'Maquinaria Industrial S.A.', material: 'Acero al Carbón', c: '0.24%', si: '0.38%', mn: '0.65%', p: '0.015%', s: '0.012%', status: 'Aprobado' },
    { ot: 'OT-2026-084', client: 'Metalmecánica del Norte', material: 'Chatarra Retorno', c: '0.28%', si: '0.42%', mn: '0.70%', p: '0.018%', s: '0.014%', status: 'Aprobado' },
    { ot: 'OT-2026-082', client: 'Fundición Minera Integral', material: 'Aleación Especial', c: '0.18%', si: '0.55%', mn: '0.80%', p: '0.010%', s: '0.008%', status: 'Aprobado' }
  ];

  // Production history data
  const historyData = [
    { ot: 'OT-2026-085', client: 'Maquinaria Industrial S.A.', furnace: 'Horno A', material: 'Acero al Carbón', time: '3h 45m', status: 'A Tiempo' },
    { ot: 'OT-2026-084', client: 'Metalmecánica del Norte', furnace: 'Horno B', material: 'Chatarra Retorno', time: '3h 20m', status: 'A Tiempo' },
    { ot: 'OT-2026-082', client: 'Fundición Minera Integral', furnace: 'Horno C', material: 'Aleación Especial', time: '4h 50m', status: 'A Tiempo' },
    { ot: 'OT-2026-080', client: 'Aceros y Perfiles MX', furnace: 'Horno A', material: 'Hierro Gris', time: '4h 10m', status: 'A Tiempo' }
  ];

  // 1. Download as CSV / Excel
  const handleDownloadCSV = () => {
    let csvContent = '';
    let fileName = '';

    if (type === 'quality') {
      fileName = 'SSMF_Reporte_Calidad_Metalurgica.csv';
      csvContent = 'Folio OT,Cliente,Material,Carbono (C),Silicio (Si),Manganeso (Mn),Fosforo (P),Azufre (S),Dictamen\n';
      qualityData.forEach((row) => {
        csvContent += `"${row.ot}","${row.client}","${row.material}","${row.c}","${row.si}","${row.mn}","${row.p}","${row.s}","${row.status}"\n`;
      });
    } else {
      fileName = 'SSMF_Historico_Produccion_Coladas.csv';
      csvContent = 'Folio OT,Cliente,Horno,Material,Duracion,Estado\n';
      historyData.forEach((row) => {
        csvContent += `"${row.ot}","${row.client}","${row.furnace}","${row.material}","${row.time}","${row.status}"\n`;
      });
    }

    // Blob with UTF-8 BOM for Excel compatibility
    const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);

    setDownloadSuccess(true);
    setTimeout(() => setDownloadSuccess(false), 3000);
  };

  // 2. Download / Print PDF with official company letterhead
  const handleDownloadPDF = () => {
    const isQuality = type === 'quality';
    const title = isQuality
      ? 'REPORTE INTEGRAL DE CALIDAD METALÚRGICA Y ESPECTROMETRÍA'
      : 'HISTÓRICO COMPLETO DE PRODUCCIÓN Y COLADAS';

    const printWindow = window.open('', '_blank');
    if (!printWindow) {
      alert('Por favor permita las ventanas emergentes para generar el PDF');
      return;
    }

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <title>${title} - SSMF 2026</title>
        <style>
          @page { size: A4; margin: 15mm; }
          body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; color: #1f2937; margin: 0; padding: 20px; font-size: 13px; line-height: 1.5; }
          .header { border-bottom: 3px solid #dc2626; padding-bottom: 12px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: flex-end; }
          .logo-box { font-size: 24px; font-weight: 800; color: #dc2626; letter-spacing: 1px; }
          .company-sub { font-size: 11px; color: #6b7280; font-weight: 600; text-transform: uppercase; }
          .meta-box { text-align: right; font-size: 11px; color: #4b5563; }
          .title { font-size: 16px; font-weight: 800; text-transform: uppercase; color: #111827; margin: 15px 0 10px; }
          .kpi-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 20px; }
          .kpi-card { border: 1px solid #e5e7eb; border-radius: 6px; padding: 10px; text-align: center; background: #f9fafb; }
          .kpi-val { font-size: 20px; font-weight: bold; color: #dc2626; }
          .kpi-lbl { font-size: 10px; color: #6b7280; text-transform: uppercase; }
          table { width: 100%; border-collapse: collapse; margin-top: 10px; }
          th { background: #f3f4f6; color: #374151; font-weight: 700; text-transform: uppercase; font-size: 11px; padding: 8px 10px; border: 1px solid #e5e7eb; text-align: left; }
          td { padding: 8px 10px; border: 1px solid #e5e7eb; font-size: 12px; }
          .status-ok { color: #15803d; font-weight: bold; }
          .footer { margin-top: 40px; border-top: 1px solid #e5e7eb; padding-top: 15px; display: flex; justify-content: space-between; font-size: 10px; color: #9ca3af; }
          .signature { margin-top: 50px; display: flex; justify-content: space-around; text-align: center; }
          .sign-line { width: 200px; border-top: 1px solid #374151; padding-top: 5px; font-size: 11px; font-weight: 600; }
        </style>
      </head>
      <body>
        <div class="header">
          <div>
            <div class="logo-box">SSMF • SS METAL FOUNDRY</div>
            <div class="company-sub">Planta Fundición de Aceros Especiales • División Control de Calidad</div>
          </div>
          <div class="meta-box">
            <div><strong>Fecha:</strong> ${new Date().toLocaleDateString('es-MX')}</div>
            <div><strong>Folio Reporte:</strong> RPT-2026-${Math.floor(1000 + Math.random() * 9000)}</div>
            <div><strong>Certificación:</strong> ISO 9001:2015 / ASTM A216</div>
          </div>
        </div>

        <div class="title">${title}</div>

        ${isQuality ? `
          <div class="kpi-grid">
            <div class="kpi-card">
              <div class="kpi-val" style="color: #16a34a;">0</div>
              <div class="kpi-lbl">Moldes Porosos Reportados</div>
            </div>
            <div class="kpi-card">
              <div class="kpi-val">99.2%</div>
              <div class="kpi-lbl">Pureza Espectral Promedio</div>
            </div>
            <div class="kpi-card">
              <div class="kpi-val" style="color: #ea580c;">1550°C</div>
              <div class="kpi-lbl">Temperatura de Vaciado</div>
            </div>
          </div>

          <p style="font-size: 12px; color: #4b5563; margin-bottom: 15px;">
            Resultados de análisis químico por espectrometría de emisión óptica y control de solidificación de las órdenes completadas.
          </p>

          <table>
            <thead>
              <tr>
                <th>OT</th>
                <th>Cliente</th>
                <th>Material</th>
                <th>Carbono (C)</th>
                <th>Silicio (Si)</th>
                <th>Manganeso (Mn)</th>
                <th>Dictamen</th>
              </tr>
            </thead>
            <tbody>
              ${qualityData.map(r => `
                <tr>
                  <td><strong>${r.ot}</strong></td>
                  <td>${r.client}</td>
                  <td>${r.material}</td>
                  <td>${r.c}</td>
                  <td>${r.si}</td>
                  <td>${r.mn}</td>
                  <td class="status-ok">${r.status} ✓</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        ` : `
          <table>
            <thead>
              <tr>
                <th>Folio OT</th>
                <th>Cliente</th>
                <th>Horno</th>
                <th>Material</th>
                <th>Duración Real</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              ${historyData.map(r => `
                <tr>
                  <td><strong>${r.ot}</strong></td>
                  <td>${r.client}</td>
                  <td>${r.furnace}</td>
                  <td>${r.material}</td>
                  <td>${r.time}</td>
                  <td class="status-ok">${r.status}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        `}

        <div class="signature">
          <div class="sign-line">Ing. Inspector de Calidad<br><span style="font-weight: normal; font-size: 9px;">Laboratorio Metalúrgico SSMF</span></div>
          <div class="sign-line">Jefe de Planta de Fundición<br><span style="font-weight: normal; font-size: 9px;">Supervisión de Operaciones</span></div>
        </div>

        <div class="footer">
          <div>SS Metal Foundry S.A. de C.V. • Documento Oficial de Producción</div>
          <div>Impreso el ${new Date().toLocaleString('es-MX')}</div>
        </div>

        <script>
          window.onload = function() {
            window.print();
          };
        </script>
      </body>
      </html>
    `;

    printWindow.document.open();
    printWindow.document.write(html);
    printWindow.document.close();

    setDownloadSuccess(true);
    setTimeout(() => setDownloadSuccess(false), 3000);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/75 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-[#181b20] border border-[#2e3644] w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden animate-fade-in text-gray-200">
        
        {/* Header */}
        <div className="bg-[#13151a] px-6 py-4 border-b border-[#252a33] flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <ShieldCheck className={`w-5 h-5 ${type === 'quality' ? 'text-green-400' : 'text-red-400'}`} />
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

        {/* Success toast alert */}
        {downloadSuccess && (
          <div className="bg-[#1e3423] border-b border-[#2e7d32] text-green-300 px-6 py-2 text-xs flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-green-400" />
            <span>¡Reporte descargado y generado con éxito!</span>
          </div>
        )}

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
                      {qualityData.map((row) => (
                        <tr key={row.ot}>
                          <td className="p-2.5 font-mono text-white">{row.ot}</td>
                          <td className="p-2.5">{row.material}</td>
                          <td className="p-2.5">{row.c}</td>
                          <td className="p-2.5">{row.si}</td>
                          <td className="p-2.5 text-green-400 font-semibold">{row.status} ✓</td>
                        </tr>
                      ))}
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
                    {historyData.map((row) => (
                      <tr key={row.ot}>
                        <td className="p-2.5 font-mono text-white">{row.ot}</td>
                        <td className="p-2.5">{row.client}</td>
                        <td className="p-2.5">{row.furnace}</td>
                        <td className="p-2.5">{row.material}</td>
                        <td className="p-2.5">{row.time}</td>
                        <td className="p-2.5 text-green-400 font-semibold">{row.status}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>

        {/* Footer with download actions */}
        <div className="bg-[#13151a] px-6 py-3.5 border-t border-[#252a33] flex flex-wrap items-center justify-between gap-3">
          <span className="text-xs text-gray-500 font-mono">SSMF Sistema de Trazabilidad 2026</span>
          
          <div className="flex items-center gap-2">
            {/* Download CSV */}
            <button
              onClick={handleDownloadCSV}
              title="Descargar en formato Excel / CSV"
              className="bg-[#1f242d] hover:bg-[#2b3340] text-gray-200 text-xs px-3 py-2 rounded-lg flex items-center gap-1.5 transition border border-[#374151] active:scale-95"
            >
              <FileSpreadsheet className="w-3.5 h-3.5 text-green-400" />
              <span>Descargar CSV</span>
            </button>

            {/* Download / Print PDF */}
            <button
              onClick={handleDownloadPDF}
              title="Descargar o imprimir reporte en PDF oficial"
              className="bg-gradient-to-r from-[#d32f2f] to-[#e53935] hover:from-[#b71c1c] hover:to-[#d32f2f] text-white text-xs px-4 py-2 rounded-lg font-semibold flex items-center gap-1.5 transition shadow-[0_2px_10px_rgba(229,57,53,0.3)] active:scale-95"
            >
              <FileText className="w-3.5 h-3.5" />
              <span>Descargar PDF</span>
            </button>

            {/* Close button */}
            <button
              onClick={onClose}
              className="bg-[#2a303c] hover:bg-[#374050] text-gray-300 text-xs px-3.5 py-2 rounded-lg font-medium transition"
            >
              Cerrar
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}
