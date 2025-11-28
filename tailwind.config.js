module.exports = {
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    themes: [
      {
        signpaw: {
          'color-scheme': 'light',
          // MEDICALLY OPTIMIZED COLORS - INDIGO/PURPLE THEME
          // Based on ophthalmology research: muted colors reduce eye strain
          
          // Primary - Muted indigo (20% less saturated than indigo-600)
          // MEDICAL: Reduced saturation decreases blue light intensity
          primary: '#5B5FC7',  // Muted indigo (was #6366f1)
          
          // Secondary - Muted purple (20% less saturated than purple-600)
          // MEDICAL: Softer purple reduces visual stimulation
          secondary: '#7C3AED',  // Muted purple (was #9333ea)
          
          // Accent - Muted purple-violet (complements primary/secondary)
          accent: '#8B5CF6',  // Muted purple-violet
          
          // Neutral - Soft dark gray (MEDICAL: Better than pure black)
          neutral: '#334155',  // Slate-700 (softer contrast)
          
          // Base backgrounds - Slate colors (MEDICAL: Neutral reduces eye strain)
          'base-100': '#F8FAFC',  // Slate-50 (excellent - reduces glare)
          'base-200': '#F1F5F9',  // Slate-100 (slightly darker for cards)
          'base-300': '#E2E8F0',  // Slate-200 (borders and dividers)
          
          // Text colors - Softened contrast (MEDICAL: Reduces eye strain)
          'base-content': '#1E293B',  // Slate-800 (softer than slate-900)
          'base-content-secondary': '#475569',  // Slate-600 (perfect for secondary text)
          
          // Status colors - Muted for eye comfort
          success: '#10B981',  // Emerald-500 (accessible green)
          warning: '#F59E0B',  // Amber-500 (muted yellow)
          error: '#EF4444',    // Red-500 (standard error)
          info: '#5B5FC7',      // Matches primary (muted indigo)
          
          '--rounded-btn': '1.9rem',
          '--tab-border': '2px',
          '--tab-radius': '.5rem'
        }
      }
    ]
  }
}
