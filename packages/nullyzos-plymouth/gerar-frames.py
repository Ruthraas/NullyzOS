#!/usr/bin/env python3
"""Gera os quadros da animação de boot do NullyzOS (docs/IDENTIDADE.md, "Boot e boas-vindas").

    python gerar-frames.py <pasta-de-saída>

Sequência (~3,5 s a 30 quadros/s), igual à prancha aprovada:
  1. os pixels do N acendem em diagonal, cada um com overshoot; no fim o N amassa e volta;
  2. NULL se escreve letra a letra, linha a linha;
  3. YZ e depois OS entram girando (um giro e meio), passam do ponto e assentam.
Os três pixels pulsando ficam por conta do script do Plymouth (dot.png).
Só biblioteca padrão: o PKGBUILD roda isto no build, sem Pillow.
"""
import math
import struct
import sys
import zlib
from pathlib import Path

W, H = 560, 300
FPS = 30
DURATION = 3.5
BG = (0, 0, 0)
ACCENT = (0x9D, 0x8C, 0xFF)
TEXT = (0xED, 0xED, 0xF2)

N = ["##...##", "###..##", "####.##", "##.####", "##..###", "##...##", "##...##"]
FONT = {
    "N": ["#...#", "##..#", "##..#", "#.#.#", "#..##", "#..##", "#...#"],
    "U": ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
    "L": ["#....", "#....", "#....", "#....", "#....", "#....", "#####"],
    "Y": ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."],
    "Z": ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"],
    "O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
    "S": [".####", "#....", "#....", ".###.", "....#", "....#", "####."],
}

# Geometria (px)
SYM_CELL, SYM_GAP = 18, 3
SYM_STEP = SYM_CELL + SYM_GAP
SYM_W = 7 * SYM_STEP - SYM_GAP
SYM_X, SYM_Y = (W - SYM_W) // 2, 20
TXT_CELL, TXT_GAP = 9, 2
TXT_STEP = TXT_CELL + TXT_GAP
LETTER_W = 5 * TXT_STEP - TXT_GAP
WORD = "NULLYZOS"
GAPS = [8, 8, 8, 8, 8, 26, 8, 0]          # espaço depois de cada letra (YZ | OS)
WORD_W = len(WORD) * LETTER_W + sum(GAPS)
TXT_X, TXT_Y = (W - WORD_W) // 2, SYM_Y + SYM_W + 46


def ease_out_back(p, s=1.7):
    p -= 1
    return p * p * ((s + 1) * p + s) + 1


def ease_out_cubic(p):
    return 1 - (1 - p) ** 3


def clamp01(x):
    return 0.0 if x < 0 else (1.0 if x > 1 else x)


class Canvas:
    def __init__(self):
        self.rows = [bytearray(bytes(BG) * W) for _ in range(H)]

    def rect(self, x0, y0, x1, y1, color):
        x0, y0 = max(0, int(round(x0))), max(0, int(round(y0)))
        x1, y1 = min(W, int(round(x1))), min(H, int(round(y1)))
        if x1 <= x0 or y1 <= y0:
            return
        line = bytes(color) * (x1 - x0)
        for y in range(y0, y1):
            self.rows[y][x0 * 3:x1 * 3] = line

    def png(self):
        raw = b"".join(b"\x00" + bytes(r) for r in self.rows)

        def chunk(kind, data):
            return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

        return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
                + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def draw_symbol(cv, t):
    # Amassada no fim (squash and stretch): 1,18 s → 1,64 s
    sp = clamp01((t - 1.18) / 0.46)
    if 0 < sp < 1:
        k = math.sin(sp * math.pi) * (1 - sp)
        sx, sy = 1 + 0.08 * k, 1 - 0.12 * k
    else:
        sx = sy = 1.0
    cx, cy = SYM_X + SYM_W / 2, SYM_Y + SYM_W   # amassa apoiado na base
    for r, row in enumerate(N):
        for c, ch in enumerate(row):
            if ch != "#":
                continue
            p = clamp01((t - (0.2 + (r + c) * 0.042)) / 0.38)
            if p <= 0:
                continue
            s = ease_out_back(p)
            size = SYM_CELL * s
            px = SYM_X + c * SYM_STEP + SYM_CELL / 2
            py = SYM_Y + r * SYM_STEP + SYM_CELL / 2
            px, py = cx + (px - cx) * sx, cy + (py - cy) * sy
            cv.rect(px - size * sx / 2, py - size * sy / 2, px + size * sx / 2, py + size * sy / 2, ACCENT)


SPIN_AT = {4: 2.05, 5: 2.23, 6: 2.65, 7: 2.83}


def draw_word(cv, t):
    x = TXT_X
    for i, ch in enumerate(WORD):
        rows = FONT[ch]
        if i < 4:
            # NULL: scanline, letra a letra
            for r, row in enumerate(rows):
                if t < 1.3 + i * 0.17 + r * 0.022:
                    continue
                for c, cc in enumerate(row):
                    if cc == "#":
                        cv.rect(x + c * TXT_STEP, TXT_Y + r * TXT_STEP,
                                x + c * TXT_STEP + TXT_CELL, TXT_Y + r * TXT_STEP + TXT_CELL, TEXT)
        else:
            # YZ OS: giro em Y (a largura segue o cosseno do ângulo) com overshoot
            p = clamp01((t - SPIN_AT[i]) / 0.98)
            if p > 0:
                if p < 0.76:
                    ang = -540 + (16 + 540) * ease_out_cubic(p / 0.76)
                    sc = 0.4 + 0.68 * ease_out_cubic(p / 0.76)
                else:
                    q = (p - 0.76) / 0.24
                    ang, sc = 16 * (1 - q), 1.08 - 0.08 * q
                if p >= 0.5 or int(p * 12) % 2 == 0:      # surge piscando até a metade
                    fx = math.cos(math.radians(ang)) * sc
                    mid = x + LETTER_W / 2
                    for r, row in enumerate(rows):
                        for c, cc in enumerate(row):
                            if cc != "#":
                                continue
                            x0 = mid + (c * TXT_STEP - LETTER_W / 2) * fx
                            x1 = mid + (c * TXT_STEP + TXT_CELL - LETTER_W / 2) * fx
                            y0 = TXT_Y + LETTER_W * 0 + (r * TXT_STEP - 38) * sc + 38
                            y1 = y0 + TXT_CELL * sc
                            cv.rect(min(x0, x1), y0, max(x0, x1), y1, ACCENT)
        x += LETTER_W + GAPS[i]


def main(out):
    out.mkdir(parents=True, exist_ok=True)
    total = int(DURATION * FPS)
    for f in range(total):
        cv = Canvas()
        t = f / FPS
        draw_symbol(cv, t)
        draw_word(cv, t)
        (out / f"frame-{f}.png").write_bytes(cv.png())
    # pixel dos três pontos que pulsam
    dot = Canvas.__new__(Canvas)
    dot.rows = [bytearray(bytes(ACCENT) * 8) for _ in range(8)]
    raw = b"".join(b"\x00" + bytes(r) for r in dot.rows)

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

    (out / "dot.png").write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 8, 8, 8, 2, 0, 0, 0))
                                  + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))
    print(f"{total} quadros em {out}")


if __name__ == "__main__":
    main(Path(sys.argv[1] if len(sys.argv) > 1 else "frames"))
