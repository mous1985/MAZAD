/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class', // Active le mode sombre avec la classe "dark"
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'], // Définit les chemins pour le scan des classes Tailwind
  theme: {
    extend: {
      colors: {
        primary: '#1E88E5', // Couleur primaire personnalisée
        secondary: '#1565C0', // Couleur secondaire personnalisée
        background: '#212121', // Fond pour le mode sombre
        foreground: '#E0F7FA', // Couleur de texte pour le mode sombre
      },
    },
  },
  plugins: [], // Plugins additionnels si nécessaires
};
