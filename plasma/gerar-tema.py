#!/usr/bin/env python3
"""Gera o tema do Plasma "Nullyz Vidro" (desktoptheme) e a decoração de janela Aurorae "Nullyz":

  desktoptheme/NullyzVidro/   painéis, menus, dicas e widgets translúcidos (o KWin desfoca o
                              que fica atrás), cantos grandes, borda clara de 1 px em cima,
                              cores do esquema ativo (ColorScheme-*), então serve no claro e no escuro
  aurorae/Nullyz/             barra de título discreta e botões redondos à esquerda
                              (fechar coral, minimizar âmbar, maximizar verde, em cores Nullyz)

Desenhos feitos do zero (inspiração: vidro do macOS Tahoe; nada da Apple é usado).
    python gerar-tema.py <pasta-de-saída>
Só biblioteca padrão.
"""
import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TOK = json.loads((RAIZ / "branding/tokens.json").read_text(encoding="utf-8"))
ESC = TOK["roles"]["escuro"]

ESTILO = (
    "<style id=\"current-color-scheme\" type=\"text/css\">"
    ".ColorScheme-Background{color:#17171f}.ColorScheme-Text{color:#ededf2}"
    ".ColorScheme-Highlight{color:#9d8cff}</style>"
)


def frame(prefixo, r, opac, borda=True, sombra=0):
    """Moldura em 9 partes (o Plasma estica as bordas e o miolo). r = raio do canto."""
    s = r * 3
    partes = []

    def parte(nome, d, cls="ColorScheme-Background", op=opac, extra=""):
        partes.append(f'<path id="{prefixo}{nome}" class="{cls}" fill="currentColor" '
                      f'fill-opacity="{op}" d="{d}" {extra}/>')

    # cantos: quarto de círculo; bordas e miolo: retângulos
    parte("topleft", f"M0 {r}A{r} {r} 0 0 1 {r} 0V{r}Z")
    parte("topright", f"M{2*r} 0A{r} {r} 0 0 1 {s} {r}H{2*r}Z")
    parte("bottomleft", f"M0 {2*r}H{r}V{s}A{r} {r} 0 0 1 0 {2*r}Z")
    parte("bottomright", f"M{2*r} {2*r}H{s}A{r} {r} 0 0 1 {2*r} {s}Z")
    parte("top", f"M{r} 0H{2*r}V{r}H{r}Z")
    parte("bottom", f"M{r} {2*r}H{2*r}V{s}H{r}Z")
    parte("left", f"M0 {r}H{r}V{2*r}H0Z")
    parte("right", f"M{2*r} {r}H{s}V{2*r}H{2*r}Z")
    parte("center", f"M{r} {r}H{2*r}V{2*r}H{r}Z")
    if borda:
        # brilho de vidro: 1 px claro no topo (fica por cima das partes de cima)
        partes.append(f'<path class="ColorScheme-Text" fill="currentColor" fill-opacity=".14" '
                      f'd="M{r} 0H{2*r}V1H{r}Z"/>')
    return partes


def svg(w, h, corpo):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
            f'{ESTILO}{"".join(corpo)}</svg>\n')


def moldura(r, opac, borda=True, com_mascara=True):
    corpo = frame("", r, opac, borda)
    if com_mascara:
        corpo += frame("mask-", r, 1, False)      # onde o KWin desfoca
    return svg(r * 3, r * 3, corpo)


def desktoptheme(out: Path):
    t = out / "desktoptheme/NullyzVidro"
    (t / "widgets").mkdir(parents=True, exist_ok=True)
    (t / "dialogs").mkdir(parents=True, exist_ok=True)
    (t / "translucent/widgets").mkdir(parents=True, exist_ok=True)
    (t / "translucent/dialogs").mkdir(parents=True, exist_ok=True)
    (t / "metadata.json").write_text(json.dumps({
        "KPackageStructure": "Plasma/Theme",
        "KPlugin": {
            "Authors": [{"Name": "NullyzOS"}],
            "Description": "Vidro do NullyzOS: painéis e menus translúcidos com cantos grandes.",
            "Id": "NullyzVidro", "License": "GPL-3.0-or-later", "Name": "Nullyz Vidro",
            "Version": "0.2", "Website": "https://github.com/Ruthraas/NullyzOS",
        },
        "X-Plasma-API-Minimum-Version": "6.0",
    }, ensure_ascii=False, indent=2), encoding="utf-8")
    # Sem desfoque (efeito desligado): quase opaco. Com desfoque (translucent/): vidro.
    for base, op_painel, op_dialogo in ((t, .94, .96), (t / "translucent", .62, .72)):
        (base / "widgets/panel-background.svg").write_text(moldura(14, op_painel), encoding="utf-8")
        (base / "dialogs/background.svg").write_text(moldura(16, op_dialogo), encoding="utf-8")
        (base / "widgets/tooltip.svg").write_text(moldura(10, op_dialogo), encoding="utf-8")
        (base / "widgets/background.svg").write_text(moldura(18, op_dialogo), encoding="utf-8")
    # Dica de raio para o painel flutuante e cor do realce (o resto vem do esquema de cores)
    (t / "plasmarc").write_text("[ContrastEffect]\nenabled=true\ncontrast=0.9\nintensity=1.1\nsaturation=1.6\n\n"
                                "[BlurBehindEffect]\nenabled=true\n\n[AdaptiveTransparency]\nenabled=true\n",
                                encoding="utf-8")


# ---- Aurorae: decoração ------------------------------------------------------------------------
SIMBOLOS = {
    "close": '<path d="M9.5 9.5l5 5M14.5 9.5l-5 5" stroke="#0e0e13" stroke-opacity=".7" stroke-width="1.4" stroke-linecap="round"/>',
    "minimize": '<path d="M9 12h6" stroke="#0e0e13" stroke-opacity=".7" stroke-width="1.4" stroke-linecap="round"/>',
    "maximize": '<path d="M9.5 14.5l5-5M10.5 9.5h4v4" stroke="#0e0e13" stroke-opacity=".7" stroke-width="1.3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
    "restore": '<path d="M9.5 14.5l5-5M10.5 9.5h4v4" stroke="#0e0e13" stroke-opacity=".7" stroke-width="1.3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
}
CORES = {"close": "#f06a6a", "minimize": "#f0b45e", "maximize": "#5fd18b", "restore": "#5fd18b"}


def svg_botao(nome):
    cor, sim = CORES[nome], SIMBOLOS[nome]
    g = []
    for estado, fill, op, s in (("active", cor, 1, ""), ("hover", cor, 1, sim), ("pressed", cor, .7, sim),
                                ("inactive", "#5a5a6a", .55, ""), ("deactivated", "#5a5a6a", .35, "")):
        g.append(f'<g id="{estado}"><rect width="24" height="24" fill="none"/>'
                 f'<circle cx="12" cy="12" r="7" fill="{fill}" fill-opacity="{op}"/>{s}</g>')
        g.append(f'<g id="{estado}-center"><rect width="24" height="24" fill="none"/>'
                 f'<circle cx="12" cy="12" r="7" fill="{fill}" fill-opacity="{op}"/>{s}</g>')
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">{"".join(g)}</svg>\n'


def decoracao(fundo, op):
    """decoration.svg: moldura com cantos de 12 px em cima e embaixo, título por cima."""
    r = 12
    s = r * 3
    corpo = []
    for estado, opac in (("decoration", op), ("decoration-inactive", op), ("decoration-maximized", 1),
                         ("decoration-maximized-inactive", 1)):
        rr = 0 if "maximized" in estado else r
        if rr:
            pecas = {
                "topleft": f"M0 {r}A{r} {r} 0 0 1 {r} 0V{r}Z", "topright": f"M{2*r} 0A{r} {r} 0 0 1 {s} {r}H{2*r}Z",
                "bottomleft": f"M0 {2*r}H{r}V{s}A{r} {r} 0 0 1 0 {2*r}Z",
                "bottomright": f"M{2*r} {2*r}H{s}A{r} {r} 0 0 1 {2*r} {s}Z",
            }
        else:
            pecas = {"topleft": f"M0 0H{r}V{r}H0Z", "topright": f"M{2*r} 0H{s}V{r}H{2*r}Z",
                     "bottomleft": f"M0 {2*r}H{r}V{s}H0Z", "bottomright": f"M{2*r} {2*r}H{s}V{s}H{2*r}Z"}
        pecas.update({"top": f"M{r} 0H{2*r}V{r}H{r}Z", "bottom": f"M{r} {2*r}H{2*r}V{s}H{r}Z",
                      "left": f"M0 {r}H{r}V{2*r}H0Z", "right": f"M{2*r} {r}H{s}V{2*r}H{2*r}Z",
                      "center": f"M{r} {r}H{2*r}V{2*r}H{r}Z"})
        for nome, d in pecas.items():
            corpo.append(f'<path id="{estado}-{nome}" fill="{fundo}" fill-opacity="{opac}" d="{d}"/>')
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{s}" height="{s}" viewBox="0 0 {s} {s}">{"".join(corpo)}</svg>\n'


def aurorae(out: Path):
    a = out / "aurorae/Nullyz"
    a.mkdir(parents=True, exist_ok=True)
    (a / "decoration.svg").write_text(decoracao(ESC["fundo"], 1), encoding="utf-8")
    for nome in ("close", "minimize", "maximize", "restore"):
        (a / f"{nome}.svg").write_text(svg_botao(nome), encoding="utf-8")
    (a / "metadata.desktop").write_text(
        "[Desktop Entry]\nName=Nullyz\nComment=Decoração de janela do NullyzOS: botões redondos à esquerda\n"
        "X-KDE-PluginInfo-Author=NullyzOS\nX-KDE-PluginInfo-Name=Nullyz\nX-KDE-PluginInfo-Version=0.2\n"
        "X-KDE-PluginInfo-License=GPL-3.0-or-later\nX-KDE-PluginInfo-Website=https://github.com/Ruthraas/NullyzOS\n",
        encoding="utf-8")
    t, m = ESC["texto"], ESC["texto_suave"]
    (a / "Nullyzrc").write_text(f"""[General]
ActiveTextColor={t}
InactiveTextColor={m}
TitleAlignment=Center
TitleVerticalAlignment=Center
Animation=160
ActiveTextShadowColor=#00000000
InactiveTextShadowColor=#00000000
Shadow=true
DecorationPosition=0

[Layout]
BorderLeft=0
BorderRight=0
BorderBottom=0
TitleEdgeTop=6
TitleEdgeBottom=6
TitleEdgeLeft=10
TitleEdgeRight=10
TitleBorderLeft=8
TitleBorderRight=8
TitleHeight=22
ButtonWidth=24
ButtonHeight=24
ButtonSpacing=2
ButtonMarginTop=0
ExplicitButtonSpacer=10
PaddingTop=8
PaddingBottom=8
PaddingLeft=8
PaddingRight=8
""", encoding="utf-8")


def main(out: Path):
    desktoptheme(out)
    aurorae(out)


if __name__ == "__main__":
    main(Path(sys.argv[1] if len(sys.argv) > 1 else "saida"))
