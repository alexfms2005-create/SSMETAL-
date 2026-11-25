import React, { useState, useMemo } from 'react';
import { 
  Search, 
  Filter, 
  Calendar, 
  Download, 
  AlertTriangle, 
  Flame, 
  CheckCircle2, 
  Layers, 
  Wrench, 
  ArrowRight,
  TrendingUp,
  Tag
} from 'lucide-react';
import { backlogWeeks } from '../data/backlogData';

export default function TabPrioridades({ onSelectForOT }) {
  const [selectedWeek, setSelectedWeek] = useState('all'); // 'all' or weekNumber
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [materialFilter, setMaterialFilter] = useState('all');

  // Flatten all items for global statistics & filtering
  const allItems = useMemo(() => {
    return backlogWeeks.flatMap((w) =>
      w.items.map((item) => ({ ...item, weekNumber: w.weekNumber, weekTitle: w.title }))
    );
  }, []);

  // Summary Metrics
  const metrics = useMemo(() => {
    const totalPorFundir = allItems.reduce((acc, curr) => acc + (curr.porFundir || 0), 0);
    const totalPorPedido = allItems.reduce((acc, curr) => acc + (curr.porPedido || 0), 0);
    
    // Semana 46 stats
    const sem46 = backlogWeeks.find((w) => w.weekNumber === 46);
    const sem46PorFundir = sem46 ? sem46.totalPorFundir : 0;
    const sem46PorPedido = sem46 ? sem46.totalPedido : 0;

    // Alertas de modelos faltantes (X)
    const missingModels = allItems.filter((i) => i.modelo === 'X').length;

    // Partidas con Maquinado (MAQ)
    const maqItems = allItems.filter((i) => i.maq === 'MAQ').length;

    return {
      totalPorFundir,
      totalPorPedido,
      sem46PorFundir,
      sem46PorPedido,
      missingModels,
      maqItems
    };
  }, [allItems]);

  // Unique materials for filter dropdown
  const materialsList = useMemo(() => {
    const set = new Set();
    allItems.forEach((i) => {
      if (i.material) set.add(i.material);
    });
    return Array.from(set).sort();
  }, [allItems]);

  // Unique statuses for filter dropdown
  const statusesList = useMemo(() => {
    const set = new Set();
    allItems.forEach((i) => {
      if (i.estatus && i.estatus !== '-') set.add(i.estatus);
    });
    return Array.from(set).sort();
  }, [allItems]);

  // Filter weeks and items
  const filteredWeeks = useMemo(() => {
    return backlogWeeks
      .filter((w) => selectedWeek === 'all' || w.weekNumber === Number(selectedWeek))
      .map((week) => {
        const filteredItems = week.items.filter((item) => {
          // Search query
          const matchSearch =
            !searchTerm ||
            item.cliente.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.descripcion.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.ocExterna.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.ocInterna.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.codInterno.toLowerCase().includes(searchTerm.toLowerCase());

          // Status filter
          const matchStatus =
            statusFilter === 'all' ||
            (item.estatus && item.estatus.toLowerCase().includes(statusFilter.toLowerCase()));

          // Material filter
          const matchMaterial =
            materialFilter === 'all' || item.material === materialFilter;

          return matchSearch && matchStatus && matchMaterial;
        });

        // Recalculate filtered totals for the week
        const weekPedido = filteredItems.reduce((acc, curr) => acc + (curr.porPedido || 0), 0);
        const weekFundir = filteredItems.reduce((acc, curr) => acc + (curr.porFundir || 0), 0);

        return {
          ...week,
          filteredItems,
          weekPedido,
          weekFundir
        };
      })
      .filter((week) => week.filteredItems.length > 0);
  }, [selectedWeek, searchTerm, statusFilter, materialFilter]);

  // Export Backlog to CSV
  const handleExportCSV = () => {
    let csv = 'Semana,Cliente,F. OC,F. Entrega,O.C. Externa,O.C. Interna,Descripcion,Cant,Unidad,Maquinado,Cod. Interno,Modelo,Material,Peso Unit (Kg),Por Pedido (Kg),Por Fundir (Kg),Estatus\n';
    
    allItems.forEach((item) => {
      csv += `"${item.weekTitle}","${item.cliente}","${item.fOc}","${item.fEntrega}","${item.ocExterna}","${item.ocInterna}","${item.descripcion}",${item.cant},"${item.un}","${item.maq}","${item.codInterno}","${item.modelo}","${item.material}",${item.pesoUnit},${item.porPedido},${item.porFundir},"${item.estatus}"\n`;
    });

    const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `SSMF_Backlog_Prioridades_${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  return (
    <div className="p-4 sm:p-6 max-w-[1550px] mx-auto space-y-6">
      
      {/* ================= HEADER BAR ================= */}
      <div className="bg-[#181b20] border border-[#282e38] rounded-2xl p-5 shadow-xl flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <span className="p-2 rounded-lg bg-[#b71c1c]/20 text-[#e53935] border border-[#b71c1c]/40">
              <Layers className="w-5 h-5" />
            </span>
            <div>
              <h1 className="text-lg md:text-xl font-bold tracking-wide text-white uppercase">
                Backlog Steel y SS Metal Foundry • Órdenes de Compra
              </h1>
              <p className="text-xs text-gray-400 flex items-center gap-2 mt-0.5 font-mono">
                <span>Corte Operativo: <strong>11/Nov/2026</strong></span>
                <span>•</span>
                <span className="text-orange-400 font-semibold bg-[#2e1d13] px-2 py-0.5 rounded border border-orange-900/60">
                  SEMANA 46 ACTIVA (09 AL 15 DE NOVIEMBRE)
                </span>
              </p>
            </div>
          </div>
        </div>

        {/* Action Button: Export CSV */}
        <div className="flex items-center gap-3">
          <button
            onClick={handleExportCSV}
            className="bg-[#222731] hover:bg-[#2c3340] text-gray-200 hover:text-white text-xs font-semibold px-4 py-2.5 rounded-lg border border-[#3b4455] flex items-center gap-2 transition shadow-md active:scale-95"
          >
            <Download className="w-4 h-4 text-green-400" />
            <span>Exportar Backlog (CSV)</span>
          </button>
        </div>
      </div>

      {/* ================= KPI CARDS ================= */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {/* Card 1: Total Backlog Por Fundir */}
        <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-4 shadow-md space-y-1 relative overflow-hidden">
          <div className="flex items-center justify-between text-xs text-gray-400">
            <span>Total Backlog por Fundir</span>
            <Flame className="w-4 h-4 text-orange-400" />
          </div>
          <div className="text-xl md:text-2xl font-bold text-white font-mono">
            {metrics.totalPorFundir.toLocaleString('es-MX', { minimumFractionDigits: 2 })} <span className="text-xs font-normal text-gray-400">Kg</span>
          </div>
          <div className="text-[11px] text-gray-400">
            Total en pedidos: <strong className="text-gray-300">{metrics.totalPorPedido.toLocaleString('es-MX')} Kg</strong>
          </div>
        </div>

        {/* Card 2: Semana 46 Activa */}
        <div className="bg-[#241a14] border border-[#e65100]/60 rounded-xl p-4 shadow-md space-y-1 relative overflow-hidden">
          <div className="flex items-center justify-between text-xs text-orange-400 font-semibold">
            <span>Semana 46 (Prioridad Actual)</span>
            <Calendar className="w-4 h-4 text-orange-400" />
          </div>
          <div className="text-xl md:text-2xl font-bold text-orange-400 font-mono">
            {metrics.sem46PorFundir.toLocaleString('es-MX', { minimumFractionDigits: 2 })} <span className="text-xs font-normal text-gray-300">Kg</span>
          </div>
          <div className="text-[11px] text-gray-300">
            Meta semanal: <strong className="text-white">{metrics.sem46PorPedido.toLocaleString('es-MX')} Kg</strong>
          </div>
        </div>

        {/* Card 3: Modelos Faltantes */}
        <div className="bg-[#251717] border border-[#b71c1c]/60 rounded-xl p-4 shadow-md space-y-1 relative overflow-hidden">
          <div className="flex items-center justify-between text-xs text-red-400 font-semibold">
            <span>Modelos Faltantes (X)</span>
            <AlertTriangle className="w-4 h-4 text-red-400" />
          </div>
          <div className="text-xl md:text-2xl font-bold text-red-400 font-mono">
            {metrics.missingModels} <span className="text-xs font-normal text-gray-300">piezas</span>
          </div>
          <div className="text-[11px] text-red-300/80">
            Requieren modelo en madera antes de programar
          </div>
        </div>

        {/* Card 4: Maquinados */}
        <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-4 shadow-md space-y-1 relative overflow-hidden">
          <div className="flex items-center justify-between text-xs text-gray-400">
            <span>Requerimiento Maquinado (MAQ)</span>
            <Wrench className="w-4 h-4 text-blue-400" />
          </div>
          <div className="text-xl md:text-2xl font-bold text-blue-400 font-mono">
            {metrics.maqItems} <span className="text-xs font-normal text-gray-400">partidas</span>
          </div>
          <div className="text-[11px] text-gray-400">
            Con maquinado posterior a colada
          </div>
        </div>
      </div>

      {/* ================= FILTERS & SEARCH CONTROLS ================= */}
      <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-4 shadow-md space-y-4">
        {/* Search input + Dropdowns */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {/* Search bar */}
          <div className="relative">
            <Search className="w-4 h-4 absolute left-3 top-3 text-gray-400" />
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Buscar cliente, pieza, OC, código..."
              className="w-full bg-[#121418] border border-[#2c333f] text-white text-xs rounded-lg pl-9 pr-3 py-2.5 focus:border-[#e53935] focus:outline-none transition"
            />
          </div>

          {/* Week select */}
          <div>
            <select
              value={selectedWeek}
              onChange={(e) => setSelectedWeek(e.target.value)}
              className="w-full bg-[#121418] border border-[#2c333f] text-gray-200 text-xs rounded-lg px-3 py-2.5 focus:border-[#e53935] focus:outline-none"
            >
              <option value="all">📅 Todas las Semanas (44 a 49)</option>
              <option value="44">Semana 44 (26 Oct - 01 Nov)</option>
              <option value="45">Semana 45 (02 Nov - 08 Nov)</option>
              <option value="46">⭐ Semana 46 (09 Nov - 15 Nov) - ACTIVA</option>
              <option value="47">Semana 47 (16 Nov - 22 Nov)</option>
              <option value="48">Semana 48 (23 Nov - 29 Nov)</option>
              <option value="49">Semana 49 (30 Nov - 06 Dic)</option>
              <option value="50">Especiales (GEISH / Bolañitos)</option>
            </select>
          </div>

          {/* Status filter */}
          <div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full bg-[#121418] border border-[#2c333f] text-gray-200 text-xs rounded-lg px-3 py-2.5 focus:border-[#e53935] focus:outline-none"
            >
              <option value="all">⚡ Todos los Estatus</option>
              {statusesList.map((st) => (
                <option key={st} value={st}>
                  {st}
                </option>
              ))}
            </select>
          </div>

          {/* Material filter */}
          <div>
            <select
              value={materialFilter}
              onChange={(e) => setMaterialFilter(e.target.value)}
              className="w-full bg-[#121418] border border-[#2c333f] text-gray-200 text-xs rounded-lg px-3 py-2.5 focus:border-[#e53935] focus:outline-none"
            >
              <option value="all">🧪 Todos los Materiales</option>
              {materialsList.map((mat) => (
                <option key={mat} value={mat}>
                  {mat}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Quick filter pills */}
        <div className="flex flex-wrap items-center gap-2 pt-1 border-t border-[#252b36] text-xs">
          <span className="text-gray-400 text-[11px] font-medium mr-1 flex items-center gap-1">
            <Filter className="w-3 h-3" /> Filtro rápido:
          </span>
          <button
            onClick={() => { setSelectedWeek('all'); setStatusFilter('all'); setMaterialFilter('all'); setSearchTerm(''); }}
            className={`px-2.5 py-1 rounded-md text-xs transition ${
              selectedWeek === 'all' && statusFilter === 'all' && materialFilter === 'all' && !searchTerm
                ? 'bg-[#e53935] text-white font-bold'
                : 'bg-[#222731] text-gray-300 hover:text-white'
            }`}
          >
            Ver Todo
          </button>
          <button
            onClick={() => setSelectedWeek('46')}
            className={`px-2.5 py-1 rounded-md text-xs transition ${
              selectedWeek === '46'
                ? 'bg-orange-600 text-white font-bold shadow-[0_0_8px_rgba(234,88,12,0.8)]'
                : 'bg-[#2e1d13] text-orange-400 border border-orange-900/60 hover:bg-orange-950'
            }`}
          >
            ⭐ Semana 46 (Prioritaria)
          </button>
          <button
            onClick={() => setStatusFilter('PROG 46')}
            className={`px-2.5 py-1 rounded-md text-xs transition ${
              statusFilter === 'PROG 46'
                ? 'bg-[#f57c00] text-white font-bold'
                : 'bg-[#222731] text-gray-300 hover:text-white'
            }`}
          >
            Programadas (PROG 46)
          </button>
          <button
            onClick={() => setStatusFilter('MOLDEO')}
            className={`px-2.5 py-1 rounded-md text-xs transition ${
              statusFilter === 'MOLDEO'
                ? 'bg-blue-600 text-white font-bold'
                : 'bg-[#222731] text-gray-300 hover:text-white'
            }`}
          >
            En Moldeo
          </button>
          <button
            onClick={() => setStatusFilter('ACABADOS')}
            className={`px-2.5 py-1 rounded-md text-xs transition ${
              statusFilter === 'ACABADOS'
                ? 'bg-green-700 text-white font-bold'
                : 'bg-[#222731] text-gray-300 hover:text-white'
            }`}
          >
            Acabados
          </button>
          <button
            onClick={() => setStatusFilter('MODELO FALTANTE')}
            className={`px-2.5 py-1 rounded-md text-xs transition ${
              statusFilter === 'MODELO FALTANTE'
                ? 'bg-red-700 text-white font-bold'
                : 'bg-[#331a1a] text-red-400 border border-red-900/60 hover:bg-red-950'
            }`}
          >
            ⚠️ Modelos Faltantes (X)
          </button>
        </div>
      </div>

      {/* ================= BACKLOG SPREADSHEET TABLE ================= */}
      <div className="space-y-6">
        {filteredWeeks.map((week) => (
          <div
            key={week.weekNumber}
            className={`border rounded-xl overflow-hidden shadow-xl transition ${
              week.isCurrent
                ? 'border-orange-600/70 bg-[#14171d]'
                : 'border-[#282e38] bg-[#16191f]'
            }`}
          >
            {/* Week Header Banner */}
            <div
              className={`px-4 py-3 flex flex-wrap items-center justify-between border-b ${
                week.isCurrent
                  ? 'bg-gradient-to-r from-[#331c12] via-[#241712] to-[#1a1412] border-orange-900/60 text-orange-200'
                  : 'bg-[#1b1f26] border-[#282e38] text-gray-200'
              }`}
            >
              <div className="flex items-center gap-3">
                <span
                  className={`text-xs font-bold px-2.5 py-1 rounded tracking-wider uppercase ${
                    week.isCurrent
                      ? 'bg-orange-600 text-white shadow-[0_0_10px_rgba(234,88,12,0.6)]'
                      : 'bg-[#29303d] text-gray-300'
                  }`}
                >
                  {week.title}
                </span>
                <span className="text-xs font-semibold text-gray-300">
                  {week.dateRange}
                </span>
                {week.isCurrent && (
                  <span className="text-[10px] bg-red-600/80 text-white font-bold px-2 py-0.5 rounded uppercase tracking-wider animate-pulse">
                    En Curso
                  </span>
                )}
              </div>

              {/* Weekly Totals */}
              <div className="flex items-center gap-4 text-xs font-mono font-semibold">
                <div>
                  <span className="text-gray-400 text-[11px] mr-1">Total Pedido:</span>
                  <span className="bg-[#2a2417] text-yellow-300 px-2.5 py-0.5 rounded border border-yellow-700/50">
                    {week.weekPedido.toLocaleString('es-MX', { minimumFractionDigits: 2 })} Kg
                  </span>
                </div>
                <div>
                  <span className="text-gray-400 text-[11px] mr-1">Por Fundir:</span>
                  <span className="bg-[#351c14] text-orange-400 px-2.5 py-0.5 rounded border border-orange-700/50">
                    {week.weekFundir.toLocaleString('es-MX', { minimumFractionDigits: 2 })} Kg
                  </span>
                </div>
              </div>
            </div>

            {/* Responsive Table */}
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs whitespace-nowrap">
                <thead className="bg-[#101216] text-gray-400 font-semibold border-b border-[#252b36] uppercase text-[10px] tracking-wider select-none">
                  <tr>
                    <th className="py-2.5 px-3">Cliente</th>
                    <th className="py-2.5 px-2.5">F. OC</th>
                    <th className="py-2.5 px-2.5">F. Entrega</th>
                    <th className="py-2.5 px-2.5">OC Ext / Int</th>
                    <th className="py-2.5 px-3">Descripción de la Pieza</th>
                    <th className="py-2.5 px-2 text-center">Cant</th>
                    <th className="py-2.5 px-2 text-center">Maq</th>
                    <th className="py-2.5 px-2.5">Cód. Interno</th>
                    <th className="py-2.5 px-2 text-center">Mod</th>
                    <th className="py-2.5 px-2.5">Material</th>
                    <th className="py-2.5 px-2.5 text-right">Peso Unit</th>
                    <th className="py-2.5 px-2.5 text-right">Por Pedido</th>
                    <th className="py-2.5 px-2.5 text-right">Por Fundir</th>
                    <th className="py-2.5 px-3 text-center">Estatus</th>
                    <th className="py-2.5 px-3 text-center">Acción</th>
                  </tr>
                </thead>

                <tbody className="divide-y divide-[#222731]">
                  {week.filteredItems.map((item) => {
                    const isSalmon = item.highlight === 'salmon';
                    const isOrange = item.highlight === 'orange';
                    const isMissingModel = item.modelo === 'X';

                    return (
                      <tr
                        key={item.id}
                        className={`transition-colors ${
                          isOrange
                            ? 'bg-[#3b2711]/60 hover:bg-[#4a3217]'
                            : isSalmon
                            ? 'bg-[#331a1a]/60 hover:bg-[#402222]'
                            : 'hover:bg-[#1f242c]'
                        }`}
                      >
                        {/* Cliente */}
                        <td className="py-2.5 px-3 font-semibold text-white">
                          {item.cliente}
                        </td>

                        {/* F. OC */}
                        <td className="py-2.5 px-2.5 text-gray-400 font-mono text-[11px]">
                          {item.fOc}
                        </td>

                        {/* F. Entrega */}
                        <td className="py-2.5 px-2.5 text-gray-300 font-mono text-[11px]">
                          {item.fEntrega}
                        </td>

                        {/* O.C. Externa / Interna */}
                        <td className="py-2.5 px-2.5 text-xs">
                          <div className="font-mono text-gray-200">{item.ocExterna}</div>
                          {item.ocInterna && item.ocInterna !== 'NA' && (
                            <div className="text-[10px] text-gray-400 font-mono">{item.ocInterna}</div>
                          )}
                        </td>

                        {/* Descripción */}
                        <td className="py-2.5 px-3 max-w-[320px] truncate text-gray-200" title={item.descripcion}>
                          <span className="font-medium">{item.descripcion}</span>
                        </td>

                        {/* Cantidad */}
                        <td className="py-2.5 px-2 text-center font-bold text-white font-mono">
                          {item.cant} <span className="text-[10px] text-gray-400 font-normal">{item.un}</span>
                        </td>

                        {/* Maquinado (MAQ) */}
                        <td className="py-2.5 px-2 text-center">
                          {item.maq === 'MAQ' ? (
                            <span className="bg-blue-900/60 text-blue-300 text-[10px] font-bold px-1.5 py-0.5 rounded border border-blue-700/60">
                              MAQ
                            </span>
                          ) : (
                            <span className="text-gray-500 text-[10px]">NA</span>
                          )}
                        </td>

                        {/* Cód. Interno */}
                        <td className="py-2.5 px-2.5 font-mono text-[11px] text-gray-300">
                          {item.codInterno}
                        </td>

                        {/* Modelo (OK / X) */}
                        <td className="py-2.5 px-2 text-center">
                          {isMissingModel ? (
                            <span className="bg-red-600 text-white font-extrabold text-[11px] px-2 py-0.5 rounded shadow-[0_0_8px_rgba(239,68,68,0.9)] animate-pulse">
                              X
                            </span>
                          ) : (
                            <span className="text-green-400 font-bold text-xs">OK</span>
                          )}
                        </td>

                        {/* Material */}
                        <td className="py-2.5 px-2.5">
                          <span
                            className={`text-[11px] font-semibold px-2 py-0.5 rounded border ${
                              item.material.includes('AC MN')
                                ? 'bg-[#1b2b2b] text-teal-300 border-teal-800'
                                : item.material.includes('NI HARD')
                                ? 'bg-[#2b1f33] text-purple-300 border-purple-800'
                                : item.material === 'WCB'
                                ? 'bg-[#1b2533] text-sky-300 border-sky-800'
                                : item.material === 'NODULAR'
                                ? 'bg-[#332213] text-orange-300 border-orange-800'
                                : item.material === 'ALUMINIO'
                                ? 'bg-[#2b2b1b] text-yellow-300 border-yellow-800'
                                : 'bg-[#222731] text-gray-300 border-gray-700'
                            }`}
                          >
                            {item.material}
                          </span>
                        </td>

                        {/* Peso Unitario */}
                        <td className="py-2.5 px-2.5 text-right font-mono text-gray-300">
                          {item.pesoUnit > 0 ? item.pesoUnit.toFixed(2) : '-'}
                        </td>

                        {/* Por Pedido */}
                        <td className="py-2.5 px-2.5 text-right font-mono font-semibold text-gray-200">
                          {item.porPedido > 0 ? item.porPedido.toLocaleString('es-MX', { minimumFractionDigits: 2 }) : '-'}
                        </td>

                        {/* Por Fundir */}
                        <td className="py-2.5 px-2.5 text-right font-mono font-bold">
                          {item.porFundir > 0 ? (
                            <span className="text-orange-400">
                              {item.porFundir.toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                            </span>
                          ) : (
                            <span className="text-gray-500">-</span>
                          )}
                        </td>

                        {/* Estatus */}
                        <td className="py-2.5 px-3 text-center">
                          {item.estatus && item.estatus !== '-' ? (
                            <span
                              className={`text-[10px] font-bold px-2 py-0.5 rounded-full inline-block ${
                                item.estatus.includes('PROG 46')
                                  ? 'bg-[#e65100]/30 text-orange-400 border border-orange-600'
                                  : item.estatus.includes('ACABADOS')
                                  ? 'bg-green-950/60 text-green-400 border border-green-700'
                                  : item.estatus.includes('MOLDEO')
                                  ? 'bg-blue-950/60 text-blue-400 border border-blue-700'
                                  : item.estatus.includes('MODELO FALTANTE')
                                  ? 'bg-red-950 text-red-400 border border-red-700'
                                  : isOrange
                                  ? 'bg-amber-900/60 text-amber-300 border border-amber-600 font-bold'
                                  : 'bg-[#222731] text-gray-300 border border-gray-700'
                              }`}
                            >
                              {item.estatus}
                            </span>
                          ) : (
                            <span className="text-gray-600">-</span>
                          )}
                        </td>

                        {/* Acción: Asignar a OT */}
                        <td className="py-2.5 px-3 text-center">
                          <button
                            onClick={() => onSelectForOT(item)}
                            title="Llevar esta partida a la pantalla de Alta de OT"
                            className="bg-[#242b36] hover:bg-[#e53935] text-gray-300 hover:text-white px-2.5 py-1 rounded text-[11px] font-semibold transition border border-[#3b4455] hover:border-transparent flex items-center gap-1 mx-auto active:scale-95 shadow-sm"
                          >
                            <span>Generar OT</span>
                            <ArrowRight className="w-3 h-3" />
                          </button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>

            {/* Week Footer Summary */}
            <div className="bg-[#121418] px-4 py-2 border-t border-[#252b36] flex items-center justify-between text-[11px] text-gray-400 font-mono">
              <div>
                Mostrando <strong className="text-white">{week.filteredItems.length}</strong> partidas en {week.title}
              </div>
              <div className="flex items-center gap-4">
                <span>Subtotal Pedido: <strong className="text-yellow-300">{week.weekPedido.toLocaleString('es-MX', { minimumFractionDigits: 2 })} Kg</strong></span>
                <span>Subtotal por Fundir: <strong className="text-orange-400">{week.weekFundir.toLocaleString('es-MX', { minimumFractionDigits: 2 })} Kg</strong></span>
              </div>
            </div>

          </div>
        ))}
      </div>

    </div>
  );
}
