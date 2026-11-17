pragma Singleton

import QtQuick
import Quickshell

// Tokens visuais do NullyzOS (branding/tokens.json, tema escuro). Toda cor do shell vem daqui.
Singleton {
    readonly property bool vm: Quickshell.env("NULLYZ_VM") === "1"   // modo leve (sem desfoque)

    readonly property color bg: "#0e0e13"
    readonly property color surface: "#17171f"
    readonly property color surfaceHi: "#1f1f29"
    readonly property color border: "#2b2b37"
    readonly property color text: "#ededf2"
    readonly property color muted: "#a3a3b3"
    readonly property color accent: "#9d8cff"
    readonly property color onAccent: "#0e0e13"
    readonly property color error: "#f06a6a"
    // Vidro: tinta (mais opaca no modo VM, que não tem desfoque), borda de luz e brilho no topo.
    readonly property color glass: vm ? Qt.rgba(24 / 255, 24 / 255, 34 / 255, 0.94) : Qt.rgba(24 / 255, 24 / 255, 34 / 255, 0.55)
    readonly property color edge: Qt.rgba(1, 1, 1, 0.16)
    readonly property color highlight: Qt.rgba(1, 1, 1, 0.28)
    readonly property color hover: Qt.rgba(1, 1, 1, 0.08)
    readonly property color selection: Qt.rgba(157 / 255, 140 / 255, 1, 0.20)

    readonly property string font: "Geist"
    readonly property string mono: "Geist Mono"

    // Cantos (botão, campo, cartão, painel)
    readonly property int rButton: 8
    readonly property int rField: 14
    readonly property int rCard: 20
    readonly property int rPanel: 28

    // Durações (ms): hover, painéis, janelas. Modo VM encurta.
    readonly property int fast: vm ? 100 : 160
    readonly property int panel: vm ? 170 : 260
    readonly property int slow: vm ? 260 : 420
}
