#!/usr/bin/env python3
"""Gera as páginas da documentação (docs.html, instalar.html, seguranca.html) a partir de
conteudo/<página>.html, dentro da mesma moldura: a janela das Configurações do NullyzOS
(lateral com ícones coloridos, busca, título e linhas), sobre o fundo do sistema.
    python gerar-docs.py
"""
import html
import re
from pathlib import Path

AQUI = Path(__file__).parent

ICONES = {
    "geral": '<path d="M4 6h16M4 12h16M4 18h10"/>',
    "instalar": '<path d="M12 4v11m0 0-4-4m4 4 4-4M5 19h14"/>',
    "requisitos": '<rect x="4" y="5" width="16" height="11" rx="2"/><path d="M9 20h6M12 16v4"/>',
    "rices": '<circle cx="12" cy="12" r="8"/><circle cx="9" cy="10" r="1.3" class="cheio"/><circle cx="13" cy="8" r="1.3" class="cheio"/><circle cx="16" cy="12" r="1.3" class="cheio"/>',
    "desktops": '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 9h18M12 9v10"/>',
    "atalhos": '<rect x="3" y="7" width="18" height="11" rx="2"/><path d="M7 11h1M11 11h1M15 11h1M7 14h10"/>',
    "seguranca": '<path d="M12 3 5 6v5c0 4.5 3 8 7 9 4-1 7-4.5 7-9V6z"/><path d="m9 12 2 2 4-4"/>',
    "perguntas": '<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .9-1 1.5V14"/><circle cx="12" cy="17" r="1" class="cheio"/>',
}

# (grupo, [(rótulo, href, ícone, cor, página)])
MENU = [
    ("Começando", [
        ("Visão geral", "docs.html", "geral", "violeta", "docs"),
        ("Instalar", "instalar.html", "instalar", "violeta", "instalar"),
        ("Requisitos", "docs.html#requisitos", "requisitos", "violeta", None),
    ]),
    ("Usando", [
        ("Rices", "docs.html#rices", "rices", "azul", None),
        ("Hyprland ou KDE", "docs.html#desktops", "desktops", "azul", None),
        ("Atalhos", "docs.html#atalhos", "atalhos", "azul", None),
    ]),
    ("Ajuda", [
        ("Guia de segurança", "seguranca.html", "seguranca", "verde", "seguranca"),
        ("Perguntas", "docs.html#perguntas", "perguntas", "coral", None),
    ]),
]

PAGINAS = {
    "docs": ("Visão geral", "O que é o NullyzOS, do que ele precisa e o que vem nele: rices, desktops, atalhos e perguntas."),
    "instalar": ("Instalar", "Passo a passo para instalar o NullyzOS: baixar e conferir a ISO, gravar no pendrive, instalar com ou sem criptografia e o primeiro login."),
    "seguranca": ("Guia de segurança", "Como manter o seu NullyzOS seguro: atualizações, de onde instalar, senhas, criptografia, backup, firewall e navegador."),
}
ORDEM = ["docs", "instalar", "seguranca"]


def icone(nome, cor):
    return f'<span class="icone {cor}" aria-hidden="true"><svg viewBox="0 0 24 24">{ICONES[nome]}</svg></span>'


def lateral(pagina):
    partes = []
    for grupo, itens in MENU:
        partes.append(f'      <p class="grupo">{grupo}</p>')
        for rotulo, href, ic, cor, pag in itens:
            atual = ' aria-current="page"' if pag == pagina else ""
            partes.append(f'      <a href="{href}"{atual}>{icone(ic, cor)}<span>{rotulo}</span></a>')
    return "\n".join(partes)


def indice(corpo):
    titulos = re.findall(r'<h2 id="([^"]+)">(.*?)</h2>', corpo)
    if not titulos:
        titulos = re.findall(r'<li class="passo" id="([^"]+)">.*?<h2>(.*?)</h2>', corpo, re.S)
    return "\n".join(f'      <a href="#{i}">{re.sub("<[^>]+>", "", t)}</a>' for i, t in titulos)


def navegacao(pagina):
    i = ORDEM.index(pagina)
    ant = ORDEM[i - 1] if i > 0 else None
    prox = ORDEM[i + 1] if i + 1 < len(ORDEM) else None
    lado = lambda p, txt, cls: (f'<a class="{cls}" href="{p}.html"><span>{txt}</span><strong>{PAGINAS[p][0]}</strong></a>' if p else "<span></span>")
    return f'    <nav class="seguir" aria-label="Páginas">\n      {lado(ant, "Anterior", "ant")}\n      {lado(prox, "Próximo", "prox")}\n    </nav>'


MOLDE = """<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{titulo} · Documentação do NullyzOS</title>
<meta name="description" content="{descricao}">
<meta name="referrer" content="strict-origin-when-cross-origin">
<meta name="color-scheme" content="dark">
<link rel="icon" href="img/nullyz.svg" type="image/svg+xml">
<link rel="preload" href="fonts/Geist-Variable.woff2" as="font" type="font/woff2" crossorigin>
<link rel="stylesheet" href="css/docs.css">
<script src="js/docs.js" defer></script>
</head>
<!-- Gerado por gerar-docs.py a partir de conteudo/{pagina}.html. Não edite à mão. -->
<body>
<a class="pular" href="#conteudo">Pular para o conteúdo</a>
<img class="fundo" src="img/arte/hero.webp" width="2560" height="1440" alt="">

<header class="topo">
  <a class="marca" href="index.html"><img src="img/nullyz.svg" alt="" width="20" height="20"><span>NullyzOS</span></a>
  <span class="selo">Documentação</span>
  <div class="topo-dir">
    <a class="topo-link" href="https://github.com/Ruthraas/NullyzOS" rel="noopener noreferrer">GitHub</a>
    <a class="botao cheio" href="https://github.com/Ruthraas/NullyzOS/releases/latest" rel="noopener noreferrer">Baixar</a>
    <button class="menu" type="button" aria-expanded="false" aria-controls="lateral">Menu</button>
  </div>
</header>

<div class="janela">
  <nav class="lateral" id="lateral" aria-label="Documentação">
    <label class="busca"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="6"/><path d="m20 20-4.5-4.5"/></svg><span class="oculto">Procurar na documentação</span><input id="filtro" type="search" placeholder="Procurar" autocomplete="off"></label>
    <div class="versao"><span class="logo"><img src="img/nullyz.svg" alt="" width="22" height="22"></span><div><strong>NullyzOS 0.2</strong><span>Arch Linux · Hyprland ou KDE</span></div></div>
{lateral}
  </nav>

  <main class="conteudo" id="conteudo">
{corpo}
{seguir}
  </main>

  <aside class="indice" aria-label="Nesta página">
    <p class="grupo">Nesta página</p>
{indice}
  </aside>
</div>

<footer class="rodape">
  <p>NullyzOS · baseado em Arch Linux, sem vínculo com o projeto Arch · sem cookies e sem rastreamento · <a href="index.html">Página inicial</a></p>
</footer>
</body>
</html>
"""


def main():
    for pagina in ORDEM:
        corpo = (AQUI / "conteudo" / f"{pagina}.html").read_text(encoding="utf-8").rstrip("\n")
        titulo, descricao = PAGINAS[pagina]
        saida = MOLDE.format(titulo=titulo, descricao=html.escape(descricao), pagina=pagina,
                             lateral=lateral(pagina), corpo=corpo, seguir=navegacao(pagina), indice=indice(corpo))
        (AQUI / f"{pagina}.html").write_text(saida, encoding="utf-8", newline="\n")
        print(f"{pagina}.html")


if __name__ == "__main__":
    main()
