#!/usr/bin/env python3
"""Checagem estática leve do shell QML do NullyzOS (veio do Nullyzrice) (não substitui `qmllint` nem rodar no Quickshell).

Verifica em cada .qml de shell/:
- chaves, parênteses e colchetes balanceados (ignorando strings e comentários);
- todo tipo usado como `Tipo {` existe: é do Qt/Quickshell (lista abaixo) ou é um arquivo
  .qml num módulo `qs.*` importado pelo arquivo (ou na mesma pasta);
- singletons têm `pragma Singleton` e raiz `Singleton {`;
- nenhuma cor literal (#rrggbb) fora de shell/theme/ (regra "sem cor fixa").
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "shell"

BUILTIN = set("""
Item Rectangle Text TextInput Image Row Column Grid Flow Repeater ListView GridView Flickable MouseArea
Behavior NumberAnimation ColorAnimation RotationAnimation SequentialAnimation ParallelAnimation PauseAnimation
Transition Translate Scale Rotation Timer Connections QtObject Component Loader Keys FontLoader
RowLayout ColumnLayout GridLayout StackLayout HoverHandler DragHandler WheelHandler TapHandler MultiEffect
ShellRoot Scope Variants PanelWindow PopupWindow FloatingWindow LazyLoader Singleton SystemClock
FileView Process StdioCollector SplitParser IpcHandler JsonAdapter Region
WlSessionLock WlSessionLockSurface PwObjectTracker NotificationServer PamContext QsMenuAnchor DropArea Shape ShapePath PathAngleArc PathLine PathArc PathSvg Matrix4x4 TextEdit
anchors margins font border easing transform
""".split())


RESERVED = set("""
console print gc qsTr qsTranslate Qt XMLHttpRequest Math JSON Date Object Array String Number Boolean
Function RegExp Error Symbol Promise Map Set undefined NaN Infinity eval arguments
break case catch class const continue debugger default delete do else enum export extends false finally
for function if implements import in instanceof interface let new null package private protected public
return static super switch this throw true try typeof var void while with yield await
""".split())


# Propriedades que todo Item do Qt Quick já tem; redeclarar com `property` é erro fatal.
ITEM_FINAL = set("""
layer state states transitions data children resources anchors parent x y z width height
implicitWidth implicitHeight opacity visible enabled clip scale rotation transform transformOrigin
focus activeFocus activeFocusOnTab smooth antialiasing baselineOffset childrenRect containmentMask
visibleChildren objectName
top bottom left right
""".split())
# top/bottom/left/right: "Cannot override FINAL property" visto com `property var top` num
# ColumnLayout no Qt 6.12 (derrubou o shell inteiro). Evitar esses nomes por precaução.


def strip(src: str) -> str:
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if src.startswith("//", i):
            j = src.find("\n", i)
            i = n if j < 0 else j
            continue
        if src.startswith("/*", i):
            j = src.find("*/", i + 2)
            i = n if j < 0 else j + 2
            continue
        if c in "\"'`":
            q = c
            i += 1
            while i < n and src[i] != q:
                i += 2 if src[i] == "\\" else 1
            i += 1
            out.append('""')
            continue
        if c == "/" and re.match(r"/(?![/*])[^\n/]+/[gimsuy]*[.,;)\s]", src[i:i + 200]) and \
                re.search(r"[(,=:!&|?]\s*$", "".join(out[-5:])):
            m = re.match(r"/(?:\\.|[^/\n])+/[gimsuy]*", src[i:])
            if m:
                i += m.end()
                out.append("/r/")
                continue
        out.append(c)
        i += 1
    return "".join(out)


def module_types(imports: list[str], here: Path) -> set[str]:
    types = {p.stem for p in here.glob("*.qml")}
    for imp in imports:
        d = ROOT.joinpath(*imp.split(".")[1:])
        types |= {p.stem for p in d.glob("*.qml")}
    return types


def main() -> int:
    errors: list[str] = []
    files = sorted(ROOT.rglob("*.qml"))
    for f in files:
        rel = f.relative_to(ROOT.parent)
        src = f.read_text(encoding="utf-8")
        code = strip(src)
        pairs = {"{": "}", "(": ")", "[": "]"}
        stack = []
        for lineno, line in enumerate(code.splitlines(), 1):
            for ch in line:
                if ch in pairs:
                    stack.append((ch, lineno))
                elif ch in pairs.values():
                    if not stack or pairs[stack[-1][0]] != ch:
                        errors.append(f"{rel}:{lineno}: '{ch}' sem par")
                        stack = []
                        break
                    stack.pop()
        for ch, ln in stack:
            errors.append(f"{rel}:{ln}: '{ch}' não fechado")

        imports = re.findall(r"^import\s+(qs(?:\.\w+)+)", src, re.M)
        known = BUILTIN | module_types(imports, f.parent)
        known |= set(re.findall(r"component\s+(\w+)\s*:", code))
        for m in re.finditer(r"(?<![\w.])([A-Z]\w*)\s*\{", code):
            t = m.group(1)
            if t not in known:
                ln = code[: m.start()].count("\n") + 1
                errors.append(f"{rel}:{ln}: tipo desconhecido '{t}' (falta import?)")

        # Nomes que o QML recusa em `property` ("Illegal property name"): objetos globais e
        # palavras reservadas do JavaScript. Um só derruba o módulo inteiro no Quickshell.
        for m in re.finditer(r"\bproperty\s+[\w<>.]+\s+(\w+)", code):
            if m.group(1) in RESERVED:
                ln = code[: m.start()].count("\n") + 1
                errors.append(f"{rel}:{ln}: nome de propriedade reservado '{m.group(1)}'")
            elif m.group(1) in ITEM_FINAL and "pragma Singleton" not in src:
                # "Cannot override FINAL property": derruba o módulo (visto com `layer` no NButton).
                ln = code[: m.start()].count("\n") + 1
                errors.append(f"{rel}:{ln}: '{m.group(1)}' já existe em todo Item do Qt (FINAL)")

        # Behavior dentro de singleton derruba o Quickshell (Qt 6.12, QQmlData::deferData).
        if "pragma Singleton" in src and re.search(r"\bBehavior\s+on\b", code):
            errors.append(f"{rel}: Behavior dentro de singleton (crash no Qt 6.12); anime nos componentes")

        if "pragma Singleton" in src and not re.search(r"^Singleton\s*\{", code, re.M):
            errors.append(f"{rel}: pragma Singleton sem raiz Singleton")
        # Propriedade "onAlgo" vira tratador de sinal no QML: o arquivo inteiro deixa de carregar.
        for m in re.finditer(r"property\s+\w+\s+(on[A-Z]\w*)", src):
            ln = src[: m.start()].count(chr(10)) + 1
            errors.append(f"{rel}:{ln}: propriedade {m.group(1)} (on + maiúscula é nome de sinal)")
        if f.parent.name == "services" and "pragma Singleton" not in src:
            errors.append(f"{rel}: service sem pragma Singleton")
        if "theme" not in f.parts:
            for m in re.finditer(r"#[0-9a-fA-F]{6}\b", src):
                ln = src[: m.start()].count("\n") + 1
                line = src.splitlines()[ln - 1]
                if "swatches" in line or "searchColors" in line or '"#" +' in line:
                    continue
                errors.append(f"{rel}:{ln}: cor literal {m.group(0)} (use Tok.*)")

    # Todo Icons.<nome> usado precisa existir em theme/Icons.qml (senão vira texto vazio).
    icons_file = ROOT / "theme" / "Icons.qml"
    icons_src = icons_file.read_text(encoding="utf-8") if icons_file.exists() else ""
    defined = set(re.findall(r"property\s+\w+\s+(\w+)\s*:", icons_src))
    for f in files:
        rel = f.relative_to(ROOT.parent)
        src = f.read_text(encoding="utf-8")
        for m in re.finditer(r"\bIcons\.(\w+)", src):
            if m.group(1) not in defined:
                ln = src[: m.start()].count(chr(10)) + 1
                errors.append(f"{rel}:{ln}: ícone inexistente Icons.{m.group(1)}")
        # Quickshell.iconPath/execDetached/env… sem `import Quickshell` = ReferenceError em
        # tempo de execução (a checagem de tipos não pega, porque não é um tipo).
        m = re.search(r"\bQuickshell\.[a-z]\w*", strip(src))
        if m and not re.search(r"^import Quickshell\s*$", src, re.M):
            ln = src[: src.find(m.group(0))].count(chr(10)) + 1
            errors.append(f"{rel}:{ln}: {m.group(0)} sem 'import Quickshell'")

    for e in errors:
        print("ERRO:", e)
    print(f"{len(files)} arquivos QML verificados, {len(errors)} problema(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
