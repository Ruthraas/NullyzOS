#!/usr/bin/env python3
"""Gera os arquivos de cor do Nullyz para o KDE Plasma a partir de branding/tokens.json
(a mesma fonte do shell do Hyprland; mesma receita de shell/services/AppTheme.qml):

  NullyzEscuro.colors / NullyzClaro.colors   esquemas de cores do Plasma
  Nullyz<Paleta>.colors                       um por paleta de rice (Ouro, Brasa, Papel…)
  Nullyz.colorscheme                         cores do Konsole (escuro)

    python gerar.py <pasta-de-saída>
Só biblioteca padrão.
"""
import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TOK = json.loads((RAIZ / "branding/tokens.json").read_text(encoding="utf-8"))

# As mesmas 16 cores ANSI do terminal do Hyprland (shell/theme/Tok.qml, ansiDark)
ANSI = ["#17171f", "#f06a6a", "#5fd18b", "#f0b45e", "#6e8cff", "#9d8cff", "#2bb6c9", "#c8c8d4",
        "#4a4a5a", "#ff8f8f", "#86e3a8", "#f7cb85", "#96acff", "#bcb0ff", "#5fd0de", "#ededf2"]


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def s(c):
    return ",".join(str(v) for v in c)


def mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def papeis_da_paleta(pal):
    """Paleta de rice (tokens.json → paletas) nos nomes de papel de roles."""
    return {"fundo": pal["bg"], "superficie": pal["surface"], "superficie_alta": pal["surfaceHi"],
            "borda": pal["border"], "texto": pal["text"], "texto_suave": pal["muted"],
            "destaque": pal["accent"], "sobre_destaque": pal["onAccent"], "sucesso": pal["success"],
            "atencao": pal["warning"], "erro": pal["error"]}


def esquema(nome, modo, papeis=None):
    fonte = papeis or TOK["roles"][modo]
    p = {k: rgb(v) for k, v in fonte.items() if v.startswith("#")}
    esc = {k: rgb(v) for k, v in TOK["roles"]["escuro"].items() if v.startswith("#")}
    acc, on = p["destaque"], p["sobre_destaque"]

    def fg(txt, muted):
        return {"ForegroundNormal": txt, "ForegroundInactive": muted, "ForegroundActive": acc,
                "ForegroundLink": acc, "ForegroundVisited": mix(acc, txt, 0.35),
                "ForegroundNegative": p["erro"], "ForegroundNeutral": p["atencao"],
                "ForegroundPositive": p["sucesso"], "DecorationFocus": acc, "DecorationHover": acc}

    def grupo(bg, alt, txt, muted):
        return {"BackgroundNormal": bg, "BackgroundAlternate": alt, **fg(txt, muted)}

    g = {
        "Colors:Window": grupo(p["fundo"], p["superficie"], p["texto"], p["texto_suave"]),
        "Colors:View": grupo(p["superficie"], p["superficie_alta"], p["texto"], p["texto_suave"]),
        "Colors:Button": grupo(p["superficie_alta"], p["superficie"], p["texto"], p["texto_suave"]),
        "Colors:Header": grupo(p["fundo"], p["superficie"], p["texto"], p["texto_suave"]),
        "Colors:Header][Inactive": grupo(p["fundo"], p["superficie"], p["texto"], p["texto_suave"]),
        "Colors:Tooltip": grupo(p["superficie"], p["superficie_alta"], p["texto"], p["texto_suave"]),
        "Colors:Complementary": grupo(esc["fundo"], esc["superficie"], esc["texto"], esc["texto_suave"]),
        "Colors:Selection": grupo(acc, mix(acc, p["fundo"], 0.3), on, mix(on, acc, 0.4)),
        "WM": {"activeBackground": p["fundo"], "activeForeground": p["texto"],
               "inactiveBackground": p["fundo"], "inactiveForeground": p["texto_suave"],
               "activeBlend": p["fundo"], "inactiveBlend": p["fundo"]},
    }
    out = [f"# Gerado por plasma/gerar.py de branding/tokens.json. Não edite.",
           "", "[General]", f"ColorScheme={nome}", f"Name={nome.replace('Nullyz', 'Nullyz ')}",
           f"AccentColor={s(acc)}", "shadeSortColumn=true", "", "[KDE]", "contrast=4"]
    for sec, kv in g.items():
        out += ["", f"[{sec}]"] + [f"{k}={s(v)}" for k, v in kv.items()]
    return "\n".join(out) + "\n"


def konsole():
    e = {k: rgb(v) for k, v in TOK["roles"]["escuro"].items() if v.startswith("#")}
    out = ["# Gerado por plasma/gerar.py. Cores do terminal do NullyzOS.",
           "[General]", "Description=Nullyz", "Opacity=0.94", "Blur=true", "",
           "[Background]", f"Color={s(e['fundo'])}", "", "[BackgroundIntense]", f"Color={s(e['superficie'])}", "",
           "[Foreground]", f"Color={s(e['texto'])}", "", "[ForegroundIntense]", f"Color={s(e['texto'])}"]
    for i in range(8):
        out += ["", f"[Color{i}]", f"Color={s(rgb(ANSI[i]))}", "", f"[Color{i}Intense]", f"Color={s(rgb(ANSI[i + 8]))}"]
    return "\n".join(out) + "\n"


def main(dest: Path):
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "NullyzEscuro.colors").write_text(esquema("NullyzEscuro", "escuro"), encoding="utf-8")
    (dest / "NullyzClaro.colors").write_text(esquema("NullyzClaro", "claro"), encoding="utf-8")
    # Um esquema por paleta de rice (Nullyz Ouro, Nullyz Brasa…), para os rices no KDE
    for pal in TOK.get("paletas", {}).values():
        nome = "Nullyz" + pal["nome"]
        modo = "claro" if pal["claro"] else "escuro"
        (dest / f"{nome}.colors").write_text(esquema(nome, modo, papeis_da_paleta(pal)), encoding="utf-8")
    (dest / "Nullyz.colorscheme").write_text(konsole(), encoding="utf-8")


if __name__ == "__main__":
    main(Path(sys.argv[1] if len(sys.argv) > 1 else "saida"))
