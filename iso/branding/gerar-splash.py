#!/usr/bin/env python3
"""Gera branding/splash.png (640x480) do menu de boot BIOS: o N pixelado e NULLYZ OS em pixel.

Só biblioteca padrão (zlib + struct), sem Pillow. Rodar de novo se o símbolo mudar:
    python iso/branding/gerar-splash.py
As formas vêm de docs/IDENTIDADE.md (N 7x7, letras 5x7).
"""
import struct
import zlib
from pathlib import Path

W, H = 640, 480
BG = (0x0B, 0x0B, 0x10)
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

px = [[BG for _ in range(W)] for _ in range(H)]


def block(x, y, size, color):
    for yy in range(y, y + size):
        for xx in range(x, x + size):
            if 0 <= xx < W and 0 <= yy < H:
                px[yy][xx] = color


def glyph(rows, x, y, cell, gap, color):
    for r, row in enumerate(rows):
        for c, ch in enumerate(row):
            if ch == "#":
                block(x + c * cell, y + r * cell, cell - gap, color)


# Símbolo: pixel de 12 px (1 de vão), centralizado no terço de cima.
cell = 12
glyph(N, (W - 7 * cell) // 2, 52, cell, 1, ACCENT)

# NULLYZ OS: letras 5x7 de pixel 4 px; YZ OS no destaque.
c2, lgap, sgap = 4, 6, 18
word = "NULLYZOS"
width = len(word) * 5 * c2 + (len(word) - 1) * lgap + sgap
x = (W - width) // 2
for i, ch in enumerate(word):
    glyph(FONT[ch], x, 160, c2, 0, ACCENT if i >= 4 else TEXT)
    x += 5 * c2 + lgap + (sgap if i == 5 else 0)

raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in px)


def chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)


png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0)) \
    + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
out = Path(__file__).with_name("splash.png")
out.write_bytes(png)
print(f"{out} ({len(png)} bytes)")
