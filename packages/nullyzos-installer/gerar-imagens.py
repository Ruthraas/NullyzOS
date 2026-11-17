#!/usr/bin/env python3
"""Gera as imagens do instalador (só biblioteca padrão):

  welcome.svg   o N pixelado com bastante respiro (o Calamares estica a imagem até a área toda)
  hyprland.png  prévia do desktop Hyprland: janelas lado a lado, barra no topo
  kde.png       prévia do KDE Plasma: janelas soltas, painel em cima e embaixo

    python gerar-imagens.py <pasta-de-saída>
Cores de branding/tokens.json (escuro).
"""
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


def main(out: Path):
    out.mkdir(parents=True, exist_ok=True)
    (out / "welcome.svg").write_text(welcome_svg(), encoding="utf-8")
    (out / "hyprland.png").write_bytes(hyprland())
    (out / "kde.png").write_bytes(kde())


if __name__ == "__main__":
    main(Path(sys.argv[1] if len(sys.argv) > 1 else "imagens"))
