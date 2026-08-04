/* screenshots.js — ProDirt app-page screenshot strip.
 *
 * Drop this into any page:
 *   <section class="app-shots" data-dir="shots" data-max="10"
 *            data-title="Screenshots" hidden></section>
 *   <script src="/screenshots.js" defer></script>
 *
 * It probes <data-dir>/1.png, 2.png, … in order and builds a bare,
 * horizontally-scrolling strip. If no images exist the section stays hidden,
 * so it is safe to ship before any screenshots are added — each app "lights
 * up" the moment its shots/ folder is filled. Name files contiguously
 * (1.png, 2.png, 3.png…); the probe stops at the first gap.
 *
 * data-orientation="landscape" shortens the frame height for wide shots
 * (e.g. Trailer Boss). Default is portrait.
 */
(function () {
  var STYLE_ID = "app-shots-style";
  if (!document.getElementById(STYLE_ID)) {
    var css =
      ".app-shots{margin:2rem 0}" +
      ".app-shots__title{font-size:1.5rem;font-weight:700;margin:0 0 1rem;color:#333}" +
      ".app-shots__strip{display:flex;gap:14px;overflow-x:auto;padding:4px 2px 16px;" +
        "scroll-snap-type:x mandatory;-webkit-overflow-scrolling:touch;scrollbar-width:thin}" +
      ".app-shots__strip figure{flex:0 0 auto;margin:0;scroll-snap-align:start}" +
      ".app-shots__strip img{height:460px;width:auto;border-radius:16px;display:block;" +
        "box-shadow:0 6px 20px rgba(0,0,0,.28);background:rgba(0,0,0,.06)}" +
      ".app-shots[data-orientation='landscape'] .app-shots__strip img{height:300px}" +
      "@media (max-width:600px){.app-shots__strip img{height:380px}" +
        ".app-shots[data-orientation='landscape'] .app-shots__strip img{height:220px}}";
    var style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = css;
    document.head.appendChild(style);
  }

  function build(section) {
    var dir = section.getAttribute("data-dir") || "shots";
    var max = parseInt(section.getAttribute("data-max") || "10", 10);
    var title = section.getAttribute("data-title") || "Screenshots";

    var strip = document.createElement("div");
    strip.className = "app-shots__strip";
    var revealed = false;

    function reveal() {
      if (revealed) return;
      revealed = true;
      var h = document.createElement("h2");
      h.className = "app-shots__title";
      h.textContent = title;
      section.appendChild(h);
      section.appendChild(strip);
      section.hidden = false;
    }

    // Sequential probe using detached Image objects (not subject to lazy-load
    // or the section's hidden state); stops at the first missing index.
    function probe(n) {
      if (n > max) return;
      var test = new Image();
      test.onload = function () {
        reveal();
        var fig = document.createElement("figure");
        var img = document.createElement("img");
        img.loading = "lazy";
        img.decoding = "async";
        img.alt = title + " " + n;
        img.src = test.src;
        fig.appendChild(img);
        strip.appendChild(fig);
        probe(n + 1);
      };
      test.onerror = function () { /* gap reached — stop */ };
      test.src = dir + "/" + n + ".png";
    }
    probe(1);
  }

  function init() {
    var sections = document.querySelectorAll(".app-shots");
    for (var i = 0; i < sections.length; i++) build(sections[i]);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
