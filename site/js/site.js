// NullyzOS — página inicial. Sem dependências e sem nada de fora.
"use strict";
document.documentElement.classList.add("js");

const reduzido = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

document.addEventListener("DOMContentLoaded", () => {
  // ---- Navbar: encolhe ao rolar; a pílula segue o link sob o mouse ou a seção lida ----------
  const nav = document.getElementById("nav");
  const links = [...document.querySelectorAll(".nav-links a[data-secao]")];
  const pilula = document.querySelector(".nav-pilula");
  let secaoAtual = links[0];

  const moverPilula = a => {
    if (!pilula || !a) return;
    pilula.style.width = `${a.offsetWidth}px`;
    pilula.style.transform = `translateX(${a.offsetLeft}px)`;
    pilula.style.opacity = "1";
  };
  const marcar = a => {
    secaoAtual = a;
    links.forEach(x => x.classList.toggle("ativo", x === a));
    moverPilula(a);
  };
  links.forEach(a => a.addEventListener("mouseenter", () => moverPilula(a)));
  document.querySelector(".nav-links")?.addEventListener("mouseleave", () => moverPilula(secaoAtual));
  window.addEventListener("resize", () => moverPilula(secaoAtual));
  requestAnimationFrame(() => moverPilula(secaoAtual));

  const aoRolar = () => nav?.classList.toggle("rolou", window.scrollY > 40);
  window.addEventListener("scroll", aoRolar, { passive: true });
  aoRolar();

  if ("IntersectionObserver" in window) {
    const olhoSecao = new IntersectionObserver(entradas => {
      entradas.forEach(e => {
        if (!e.isIntersecting) return;
        const a = links.find(x => x.dataset.secao === e.target.id);
        if (a) marcar(a);
      });
    }, { rootMargin: "-45% 0px -50% 0px" });
    links.forEach(a => { const s = document.getElementById(a.dataset.secao); if (s) olhoSecao.observe(s); });
  }

  // Relógio, como na barra do sistema
  const relogio = document.getElementById("relogio");
  if (relogio) {
    const fmt = new Intl.DateTimeFormat("pt-BR", { weekday: "short", day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });
    const tic = () => { relogio.textContent = fmt.format(new Date()).replace(/\./g, ""); };
    tic();
    setInterval(tic, 15000);
  }

  // Menu do celular
  const botaoMenu = document.querySelector(".nav-menu");
  const menu = document.getElementById("menu-celular");
  if (botaoMenu && menu) {
    const abrir = sim => {
      menu.hidden = !sim;
      botaoMenu.setAttribute("aria-expanded", String(sim));
      botaoMenu.setAttribute("aria-label", sim ? "Fechar menu" : "Abrir menu");
    };
    botaoMenu.addEventListener("click", () => abrir(menu.hidden));
    menu.addEventListener("click", e => { if (e.target.closest("a")) abrir(false); });
    document.addEventListener("keydown", e => { if (e.key === "Escape") abrir(false); });
  }

  // ---- Carrossel ---------------------------------------------------------------------------
  const trilho = document.getElementById("trilho");
  const pontos = document.getElementById("pontos");
  const slides = trilho ? [...trilho.children] : [];
  let atual = 0;
  let pausa = false;

  const botoes = slides.map((s, i) => {
    const b = document.createElement("button");
    b.type = "button";
    b.setAttribute("role", "tab");
    b.setAttribute("aria-label", s.querySelector("h3").textContent);
    b.addEventListener("click", () => ir(i));
    pontos?.append(b);
    return b;
  });
  const marcarSlide = i => {
    atual = i;
    botoes.forEach((b, j) => b.setAttribute("aria-selected", String(j === i)));
    slides.forEach((s, j) => s.classList.toggle("atual", j === i));
  };
  function ir(i) {
    if (!trilho) return;
    const n = (i + slides.length) % slides.length;
    trilho.scrollTo({ left: slides[n].offsetLeft, behavior: reduzido ? "auto" : "smooth" });
    marcarSlide(n);
  }
  document.getElementById("anterior")?.addEventListener("click", () => ir(atual - 1));
  document.getElementById("proximo")?.addEventListener("click", () => ir(atual + 1));
  if (trilho) {
    // Arrastar com o dedo também troca o slide: acompanha a rolagem do trilho
    let espera;
    trilho.addEventListener("scroll", () => {
      clearTimeout(espera);
      espera = setTimeout(() => marcarSlide(Math.round(trilho.scrollLeft / trilho.clientWidth)), 80);
    }, { passive: true });
    const carrossel = document.getElementById("carrossel");
    carrossel.addEventListener("mouseenter", () => { pausa = true; });
    carrossel.addEventListener("mouseleave", () => { pausa = false; });
    carrossel.addEventListener("focusin", () => { pausa = true; });
    carrossel.addEventListener("focusout", () => { pausa = false; });
    carrossel.addEventListener("keydown", e => {
      if (e.key === "ArrowRight") ir(atual + 1);
      if (e.key === "ArrowLeft") ir(atual - 1);
    });
    marcarSlide(0);
    if (!reduzido) setInterval(() => { if (!pausa && !document.hidden) ir(atual + 1); }, 5000);
  }

  // ---- Copiar e comando conforme o sistema ----------------------------------------------------
  const cmd = document.getElementById("cmd");
  if (cmd && /Windows/i.test(navigator.userAgent)) cmd.textContent = "Get-FileHash .\\nullyzos-*.iso -Algorithm SHA256";
  document.querySelectorAll(".copiar").forEach(b => b.addEventListener("click", async () => {
    const alvo = document.getElementById(b.dataset.copiar);
    try { await navigator.clipboard.writeText(alvo.textContent); b.textContent = "Copiado"; }
    catch { b.textContent = "Selecione e copie"; }
    setTimeout(() => { b.textContent = "Copiar"; }, 1600);
  }));

  // ---- Entradas ao rolar --------------------------------------------------------------------
  const partes = document.querySelectorAll(".sobre-texto > *, .carrossel, .baixar-topo > *, .passos li, .baixar-acoes, .baixar-nota, .rodape-colunas > div, .rodape-nome");
  if (!reduzido && "IntersectionObserver" in window) {
    const grupos = new Map();
    partes.forEach(p => {
      const s = p.closest("section, footer");
      const n = grupos.get(s) || 0;
      grupos.set(s, n + 1);
      p.style.setProperty("--i", String(Math.min(n, 6)));
      p.classList.add("entra");
    });
    const olho = new IntersectionObserver(entradas => entradas.forEach(e => {
      if (!e.isIntersecting) return;
      e.target.classList.add("dentro");
      olho.unobserve(e.target);
    }), { rootMargin: "0px 0px -8% 0px" });
    requestAnimationFrame(() => requestAnimationFrame(() => partes.forEach(p => olho.observe(p))));
  }
});
