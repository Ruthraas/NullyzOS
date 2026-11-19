// NullyzOS — site. Sem dependências e sem nada de fora. Três coisas:
//  1. o seletor de rices pinta a página e troca a tela fixa;
//  2. a tela fixa acompanha a seção que está sendo lida;
//  3. entradas das seções e o comando de conferência por sistema.
"use strict";
document.documentElement.classList.add("js");

const reduzido = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

document.addEventListener("DOMContentLoaded", () => {
  const corpo = document.body;
  const tela = document.getElementById("tela");
  const legenda = document.getElementById("legenda");
  const descRice = document.getElementById("rice-desc");

  const NOMES = { nulo: "Nulo", papel: "Papel", ouro: "Ouro", brasa: "Brasa", cru: "Cru",
                  areia: "Areia", musgo: "Musgo", sol: "Sol", mono: "Mono" };
  const TELAS = {
    wallpaper: ["img/tela-wallpaper.webp", "Cores do wallpaper: a paleta inteira saiu da imagem de fundo.",
                "NullyzOS com as cores tiradas do wallpaper."],
    instalador: ["img/tela-instalador.webp", "O instalador: idioma, teclado, desktop e visual.",
                 "Instalador do NullyzOS na etapa de escolher o visual, com a prévia de cada rice."]
  };
  let rice = "nulo";
  let atual = "";

  // Troca a imagem da tela fixa com uma passagem curta (sem piscar o que já está lá)
  function mostrar(src, alt, texto) {
    if (!tela || tela.getAttribute("src") === src) return;
    const troca = () => {
      tela.setAttribute("src", src);
      tela.setAttribute("alt", alt);
      if (legenda) legenda.textContent = texto;
    };
    if (reduzido) { troca(); return; }
    const nova = new Image();
    nova.src = src;
    tela.classList.add("trocando");
    const fim = () => { troca(); requestAnimationFrame(() => tela.classList.remove("trocando")); };
    Promise.all([nova.decode().catch(() => {}), new Promise(r => setTimeout(r, 220))]).then(fim);
  }
  function telaDoRice() {
    const nome = NOMES[rice];
    mostrar(`img/tela-${rice}.webp`,
            `Área de trabalho do NullyzOS com o rice ${nome}.`,
            `Hyprland com o rice ${nome}.`);
  }
  function irPara(chave) {
    if (chave === atual) return;
    atual = chave;
    if (TELAS[chave]) mostrar(TELAS[chave][0], TELAS[chave][2], TELAS[chave][1]);
    else telaDoRice();
  }

  // 1. Seletor de rices (setas também, como um grupo de rádio)
  const botoes = [...document.querySelectorAll(".seletor [data-rice]")];
  function escolher(b, foco) {
    rice = b.dataset.rice;
    botoes.forEach(x => {
      const sim = x === b;
      x.setAttribute("aria-checked", String(sim));
      x.tabIndex = sim ? 0 : -1;
    });
    corpo.dataset.rice = rice;
    if (descRice) descRice.textContent = b.dataset.legenda || "";
    atual = "";
    irPara("rice");
    if (foco) b.focus();
  }
  botoes.forEach((b, i) => {
    b.tabIndex = i === 0 ? 0 : -1;
    b.addEventListener("click", () => escolher(b));
    b.addEventListener("keydown", e => {
      const passo = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 }[e.key];
      if (!passo) return;
      e.preventDefault();
      escolher(botoes[(i + passo + botoes.length) % botoes.length], true);
    });
  });

  // 2. A tela fixa acompanha a seção do meio da tela
  const secoes = document.querySelectorAll(".leitura > section");
  if ("IntersectionObserver" in window) {
    const olho = new IntersectionObserver(entradas => {
      entradas.forEach(e => {
        if (e.isIntersecting) irPara(e.target.dataset.tela || "rice");
      });
    }, { rootMargin: "-45% 0px -45% 0px" });
    secoes.forEach(s => olho.observe(s));
  }

  // 3a. Entradas: título, texto e imagem de cada seção, em ordem, uma vez
  const partes = document.querySelectorAll(
    "main section h2, main section > p, .leitura section > p, .seletor, .par, .campo > *, .seguranca dl > div, .quadro, .leve > *, .feito li, .perguntas .texto p, .janela, .fecho > *");
  if (!reduzido && "IntersectionObserver" in window) {
    const grupos = new Map();
    partes.forEach(p => {
      const s = p.closest("section") || corpo;
      const n = grupos.get(s) || 0;
      grupos.set(s, n + 1);
      p.style.setProperty("--i", String(Math.min(n, 8)));
      p.classList.add("entra");
    });
    const olhoEntrada = new IntersectionObserver(entradas => {
      entradas.forEach(e => {
        if (!e.isIntersecting) return;
        e.target.classList.add("dentro");
        olhoEntrada.unobserve(e.target);
      });
    }, { rootMargin: "0px 0px -8% 0px" });
    // Dois quadros depois: o estado escondido já foi desenhado, então a entrada anima
    requestAnimationFrame(() => requestAnimationFrame(() => partes.forEach(p => olhoEntrada.observe(p))));
  }

  // 3b. Comando para conferir a ISO, conforme o sistema de quem baixa
  const cmd = document.getElementById("cmd");
  const COMANDOS = {
    linux: "sha256sum -c SHA256SUMS",
    windows: "Get-FileHash .\\nullyzos-*.iso -Algorithm SHA256"
  };
  const opcoes = [...document.querySelectorAll(".escolha [data-so]")];
  opcoes.forEach(b => b.addEventListener("click", () => {
    opcoes.forEach(x => x.setAttribute("aria-checked", String(x === b)));
    if (cmd) cmd.textContent = COMANDOS[b.dataset.so];
  }));
  if (/Windows/i.test(navigator.userAgent)) opcoes.find(b => b.dataset.so === "windows")?.click();
});
