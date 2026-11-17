#!/usr/bin/env python3
"""Gera o fundo da tela de login (fundo.png): manchas de cor suaves sobre quase-preto,
as mesmas das pranchas do desktop (docs/IDENTIDADE.md). 960x540; o SDDM estica com suavização.
Só biblioteca padrão.   python gerar-fundo.py <saída.png>
"""
import math
import struct
import sys
import zlib

W, H = 960, 540
BASE = (11, 11, 16)
# (centro x, centro y, raio x, raio y, cor) em frações da tela
BLOBS = [
    (0.22, 0.30, 0.70, 0.60, (75, 59, 214)),
    (0.82, 0.82, 0.60, 0.60, (29, 135, 150)),
    (0.76, 0.14, 0.42, 0.42, (184, 80, 111)),
]


def main(out):
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
    main(sys.argv[1] if len(sys.argv) > 1 else "fundo.png")
