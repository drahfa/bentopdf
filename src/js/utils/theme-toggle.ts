export function initThemeToggle(): void {
  const saved = localStorage.getItem('theme') || 'light';
  if (saved === 'light') {
    document.documentElement.classList.add('light-theme');
  }
  updateIcons(saved);

  document.querySelectorAll('.theme-toggle-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const isLight = document.documentElement.classList.toggle('light-theme');
      const theme = isLight ? 'light' : 'dark';
      localStorage.setItem('theme', theme);
      updateIcons(theme);
    });
  });
}

function updateIcons(theme: string): void {
  document.querySelectorAll('.theme-toggle-btn').forEach((btn) => {
    const sunIcon = btn.querySelector('.theme-icon-sun');
    const moonIcon = btn.querySelector('.theme-icon-moon');
    if (sunIcon && moonIcon) {
      if (theme === 'light') {
        sunIcon.classList.add('hidden');
        moonIcon.classList.remove('hidden');
      } else {
        sunIcon.classList.remove('hidden');
        moonIcon.classList.add('hidden');
      }
    }
  });
}
