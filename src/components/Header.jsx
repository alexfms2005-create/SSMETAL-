import React from 'react';

export default function Header({ activeTab, setActiveTab, currentTime }) {
  const tabs = [
    { id: 'alta', label: 'Alta de OT' },
    { id: 'proceso', label: 'Proceso de Fundición' },
    { id: 'terminadas', label: 'OTs Terminadas' },
  ];

  return (
    <header className="bg-[#121418] border-b border-[#252a33] px-6 py-2.5 flex items-center justify-between select-none">
      {/* Brand logo & name */}
      <div className="flex items-center space-x-3">
        <div className="flex items-center">
          <img 
            src="/Imagenes/Logo.png" 
            alt="SSMF SS Metal Foundry" 
            className="h-10 w-auto object-contain cursor-pointer transition hover:opacity-95"
            onError={(e) => {
              // Fallback if image fails
              e.currentTarget.style.display = 'none';
              const fallback = document.getElementById('brand-fallback');
              if (fallback) fallback.style.display = 'flex';
            }}
          />
          <div id="brand-fallback" className="hidden items-center space-x-2">
            <div className="border border-red-600 px-1.5 py-0.5 rounded text-red-500 font-bold text-xs tracking-wider">
              SSMF
            </div>
            <span className="font-bold tracking-wider text-sm text-gray-200">SS METAL FOUNDRY</span>
          </div>
        </div>
      </div>

      {/* Navigation tabs */}
      <nav className="flex items-center space-x-1 sm:space-x-4">
        {tabs.map((tab) => {
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`relative py-2 px-3 text-sm font-medium transition-all duration-150 ${
                isActive
                  ? 'text-white'
                  : 'text-gray-400 hover:text-gray-200'
              }`}
            >
              {tab.label}
              {isActive && (
                <span className="absolute bottom-[-11px] left-0 right-0 h-[3px] bg-[#e53935] shadow-[0_0_8px_rgba(229,57,53,0.8)] rounded-t-sm" />
              )}
            </button>
          );
        })}
      </nav>

      {/* User profile & real-time date/clock */}
      <div className="flex items-center space-x-6 text-xs text-gray-300">
        <div className="flex items-center space-x-2">
          <span>Usuario: <strong className="text-white font-semibold">Administrador</strong></span>
          <button 
            onClick={() => alert("Sesión de demostración activa en SS Metal Foundry.")}
            className="ml-2 bg-[#252b35] hover:bg-[#303844] text-gray-300 hover:text-white px-2.5 py-1 rounded text-xs transition border border-[#374151]"
          >
            Cerrar sesión
          </button>
        </div>

        <div className="text-gray-400 font-mono tracking-wide hidden md:block">
          {currentTime || '11/Nov/2026, 13:06:00'}
        </div>
      </div>
    </header>
  );
}
