import React, { useState } from 'react';
import { Calendar as CalendarIcon, Flame, Plus, X, Check, ChevronLeft, ChevronRight } from 'lucide-react';
import { availableMaterials } from '../data/mockData';

const MONTH_NAMES = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

export default function TabAltaOT({ furnaces, onGenerateOT, nextOTNumber }) {
  const [otNumber] = useState(nextOTNumber || 'OT-2026-092');
  const [client, setClient] = useState('Maquinaria Industrial S.A.');
  const [selectedMaterials, setSelectedMaterials] = useState([
    'Acero al Carbón',
    'Chatarra de Retorno',
    'Ferroaleaciones'
  ]);
  const [materialDropdown, setMaterialDropdown] = useState('');
  const [quantityKg, setQuantityKg] = useState('1200');

  // Fully functional calendar state (defaults to 18 Nov 2026 as in mockup)
  const [selectedDate, setSelectedDate] = useState({ day: 18, month: 10, year: 2026 }); // month 10 = Nov
  const [viewDate, setViewDate] = useState({ month: 10, year: 2026 });

  const [selectedFurnaceId, setSelectedFurnaceId] = useState('horno-b');
  const [notes, setNotes] = useState('Monitorear temperatura de vaciado a 1550°C.');
  const [showSuccessToast, setShowSuccessToast] = useState(false);

  // Calendar navigation functions
  const handlePrevMonth = () => {
    setViewDate((prev) => {
      if (prev.month === 0) {
        return { month: 11, year: prev.year - 1 };
      }
      return { ...prev, month: prev.month - 1 };
    });
  };

  const handleNextMonth = () => {
    setViewDate((prev) => {
      if (prev.month === 11) {
        return { month: 0, year: prev.year + 1 };
      }
      return { ...prev, month: prev.month + 1 };
    });
  };

  const handleSelectDay = (day) => {
    setSelectedDate({
      day,
      month: viewDate.month,
      year: viewDate.year
    });
  };

  // Compute days in current view month
  const daysInViewMonth = new Date(viewDate.year, viewDate.month + 1, 0).getDate();
  // Monday = 0, Sunday = 6
  const firstDayOfWeek = (new Date(viewDate.year, viewDate.month, 1).getDay() + 6) % 7;

  const calendarGrid = [];
  for (let i = 0; i < firstDayOfWeek; i++) {
    calendarGrid.push(null);
  }
  for (let d = 1; d <= daysInViewMonth; d++) {
    calendarGrid.push(d);
  }

  const addMaterial = (mat) => {
    if (mat && !selectedMaterials.includes(mat)) {
      setSelectedMaterials([...selectedMaterials, mat]);
    }
    setMaterialDropdown('');
  };

  const removeMaterial = (mat) => {
    setSelectedMaterials(selectedMaterials.filter((m) => m !== mat));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!client.trim()) {
      alert('Por favor ingrese el nombre del cliente');
      return;
    }
    if (selectedMaterials.length === 0) {
      alert('Seleccione al menos un material');
      return;
    }

    const furnace = furnaces.find((f) => f.id === selectedFurnaceId);

    const formattedDate = `${String(selectedDate.day).padStart(2, '0')} / ${MONTH_NAMES[selectedDate.month]} / ${selectedDate.year}`;

    const newOT = {
      id: otNumber,
      furnaceId: selectedFurnaceId,
      furnaceName: furnace ? furnace.name : 'Horno B',
      material: selectedMaterials.join(', '),
      progress: 0,
      phase: 'Carga inicial (0%)',
      remainingMinutes: 180,
      client: client,
      quantityKg: Number(quantityKg) || 1200,
      color: 'orange',
      notes: notes,
      deliveryDate: formattedDate
    };

    onGenerateOT(newOT);
    setShowSuccessToast(true);
    setTimeout(() => setShowSuccessToast(false), 4000);
  };

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      {/* Page Title */}
      <div className="border-b border-[#262c36] pb-3">
        <h1 className="text-xl md:text-2xl font-bold tracking-wide text-white uppercase flex items-center gap-2">
          Alta de Orden de Trabajo (OT)
        </h1>
      </div>

      {showSuccessToast && (
        <div className="bg-[#1b3320] border border-[#2e7d32] text-green-300 px-4 py-3 rounded-lg flex items-center justify-between shadow-lg animate-fade-in">
          <div className="flex items-center gap-2">
            <Check className="w-5 h-5 text-green-400" />
            <span>¡Orden de trabajo <strong>{otNumber}</strong> generada con éxito y enviada al tablero de proceso!</span>
          </div>
          <button onClick={() => setShowSuccessToast(false)} className="text-gray-400 hover:text-white">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Two columns layout */}
      <form onSubmit={handleSubmit} className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left Column: DATOS GENERALES DE LA OT */}
        <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-5 space-y-5 shadow-xl">
          <h2 className="text-sm font-semibold tracking-wider text-gray-200 uppercase flex items-center gap-2 border-b border-[#252b36] pb-2">
            Datos Generales de la OT
          </h2>

          {/* Número de OT autogenerado */}
          <div>
            <label className="block text-xs font-medium text-gray-400 mb-1.5">
              Número de OT (autogenerado)
            </label>
            <input
              type="text"
              readOnly
              value={otNumber}
              className="w-full bg-[#1e2229] border border-[#2c333f] text-gray-300 text-sm rounded-lg px-3.5 py-2.5 focus:outline-none cursor-not-allowed font-sans"
            />
          </div>

          {/* Cliente */}
          <div>
            <label className="block text-xs font-medium text-gray-400 mb-1.5">
              Cliente
            </label>
            <input
              type="text"
              value={client}
              onChange={(e) => setClient(e.target.value)}
              placeholder="Nombre del cliente o empresa"
              className="w-full bg-[#1e2229] border border-[#2c333f] text-white text-sm rounded-lg px-3.5 py-2.5 focus:border-[#e53935] focus:outline-none transition"
              required
            />
          </div>

          {/* MATERIALES REQUERIDOS */}
          <div>
            <label className="block text-xs font-medium text-gray-400 mb-1.5 flex items-center gap-1.5">
              <span>⚙️ MATERIALES REQUERIDOS</span>
            </label>
            
            <div className="space-y-2">
              <select
                value={materialDropdown}
                onChange={(e) => addMaterial(e.target.value)}
                className="w-full bg-[#1e2229] border border-[#2c333f] text-gray-300 text-sm rounded-lg px-3.5 py-2.5 focus:border-[#e53935] focus:outline-none"
              >
                <option value="">Materiales requeridos...</option>
                {availableMaterials.map((mat) => (
                  <option key={mat} value={mat}>
                    {mat}
                  </option>
                ))}
              </select>

              {/* Tag chips */}
              <div className="flex flex-wrap gap-2 pt-1">
                {selectedMaterials.map((mat) => (
                  <span
                    key={mat}
                    className="inline-flex items-center gap-1.5 bg-[#252b36] border border-[#3b4455] text-gray-200 text-xs px-3 py-1.5 rounded-md hover:border-gray-400 transition"
                  >
                    <span>{mat}</span>
                    <button
                      type="button"
                      onClick={() => removeMaterial(mat)}
                      className="text-gray-400 hover:text-red-400 ml-1 transition"
                    >
                      <X className="w-3.5 h-3.5" />
                    </button>
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* Cantidad Total (Kg) */}
          <div>
            <label className="block text-xs font-medium text-gray-400 mb-1.5 font-sans">
              Cantidad Total (Kg):
            </label>
            <input
              type="number"
              value={quantityKg}
              onChange={(e) => setQuantityKg(e.target.value)}
              className="w-full bg-[#1e2229] border border-[#2c333f] text-white text-sm rounded-lg px-3.5 py-2.5 focus:border-[#e53935] focus:outline-none font-sans [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
              required
            />
          </div>

          {/* FECHA ESTIMADA DE ENTREGA (Calendario) */}
          <div>
            <label className="block text-xs font-medium text-gray-400 mb-2 flex items-center gap-1.5 font-sans">
              <CalendarIcon className="w-3.5 h-3.5 text-orange-400" />
              <span>FECHA ESTIMADA DE ENTREGA</span>
            </label>

            <div className="bg-[#1e2229] border border-[#2c333f] rounded-lg p-3 text-xs select-none font-sans">
              {/* Calendar Header with exact matching typography */}
              <div className="flex items-center justify-between text-gray-300 font-semibold mb-3 px-2">
                <button
                  type="button"
                  onClick={handlePrevMonth}
                  title="Mes anterior"
                  className="text-gray-400 hover:text-white font-sans text-sm font-bold px-2 py-0.5 rounded hover:bg-[#2b3340] transition select-none cursor-pointer"
                >
                  &lt;
                </button>
                <span className="tracking-wide text-xs sm:text-sm font-semibold text-gray-200 font-sans">
                  {selectedDate.month === viewDate.month && selectedDate.year === viewDate.year
                    ? `${selectedDate.day} / ${MONTH_NAMES[viewDate.month]} / ${viewDate.year}`
                    : `${MONTH_NAMES[viewDate.month]} / ${viewDate.year}`}
                </span>
                <button
                  type="button"
                  onClick={handleNextMonth}
                  title="Mes siguiente"
                  className="text-gray-400 hover:text-white font-sans text-sm font-bold px-2 py-0.5 rounded hover:bg-[#2b3340] transition select-none cursor-pointer"
                >
                  &gt;
                </button>
              </div>

              {/* Day names */}
              <div className="grid grid-cols-7 text-center text-[11px] text-gray-400 font-medium mb-1.5">
                <span>Lun</span>
                <span>Mar</span>
                <span>Mie</span>
                <span>Jue</span>
                <span>Vie</span>
                <span>Sab</span>
                <span>Dom</span>
              </div>

              {/* Days grid */}
              <div className="grid grid-cols-7 gap-1 text-center">
                {calendarGrid.map((day, idx) => {
                  if (day === null) {
                    return <div key={`empty-${idx}`} className="h-7 w-7" />;
                  }
                  const isSelected =
                    selectedDate.day === day &&
                    selectedDate.month === viewDate.month &&
                    selectedDate.year === viewDate.year;

                  return (
                    <button
                      key={`day-${day}`}
                      type="button"
                      onClick={() => handleSelectDay(day)}
                      className={`h-7 w-7 mx-auto flex items-center justify-center rounded-full text-xs transition transform active:scale-90 ${
                        isSelected
                          ? 'bg-[#e53935] text-white shadow-[0_0_12px_rgba(229,57,53,0.8)] font-bold scale-105'
                          : 'text-gray-300 hover:bg-[#2b3340] hover:text-white'
                      }`}
                    >
                      {day}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: ASIGNACIÓN Y DISPONIBILIDAD */}
        <div className="bg-[#181b20] border border-[#282e38] rounded-xl p-5 space-y-6 shadow-xl flex flex-col justify-between">
          <div className="space-y-5">
            <h2 className="text-sm font-semibold tracking-wider text-gray-200 uppercase flex items-center gap-2 border-b border-[#252b36] pb-2">
              Asignación y Disponibilidad
            </h2>

            {/* HORNOS DISPONIBLES */}
            <div>
              <label className="block text-xs font-medium text-gray-400 mb-2 flex items-center gap-1.5">
                <span>🎛️ HORNOS DISPONIBLES</span>
              </label>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                {furnaces.map((furnace) => {
                  const isSelected = selectedFurnaceId === furnace.id;
                  const isOccupied = furnace.status === 'EN PROCESO';
                  const isMaintenance = furnace.status === 'MANTENIMIENTO';

                  return (
                    <div
                      key={furnace.id}
                      onClick={() => !isOccupied && setSelectedFurnaceId(furnace.id)}
                      className={`p-3.5 rounded-lg border transition-all cursor-pointer relative flex flex-col justify-between min-h-[110px] ${
                        isSelected
                          ? 'bg-[#221c17] border-[#e65100] shadow-[0_0_15px_rgba(230,81,0,0.25)]'
                          : 'bg-[#1e2229] border-[#2c333f] hover:border-[#3d4655]'
                      } ${isOccupied ? 'opacity-85' : ''}`}
                    >
                      {/* Top icon and red indicator if occupied */}
                      <div className="flex items-center justify-between">
                        <div className="p-1 rounded bg-[#15181e] text-orange-400">
                          <Flame className="w-5 h-5 text-[#f57c00]" />
                        </div>
                        {isOccupied && (
                          <span className="w-2.5 h-2.5 rounded-full bg-red-500 shadow-[0_0_6px_rgba(239,68,68,0.9)] animate-pulse" />
                        )}
                      </div>

                      {/* Furnace name & capacity */}
                      <div className="mt-2">
                        <div className="font-bold text-xs text-white tracking-wide">
                          {furnace.name} ({furnace.capacity})
                        </div>
                        <div className="text-[11px] mt-0.5 font-medium">
                          {isOccupied && (
                            <span className="text-red-400">OCUPADO - {furnace.activeOT}</span>
                          )}
                          {!isOccupied && !isMaintenance && (
                            <span className="text-green-400">DISPONIBLE</span>
                          )}
                          {isMaintenance && (
                            <span className="text-gray-400">MANTENIMIENTO</span>
                          )}
                        </div>
                      </div>

                      {/* Toggle switch representation */}
                      <div className="mt-2 flex items-center justify-end">
                        <div
                          className={`w-9 h-5 rounded-full p-0.5 transition-colors duration-200 ease-in-out flex items-center ${
                            isSelected && !isOccupied
                              ? 'bg-[#f57c00] justify-end'
                              : 'bg-[#2c333f] justify-start'
                          }`}
                        >
                          <div className="w-4 h-4 rounded-full bg-white shadow-sm" />
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* NOTAS / ESPECIFICACIONES */}
            <div>
              <label className="block text-xs font-medium text-gray-400 mb-1.5 flex items-center gap-1.5">
                <span>📄 NOTAS / ESPECIFICACIONES</span>
              </label>
              <textarea
                rows={4}
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Notas de temperatura, desoxidación, inoculantes, tiempo de colada..."
                className="w-full bg-[#1e2229] border border-[#2c333f] text-gray-200 text-sm rounded-lg p-3 focus:border-[#e53935] focus:outline-none transition resize-none font-sans"
              />
            </div>
          </div>

          {/* Bottom Button */}
          <div className="pt-4 flex justify-end">
            <button
              type="submit"
              className="bg-gradient-to-r from-[#d32f2f] to-[#e53935] hover:from-[#b71c1c] hover:to-[#d32f2f] text-white font-semibold text-sm px-6 py-3 rounded-lg shadow-[0_4px_15px_rgba(229,57,53,0.4)] transition-all flex items-center gap-2 transform active:scale-98"
            >
              <Plus className="w-4 h-4 stroke-[3]" />
              <span>GENERAR ORDEN DE TRABAJO</span>
            </button>
          </div>
        </div>
      </form>
    </div>
  );
}
