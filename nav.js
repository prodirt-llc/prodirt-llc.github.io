/* ProDirt shared top nav + heading font - injected on every page.
   Edit this one file and every page updates. */
(function () {
  /* ---- Heading font: Barlow (headings only, body stays system font) ---- */
  var pc1 = document.createElement('link');
  pc1.rel = 'preconnect';
  pc1.href = 'https://fonts.googleapis.com';
  var pc2 = document.createElement('link');
  pc2.rel = 'preconnect';
  pc2.href = 'https://fonts.gstatic.com';
  pc2.crossOrigin = 'anonymous';
  var font = document.createElement('link');
  font.rel = 'stylesheet';
  font.href = 'https://fonts.googleapis.com/css2?family=Barlow:wght@600;700&display=swap';
  document.head.appendChild(pc1);
  document.head.appendChild(pc2);
  document.head.appendChild(font);

  /* ---- Styles ---- */
  var css = [
    "h1,h2,h3,h4,h5,h6{font-family:'Barlow',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;}",
    '.pd-nav{position:sticky;top:0;z-index:1000;background:#1a3a1a;',
    'border-bottom:2px solid #ff6b35;box-shadow:0 2px 8px rgba(0,0,0,0.25);}',
    '.pd-nav-inner{max-width:1200px;margin:0 auto;padding:0 1rem;height:56px;',
    'display:flex;align-items:center;justify-content:space-between;}',
    '.pd-nav-logo{display:flex;align-items:center;}',
    '.pd-nav-logo img{height:30px;width:auto;display:block;}',
    '.pd-nav-links{display:flex;align-items:center;gap:1.5rem;}',
    ".pd-nav-links a{color:#e8f0e8;text-decoration:none;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;",
    'font-size:0.95rem;font-weight:600;letter-spacing:0.2px;transition:color 0.2s;}',
    '.pd-nav-links a:hover{color:#ff6b35;}',
    'html{scroll-padding-top:70px;}',
    '@media (max-width:480px){',
    '.pd-nav-inner{height:50px;}',
    '.pd-nav-logo img{height:26px;}',
    '.pd-nav-links{gap:1rem;}',
    '.pd-nav-links a{font-size:0.9rem;}}'
  ].join('');

  var style = document.createElement('style');
  style.textContent = css;
  document.head.appendChild(style);

  /* ---- Nav bar ---- */
  var nav = document.createElement('header');
  nav.className = 'pd-nav';
  nav.innerHTML =
    '<div class="pd-nav-inner">' +
      '<a class="pd-nav-logo" href="/" aria-label="ProDirt LLC home">' +
        '<img src="/logo-white.png" alt="ProDirt LLC">' +
      '</a>' +
      '<nav class="pd-nav-links" aria-label="Primary">' +
        '<a href="/#apps">Apps</a>' +
        '<a href="/blog/">Blog</a>' +
        '<a href="mailto:prodirt.co@gmail.com">Contact</a>' +
      '</nav>' +
    '</div>';

  function mount() {
    document.body.insertBefore(nav, document.body.firstChild);
  }
  if (document.body) {
    mount();
  } else {
    document.addEventListener('DOMContentLoaded', mount);
  }
})();
