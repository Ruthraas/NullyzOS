// NullyzOS — documentação. Sem dependências e sem nada de fora: menu no celular, busca na
// lateral, abas, copiar, seletor de rices, índice da página e os passos marcados ao ler.
"use strict";

document.addEventListener("DOMContentLoaded", () => {
  // Menu (celular)
  const menu = document.querySelector(".menu");
  const lateral = document.getElementById("lateral");
  if (menu && lateral) {
    const abrir = sim => { lateral.classList.toggle("aberta", sim); menu.setAttribute("aria-expanded", String(sim)); };
    menu.addEventListener("click", () => abrir(!lateral.classList.contains("aberta")));
    lateral.addEventListener("click", e => { if (e.target.closest("a")) abrir(false); });
    document.addEventListener("keydown", e => { if (e.key === "Escape") abrir(false); });
  }

  // Busca na lateral: filtra os itens (sem acento e sem maiúscula)
  const filtro = document.getElementById("filtro");
  if (filtro && lateral) {
    const sem = s => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
    const itens = [...lateral.querySelectorAll("a")];
    filtro.addEventListener("input", () => {
      const q = sem(filtro.value.trim());
      itens.forEach(a => { a.hidden = q !== "" && !sem(a.textContent).includes(q); });
      lateral.querySelectorAll(".grupo").forEach(g => {
        let n = g.nextElementSibling, algum = false;
        while (n && n.tagName === "A") { if (!n.hidden) algum = true; n = n.nextElementSibling; }
        g.hidden = !algum;
      });
    });
    filtro.addEventListener("keydown", e => {
      if (e.key !== "Enter") return;
      const primeiro = itens.find(a => !a.hidden);
      if (primeiro) window.location.href = primeiro.href;
    });
  }

  // Abas (setas também)
  document.querySelectorAll(".abas").forEach(abas => {
    const botoes = [...abas.querySelectorAll('[role="tab"]')];
    const ativar = (b, foco) => {
      botoes.forEach(x => {
        const sim = x === b;
        x.setAttribute("aria-selected", String(sim));
        x.tabIndex = sim ? 0 : -1;
        document.getElementById(x.getAttribute("aria-controls")).hidden = !sim;
      });
      if (foco) b.focus();
    };
    botoes.forEach((b, i) => {
      b.addEventListener("click", () => ativar(b));
      b.addEventListener("keydown", e => {
        const passo = { ArrowRight: 1, ArrowLeft: -1 }[e.key];
        if (passo) { e.preventDefault(); ativar(botoes[(i + passo + botoes.length) % botoes.length], true); }
      });
    });
    if (/Windows/i.test(navigator.userAgent)) {
      const win = botoes.find(b => /Windows/.test(b.textContent));
      if (win) ativar(win);
    }
  });

  // Copiar
  document.querySelectorAll(".copiar").forEach(b => b.addEventListener("click", async () => {
    const texto = b.parentElement.querySelector("code").textContent;
    try { await navigator.clipboard.writeText(texto); b.textContent = "Copiado"; }
    catch { b.textContent = "Selecione e copie"; }
    setTimeout(() => { b.textContent = "Copiar"; }, 1600);
  }));

  // Seletor de rices: troca o print e a legenda
  const tela = document.getElementById("tela-rice");
  const legenda = document.getElementById("rice-texto");
  const rices = [...document.querySelectorAll(".rices [data-rice]")];
  const escolher = (b, foco) => {
    rices.forEach(x => { const sim = x === b; x.setAttribute("aria-checked", String(sim)); x.tabIndex = sim ? 0 : -1; });
    if (foco) b.focus();
    if (legenda) legenda.textContent = b.dataset.texto || "";
    if (!tela) return;
    const src = `img/telas/tela-${b.dataset.rice}.webp`;
    if (tela.getAttribute("src") === src) return;
    const nova = new Image();
    nova.src = src;
    tela.classList.add("trocando");
    Promise.all([nova.decode().catch(() => {}), new Promise(r => setTimeout(r, 120))]).then(() => {
      tela.src = src;
      tela.alt = `O rice ${b.textContent.trim()} aplicado.`;
      tela.classList.remove("trocando");
    });
  };
  rices.forEach((b, i) => {
    b.tabIndex = i === 0 ? 0 : -1;
    b.addEventListener("click", () => escolher(b));
    b.addEventListener("keydown", e => {
      const passo = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 }[e.key];
      if (passo) { e.preventDefault(); escolher(rices[(i + passo + rices.length) % rices.length], true); }
    });
  });

  // "Nesta página" e os passos já lidos
  if ("IntersectionObserver" in window) {
    const links = [...document.querySelectorAll(".indice a")];
    const alvos = links.map(a => document.querySelector(a.getAttribute("href"))).filter(Boolean);
    const olho = new IntersectionObserver(entradas => entradas.forEach(e => {
      if (!e.isIntersecting) return;
      links.forEach(a => a.classList.toggle("ativo", a.getAttribute("href") === "#" + e.target.id));
    }), { rootMargin: "-90px 0px -65% 0px" });
    alvos.forEach(t => olho.observe(t));

    const passos = document.querySelectorAll(".passo");
    const visto = new IntersectionObserver(entradas => entradas.forEach(e => {
      if (e.isIntersecting) { e.target.classList.add("visto"); visto.unobserve(e.target); }
    }), { rootMargin: "0px 0px -55% 0px" });
    passos.forEach(p => visto.observe(p));
  }
});
