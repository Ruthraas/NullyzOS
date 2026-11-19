#!/usr/bin/env python3
"""Gera o tema de ícones do NullyzOS (#13): ícones de app em azulejo arredondado (raio 38% do
lado, docs/IDENTIDADE.md), cor de fundo com um degradê sutil e o desenho em traço branco.
O resto dos ícones vem do Breeze (herdado). Dois temas: "Nullyz" (herda breeze-dark) e
"Nullyz-Claro" (herda breeze); os ícones de app são os mesmos nos dois.
    python gerar-icones.py <pasta de saída>     → <saída>/Nullyz e <saída>/Nullyz-Claro
Só biblioteca padrão.
"""
import sys
from pathlib import Path

# Desenhos em grade de 24 (traço), centrados no azulejo
DESENHOS = {
    "pasta": '<path d="M3 7.5a2 2 0 0 1 2-2h4.2l2 2H19a2 2 0 0 1 2 2v7.5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M3 10h18"/>',
    "terminal": '<rect x="3" y="4.5" width="18" height="15" rx="2.5"/><path d="m7.5 10 3 2.5-3 2.5M13 15.5h4"/>',
    "loja": '<path d="M5.5 8.5h13l-1.2 11h-10.6z"/><path d="M9 8.5V7a3 3 0 0 1 6 0v1.5"/>',
    "imagem": '<rect x="3" y="4.5" width="18" height="15" rx="2.5"/><circle cx="9" cy="10" r="1.6"/><path d="m21 16-5-5-8.5 8.5"/>',
    "documento": '<path d="M6.5 3h7.5l4 4v14h-11.5z"/><path d="M14 3v4h4M9.5 12h5M9.5 15.5h5"/>',
    "editor": '<path d="M4 20h4.2L19.5 8.7l-4.2-4.2L4 15.8z"/><path d="m13.5 6.3 4.2 4.2"/>',
    "video": '<rect x="3" y="4.5" width="18" height="15" rx="2.5"/><path d="m10 9 5 3-5 3z"/>',
    "pacote": '<path d="M3.5 4.5h17v4h-17zM5 8.5h14v11H5z"/><path d="M10 12h4"/>',
    "calculadora": '<rect x="5.5" y="3" width="13" height="18" rx="2.5"/><path d="M8.5 7h7M8.5 11.5h.01M12 11.5h.01M15.5 11.5h.01M8.5 15h.01M12 15h.01M15.5 15h.01M8.5 18h.01M12 18h.01M15.5 18h.01"/>',
    "disco": '<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="2.2"/><path d="M12 3.5V6"/>',
    "engrenagem": '<circle cx="12" cy="12" r="3"/><path d="M12 2.8v2.4M12 18.8v2.4M2.8 12h2.4M18.8 12h2.4M5.5 5.5l1.7 1.7M16.8 16.8l1.7 1.7M5.5 18.5l1.7-1.7M16.8 7.2l1.7-1.7"/><circle cx="12" cy="12" r="6.3"/>',
    "monitor": '<rect x="3" y="4" width="18" height="12.5" rx="2.5"/><path d="M8.5 20h7M12 16.5V20M6.5 12.5l3-3.5 3 2.5 4.5-5"/>',
}

# cor do azulejo (de branding/tokens.json → destaques, mais dois neutros)
CORES = {
    "azul": "#6e8cff", "violeta": "#9d8cff", "ciano": "#2bb6c9", "coral": "#f08a5d",
    "verde": "#5fd18b", "rosa": "#f07ab8", "ambar": "#e9a43f", "grafite": "#4a4a5c", "ardosia": "#5d6b82",
}

# (desenho, cor, [nomes do ícone])
ICONES = [
    ("pasta", "azul", ["org.kde.dolphin", "system-file-manager", "system-file-manager-root"]),
    ("terminal", "grafite", ["kitty", "utilities-terminal", "org.kde.konsole", "konsole"]),
    ("loja", "violeta", ["org.kde.discover", "plasmadiscover", "system-software-install"]),
    ("imagem", "ciano", ["org.kde.gwenview", "gwenview"]),
    ("documento", "coral", ["org.kde.okular", "okular"]),
    ("editor", "verde", ["org.kde.kate", "kate", "accessories-text-editor"]),
    ("video", "rosa", ["org.kde.haruna", "haruna"]),
    ("pacote", "ambar", ["org.kde.ark", "ark", "utilities-file-archiver"]),
    ("calculadora", "grafite", ["org.kde.kcalc", "accessories-calculator"]),
    ("disco", "ardosia", ["org.kde.partitionmanager", "partitionmanager"]),
    ("engrenagem", "grafite", ["systemsettings", "preferences-system", "org.kde.systemsettings"]),
    ("monitor", "ardosia", ["org.kde.plasma-systemmonitor", "utilities-system-monitor"]),
]


def clarear(hexa, t):
    r, g, b = (int(hexa[i:i + 2], 16) for i in (1, 3, 5))
    return "#%02x%02x%02x" % tuple(round(c + (255 - c) * t) for c in (r, g, b))


def svg(desenho, cor):
    claro = clarear(cor, 0.18)
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">
  <defs><linearGradient id="f" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{claro}"/><stop offset="1" stop-color="{cor}"/></linearGradient></defs>
  <rect x="3" y="3" width="58" height="58" rx="22" fill="url(#f)"/>
  <rect x="3.5" y="3.5" width="57" height="57" rx="21.5" fill="none" stroke="#ffffff" stroke-opacity=".22"/>
  <g transform="translate(16 16) scale(1.333)" fill="none" stroke="#ffffff" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">{DESENHOS[desenho]}</g>
</svg>
'''


def tema(saida, nome, herda, comentario):
    raiz = saida / nome
    pasta = raiz / "apps" / "scalable"
    pasta.mkdir(parents=True, exist_ok=True)
    (raiz / "index.theme").write_text(f"""[Icon Theme]
Name={nome}
Comment={comentario}
Inherits={herda}
Directories=apps/scalable

[apps/scalable]
Size=64
MinSize=16
MaxSize=512
Context=Applications
Type=Scalable
""", encoding="utf-8")
    for desenho, cor, nomes in ICONES:
        conteudo = svg(desenho, CORES[cor])
        for n in nomes:
            (pasta / f"{n}.svg").write_text(conteudo, encoding="utf-8")


def main(saida):
    saida = Path(saida)
    tema(saida, "Nullyz", "breeze-dark,breeze,hicolor", "Ícones de app do NullyzOS (o resto do Breeze escuro)")
    tema(saida, "Nullyz-Claro", "breeze,hicolor", "Ícones de app do NullyzOS (o resto do Breeze claro)")
    print(f"{len(ICONES)} desenhos, {sum(len(n) for _, _, n in ICONES)} nomes, 2 temas em {saida}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "icones")
