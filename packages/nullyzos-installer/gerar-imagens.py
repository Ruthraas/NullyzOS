#!/usr/bin/env python3
"""Gera as imagens do instalador (só biblioteca padrão):

  welcome.svg   o N pixelado com bastante respiro (o Calamares estica a imagem até a área toda)
  hyprland.png  prévia do desktop Hyprland: janelas lado a lado, barra no topo
  kde.png       prévia do KDE Plasma: janelas soltas, painel em cima e embaixo
  rice-<id>.png prévia de cada rice (rices/catalogo.json): tema, cor, cantos, barra e dock

    python gerar-imagens.py <pasta-de-saída>
Cores de branding/tokens.json (escuro).
"""
import json
import struct
import sys
import zlib
from pathlib import Path

N = ["##...##", "###..##", "####.##", "##.####", "##..###", "##...##", "##...##"]
BG = (14, 14, 19)
BAR = (31, 31, 41)
WIN = (34, 34, 45)
WIN_HI = (42, 42, 56)
ACCENT = (157, 140, 255)
MUTED = (90, 90, 106)


def welcome_svg() -> str:
    cell, pad = 10, 115          # N de 70 px num quadro de 300: ocupa ~1/4 da área
    rects = [f'<rect x="{pad + c * cell + 0.5}" y="{pad + r * cell + 0.5}" width="9" height="9" rx="1.5"/>'
             for r, row in enumerate(N) for c, ch in enumerate(row) if ch == "#"]
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300" fill="#9d8cff">\n  '
            + "\n  ".join(rects) + "\n</svg>\n")


class Img:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.rows = [bytearray(bytes(BG) * w) for _ in range(h)]

    def rect(self, x0, y0, x1, y1, color, radius=0):
        for y in range(max(0, y0), min(self.h, y1)):
            for x in range(max(0, x0), min(self.w, x1)):
                if radius:
                    dx = min(x - x0, x1 - 1 - x)
                    dy = min(y - y0, y1 - 1 - y)
                    if dx < radius and dy < radius and (radius - dx) ** 2 + (radius - dy) ** 2 > radius ** 2:
                        continue
                self.rows[y][x * 3:x * 3 + 3] = bytes(color)

    def png(self):
        raw = b"".join(b"\x00" + bytes(r) for r in self.rows)

        def chunk(kind, data):
            return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

        return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 2, 0, 0, 0))
                + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def lines(img, x, y, w, n, color=MUTED):
    for i in range(n):
        img.rect(x, y + i * 14, x + int(w * (0.9 - 0.15 * (i % 3))), y + i * 14 + 6, color, 3)


def hyprland() -> bytes:
    img = Img(640, 400)
    img.rect(0, 0, 640, 24, BAR)
    img.rect(14, 9, 34, 15, ACCENT, 3)              # workspace ativo (pílula)
    for i in range(4):
        img.rect(42 + i * 14, 9, 50 + i * 14, 15, MUTED, 3)
    # janela ativa (borda de destaque) + duas empilhadas
    img.rect(10, 34, 322, 390, ACCENT, 10)
    img.rect(12, 36, 320, 388, WIN, 9)
    lines(img, 30, 60, 250, 8)
    img.rect(332, 34, 630, 208, WIN, 10)
    lines(img, 350, 58, 230, 5)
    img.rect(332, 218, 630, 390, WIN, 10)
    lines(img, 350, 242, 230, 5)
    return img.png()


def kde() -> bytes:
    img = Img(640, 400)
    img.rect(0, 0, 640, 24, BAR)
    img.rect(10, 8, 20, 18, ACCENT, 2)
    lines(img, 34, 9, 120, 1)
    # janelas soltas sobrepostas
    img.rect(70, 60, 400, 290, WIN, 12)
    img.rect(70, 60, 400, 84, WIN_HI, 12)
    lines(img, 92, 104, 260, 6)
    img.rect(250, 120, 580, 330, WIN, 12)
    img.rect(250, 120, 580, 144, WIN_HI, 12)
    lines(img, 272, 164, 260, 6)
    # painel flutuante embaixo
    img.rect(200, 350, 440, 388, BAR, 14)
    for i in range(6):
        img.rect(214 + i * 37, 358, 214 + i * 37 + 24, 380, ACCENT if i == 0 else WIN_HI, 6)
    return img.png()


ACCENTS = {"violeta": "9d8cff", "azul": "6e8cff", "ciano": "2bb6c9", "verde": "5fd18b",
           "coral": "f08a5d", "rosa": "f07ab8", "auto": "9d8cff"}
PALETAS = {"escuro": ("0e0e13", "17171f", "22222d", "2b2b37", "5a5a6a"),
           "claro": ("f4f4f7", "ffffff", "e9e9f0", "d9d9e2", "a3a3b3")}


def hexrgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rice(r) -> bytes:
    """Prévia de um rice pelas preferências: tema, destaque, cantos, espaçamento, barra, dock."""
    pref, hy = r.get("preferencias", {}), r.get("hyprland", {})
    bg, surf, win, line, muted = (hexrgb(c) for c in PALETAS.get(pref.get("theme", "escuro"), PALETAS["escuro"]))
    claro = pref.get("theme") == "claro"
    acc = hexrgb(ACCENTS.get(pref.get("accent", "violeta"), "9d8cff"))
    rad = int(10 * pref.get("roundness", 1))
    gap = {"compacto": 4, "normal": 10, "amplo": 18}.get(hy.get("gaps", ""), 10)
    barh = {"compacta": 18, "normal": 24, "alta": 30}.get(pref.get("barSize", "normal"), 24)
    img = Img(640, 400)
    img.rect(0, 0, 640, 400, bg)
    # mancha de cor no canto (o fundo Nullyz)
    for i in range(6):
        k = 0.10 - i * 0.015
        c = tuple(int(b + (a - b) * k) for a, b in zip(acc, bg))
        img.rect(380 + i * 30, 230 + i * 20, 640, 400, c, 0)
    img.rect(0, 0, 640, barh, surf)
    img.rect(12, barh // 2 - 3, 32, barh // 2 + 3, acc, 3)
    for i in range(4):
        img.rect(40 + i * 12, barh // 2 - 3, 46 + i * 12, barh // 2 + 3, muted, 3)
    y0 = barh + gap
    y1 = 400 - 56 - gap
    meio = 320
    img.rect(gap, y0, meio - gap // 2, y1, acc, rad + 2)
    img.rect(gap + 2, y0 + 2, meio - gap // 2 - 2, y1 - 2, win, rad)
    lines(img, gap + 20, y0 + 24, 240, 8, muted)
    alt = (y1 - y0 - gap) // 2
    img.rect(meio + gap // 2, y0, 640 - gap, y0 + alt, win, rad)
    lines(img, meio + gap // 2 + 18, y0 + 20, 220, 4, muted)
    img.rect(meio + gap // 2, y0 + alt + gap, 640 - gap, y1, win, rad)
    lines(img, meio + gap // 2 + 18, y0 + alt + gap + 20, 220, 4, muted)
    # dock
    estilo = pref.get("dockStyle", "vidro")
    if estilo != "transparente":
        img.rect(220, 352, 420, 392, surf if estilo == "solido" or claro else win, min(rad + 6, 20))
    for i in range(5):
        x = 232 + i * 37
        img.rect(x, 359, x + 26, 385, acc if i == 0 else line, max(2, rad // 2 + 2))
    return img.png()


def main(out: Path):
    out.mkdir(parents=True, exist_ok=True)
    (out / "welcome.svg").write_text(welcome_svg(), encoding="utf-8")
    (out / "hyprland.png").write_bytes(hyprland())
    (out / "kde.png").write_bytes(kde())
    cat = Path(__file__).resolve().parent.parent.parent / "rices" / "catalogo.json"
    if cat.exists():
        for r in json.loads(cat.read_text(encoding="utf-8")):
            (out / f"rice-{r['id']}.png").write_bytes(rice(r))


if __name__ == "__main__":
    main(Path(sys.argv[1] if len(sys.argv) > 1 else "imagens"))
