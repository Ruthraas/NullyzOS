#!/usr/bin/env python3
"""Converte ícones do Lucide (lucide-static, ISC; https://lucide.dev) num caminho SVG único
por ícone, no formato que shell/components/Ico.qml desenha (traço 24x24), e gera
shell/theme/Icons.qml.

    python scripts/lucide-icons.py <pasta com os .svg do lucide-static>

Círculos, retângulos (com canto), linhas, polilinhas e polígonos viram comandos de path.
Pontos (círculo de raio < 1) viram um traço de comprimento zero, que a ponta redonda
desenha como um ponto. Versão do Lucide usada: ver VERSAO abaixo e CREDITS.md.
"""
import re
import sys
from pathlib import Path
from xml.etree import ElementTree as ET

VERSAO = "0.460.0"

# nome no shell -> arquivo do Lucide
MAPA = {
    "palette": "palette", "lock": "lock", "bar": "panel-top", "dock": "panel-bottom",
    "windows": "app-window", "apps": "layout-grid", "type": "type", "terminal": "square-terminal",
    "wifi": "wifi", "wifiOff": "wifi-off", "ethernet": "ethernet-port", "bluetooth": "bluetooth",
    "printer": "printer", "volumeOff": "volume-x", "speaker": "volume", "volumeLow": "volume-1",
    "volumeHigh": "volume-2", "keyboard": "keyboard", "monitor": "monitor", "bolt": "zap",
    "gauge": "gauge", "clock": "clock", "globe": "globe", "bell": "bell", "bellOff": "bell-off",
    "disk": "hard-drive", "user": "user", "rocket": "rocket", "download": "download",
    "command": "command", "info": "info", "search": "search", "sun": "sun", "moon": "moon",
    "power": "power", "restart": "rotate-cw", "refresh": "refresh-cw", "logout": "log-out",
    "gear": "settings", "check": "check", "close": "x", "plus": "plus", "play": "play",
    "pause": "pause", "next": "skip-forward", "prev": "skip-back", "battery": "battery",
    "chevronLeft": "chevron-left", "chevronRight": "chevron-right", "sparkles": "sparkles",
    "image": "image",
}
WIFI_NIVEIS = ["wifi-zero", "wifi-low", "wifi-high", "wifi"]


def num(v):
    return float(v) if v not in (None, "") else 0.0


def fmt(x):
    s = f"{x:.3f}".rstrip("0").rstrip(".")
    return s if s not in ("-0", "") else "0"


def elemento(e):
    tag = e.tag.split("}")[-1]
    a = e.attrib
    if tag == "path":
        return a["d"]
    if tag == "circle":
        cx, cy, r = num(a.get("cx")), num(a.get("cy")), num(a.get("r"))
        if r < 1:   # ponto
            return f"M{fmt(cx)} {fmt(cy)}h.01"
        return (f"M{fmt(cx - r)} {fmt(cy)}a{fmt(r)} {fmt(r)} 0 1 0 {fmt(2 * r)} 0"
                f"a{fmt(r)} {fmt(r)} 0 1 0 {fmt(-2 * r)} 0")
    if tag == "line":
        return f"M{fmt(num(a.get('x1')))} {fmt(num(a.get('y1')))}L{fmt(num(a.get('x2')))} {fmt(num(a.get('y2')))}"
    if tag in ("polyline", "polygon"):
        p = [float(v) for v in re.split(r"[\s,]+", a["points"].strip())]
        pts = [f"{fmt(p[i])} {fmt(p[i + 1])}" for i in range(0, len(p), 2)]
        return "M" + "L".join(pts) + ("Z" if tag == "polygon" else "")
    if tag == "rect":
        x, y, w, h = num(a.get("x")), num(a.get("y")), num(a.get("width")), num(a.get("height"))
        r = min(num(a.get("rx") or a.get("ry")), w / 2, h / 2)
        if r <= 0:
            return f"M{fmt(x)} {fmt(y)}h{fmt(w)}v{fmt(h)}h{fmt(-w)}Z"
        return (f"M{fmt(x + r)} {fmt(y)}h{fmt(w - 2 * r)}a{fmt(r)} {fmt(r)} 0 0 1 {fmt(r)} {fmt(r)}"
                f"v{fmt(h - 2 * r)}a{fmt(r)} {fmt(r)} 0 0 1 {fmt(-r)} {fmt(r)}"
                f"h{fmt(-(w - 2 * r))}a{fmt(r)} {fmt(r)} 0 0 1 {fmt(-r)} {fmt(-r)}"
                f"v{fmt(-(h - 2 * r))}a{fmt(r)} {fmt(r)} 0 0 1 {fmt(r)} {fmt(-r)}Z")
    return ""


def icone(pasta, nome):
    raiz = ET.parse(pasta / f"{nome}.svg").getroot()
    return " ".join(p for p in (elemento(e) for e in raiz) if p)


def main():
    pasta = Path(sys.argv[1])
    linhas = []
    for prop, arq in MAPA.items():
        linhas.append(f'    readonly property string {prop}: "{icone(pasta, arq)}"')
    niveis = ",\n        ".join(f'"{icone(pasta, n)}"' for n in WIFI_NIVEIS)
    saida = f'''pragma Singleton

import QtQuick
import Quickshell

// Ícones do shell: Lucide {VERSAO} (https://lucide.dev, licença ISC; ver CREDITS.md),
// convertidos para um caminho SVG único por ícone (traço 24x24) por scripts/lucide-icons.py.
// Não edite à mão: rode o script de novo.
Singleton {{
    readonly property var wifiLevels: [
        {niveis}
    ]
{chr(10).join(linhas)}
}}
'''
    out = Path(__file__).resolve().parents[1] / "shell" / "theme" / "Icons.qml"
    out.write_text(saida, encoding="utf-8", newline="\n")
    print(f"{len(MAPA)} ícones -> {out}")


if __name__ == "__main__":
    main()
