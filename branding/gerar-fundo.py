#!/usr/bin/env python3
"""Gera os fundos do Nullyz: manchas de cor suaves sobre quase-preto, as mesmas das pranchas
do desktop (docs/IDENTIDADE.md). 960x540; quem mostra estica com suavização.
"padrao" é o da tela de login e o primeiro da área de trabalho; os outros são variações de
cor oferecidas em Configurações → Aparência. Só biblioteca padrão.
    python gerar-fundo.py <saída.png> [variante]      (variantes: veja VARIANTES)
"""
import math
import struct
import sys
import zlib

W, H = 960, 540
BASE = (11, 11, 16)
# (centro x, centro y, raio x, raio y, cor) em frações da tela
VARIANTES = {
    # violeta, petróleo e rosa: o fundo de sempre
    "padrao": [
        (0.22, 0.30, 0.70, 0.60, (75, 59, 214)),
        (0.82, 0.82, 0.60, 0.60, (29, 135, 150)),
        (0.76, 0.14, 0.42, 0.42, (184, 80, 111)),
    ],
    # verde-água e violeta, de cima para baixo
    "aurora": [
        (0.30, 0.10, 0.80, 0.45, (32, 160, 128)),
        (0.78, 0.40, 0.55, 0.55, (96, 70, 220)),
        (0.15, 0.90, 0.50, 0.50, (24, 96, 150)),
    ],
    # laranja queimado e vinho, num canto só
    "brasa": [
        (0.86, 0.86, 0.75, 0.70, (196, 88, 48)),
        (0.58, 0.98, 0.50, 0.40, (150, 40, 80)),
        (0.12, 0.12, 0.40, 0.40, (70, 50, 150)),
    ],
    # azuis frios
    "oceano": [
        (0.20, 0.75, 0.70, 0.65, (30, 80, 190)),
        (0.80, 0.25, 0.60, 0.55, (20, 140, 180)),
    ],
    # só o violeta do Nullyz, no centro
    "nucleo": [
        (0.50, 0.55, 0.65, 0.70, (110, 90, 240)),
    ],
    # cinzas quase sem cor
    "grafite": [
        (0.25, 0.30, 0.70, 0.60, (70, 70, 84)),
        (0.80, 0.80, 0.60, 0.60, (50, 54, 66)),
    ],
}


def main(out, variante="padrao"):
    BLOBS = VARIANTES[variante]
    rows = []
    for y in range(H):
        row = bytearray()
        fy = y / H
        for x in range(W):
            fx = x / W
            r, g, b = BASE
            for cx, cy, rx, ry, col in BLOBS:
                d = math.hypot((fx - cx) / rx, (fy - cy) / ry)
                a = max(0.0, 1 - d / 0.78)
                a = a * a * (3 - 2 * a) * 0.62   # smoothstep (borda macia), no máximo 62% da cor
                r += (col[0] - r) * a
                g += (col[1] - g) * a
                b += (col[2] - b) * a
            row += bytes((int(r), int(g), int(b)))
        rows.append(b"\x00" + bytes(row))

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

    png = (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(b"".join(rows), 9)) + chunk(b"IEND", b""))
    with open(out, "wb") as f:
        f.write(png)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "fundo.png", sys.argv[2] if len(sys.argv) > 2 else "padrao")
