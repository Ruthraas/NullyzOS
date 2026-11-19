// NullyzOS — site. Sem dependências e sem nada de fora: menu no celular, abas, botões de
// copiar, seletor de rices e o índice "Nesta página" acompanhando a leitura.
"use strict";

document.addEventListener("DOMContentLoaded", () => {
  // Menu (celular)
  const menu = document.querySelector(".menu");
  const lateral = document.getElementById("lateral");
  if (menu && lateral) {
    const fechar = () => { lateral.classList.remove("aberta"); menu.setAttribute("aria-expanded", "false"); };
    menu.addEventListener("click", () => {
      const abrir = !lateral.classList.contains("aberta");
      lateral.classList.toggle("aberta", abrir);
      menu.setAttribute("aria-expanded", String(abrir));
    });
    lateral.addEventListener("click", e => { if (e.target.closest("a")) fechar(); });
    document.addEventListener("keydown", e => { if (e.key === "Escape") fechar(); });
  }

  // Abas (com setas, como manda o padrão de abas)
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
  document.querySelectorAll(".copiar").forEach(b => {
    b.addEventListener("click", async () => {
      const texto = b.parentElement.querySelector("code").textContent;
      try {
        await navigator.clipboard.writeText(texto);
        b.textContent = "Copiado";
      } catch {
        b.textContent = "Selecione e copie";
      }
      setTimeout(() => { b.textContent = "Copiar"; }, 1600);
    });
  });

  // Seletor de rices
  const tela = document.getElementById("tela-rice");
  const rices = [...document.querySelectorAll(".rices [data-rice]")];
  const escolher = (b, foco) => {
    rices.forEach(x => {
      const sim = x === b;
      x.setAttribute("aria-checked", String(sim));
      x.tabIndex = sim ? 0 : -1;
    });
    if (foco) b.focus();
    if (!tela) return;
    const nome = b.textContent.trim();
    const src = `img/tela-${b.dataset.rice}.webp`;
    if (tela.getAttribute("src") === src) return;
    const nova = new Image();
    nova.src = src;
    tela.classList.add("trocando");
    Promise.all([nova.decode().catch(() => {}), new Promise(r => setTimeout(r, 150))]).then(() => {
      tela.src = src;
      tela.alt = `O rice ${nome} aplicado.`;
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

  // "Nesta página" marca a seção que está sendo lida
  const links = [...document.querySelectorAll(".indice a")];
  const alvos = links.map(a => document.querySelector(a.getAttribute("href"))).filter(Boolean);
  if (links.length && "IntersectionObserver" in window) {
    const olho = new IntersectionObserver(entradas => {
      entradas.forEach(e => {
        if (!e.isIntersecting) return;
        links.forEach(a => a.classList.toggle("ativo", a.getAttribute("href") === "#" + e.target.id));
      });
    }, { rootMargin: "-80px 0px -70% 0px" });
    alvos.forEach(t => olho.observe(t));
  }
});
