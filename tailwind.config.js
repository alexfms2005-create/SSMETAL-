/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        foundry: {
          dark: '#111317',
          panel: '#181b20',
          card: '#1e2229',
          border: '#2c323c',
          red: '#e53935',
          'red-dark': '#b71c1c',
          orange: '#f57c00',
          'orange-glow': '#ff9800',
          green: '#2e7d32',
          'green-glow': '#4caf50'
        }
      }
    },
  },
  plugins: [],
}
