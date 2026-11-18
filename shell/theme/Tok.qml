pragma Singleton

import QtQuick
import Quickshell

// Tokens visuais do NullyzOS (branding/tokens.json, papéis escuro e claro). Toda cor do shell
// vem daqui. Prefs escreve `light`, `accentName` e `glassOpacity` (Configurações → Aparência).
// Sem Behavior aqui (singleton derruba o Qt 6.12): quem anima a troca é cada componente.
Singleton {
    readonly property bool vm: Quickshell.env("NULLYZ_VM") === "1"   // modo leve (sem desfoque)

    property bool light: false
    property string accentName: "violeta"
    property real glassOpacity: 0.55          // 0.35 (mais transparente) .. 0.9

    // As duas paletas lado a lado (miniaturas de tema nas Configurações).
    readonly property var palettes: ({
        escuro: { bg: "#0e0e13", surface: "#17171f", border: "#2b2b37", text: "#ededf2", muted: "#a3a3b3" },
        claro: { bg: "#f4f4f7", surface: "#ffffff", border: "#d9d9e2", text: "#15151c", muted: "#5a5a6a" }
    })

    // 16 cores do terminal (kitty). No claro, tons mais fechados para ler no fundo branco.
    readonly property var ansiDark: ["#17171f", "#f06a6a", "#5fd18b", "#f0b45e", "#6e8cff", "#9d8cff", "#2bb6c9", "#c8c8d4",
                                     "#4a4a5a", "#ff8f8f", "#86e3a8", "#f7cb85", "#96acff", "#bcb0ff", "#5fd0de", "#ededf2"]
    readonly property var ansiLight: ["#2b2b37", "#c93a3a", "#1f8a4c", "#a8650f", "#3a5ad9", "#5b46e0", "#0f8394", "#5a5a6a",
                                      "#4a4a5a", "#e05252", "#2aa862", "#c27a14", "#5672e8", "#7560ee", "#1aa0b3", "#15151c"]

    readonly property color bg: light ? "#f4f4f7" : "#0e0e13"
    readonly property color surface: light ? "#ffffff" : "#17171f"
    readonly property color surfaceHi: light ? "#ececf1" : "#1f1f29"
    readonly property color border: light ? "#d9d9e2" : "#2b2b37"
    readonly property color text: light ? "#15151c" : "#ededf2"
    readonly property color muted: light ? "#5a5a6a" : "#a3a3b3"
    readonly property color error: light ? "#c93a3a" : "#f06a6a"

    // Cor de destaque (branding/tokens.json → destaques). No claro, um tom mais fechado para
    // ter contraste com o fundo branco.
    readonly property var accents: ({
        violeta: { name: "Violeta", color: "#9d8cff", light: "#5b46e0" },
        azul: { name: "Azul", color: "#6e8cff", light: "#3a5ad9" },
        ciano: { name: "Ciano", color: "#2bb6c9", light: "#0f8394" },
        verde: { name: "Verde", color: "#5fd18b", light: "#1f8a4c" },
        coral: { name: "Coral", color: "#f08a5d", light: "#c4562a" },
        rosa: { name: "Rosa", color: "#f07ab8", light: "#c23a82" }
    })
    readonly property var accentOrder: ["violeta", "azul", "ciano", "verde", "coral", "rosa"]
    readonly property var accentEntry: accents[accentName] || accents.violeta
    readonly property color accent: light ? accentEntry.light : accentEntry.color
    readonly property color textOnAccent: light ? "#ffffff" : "#0e0e13"

    // Vidro: tinta (mais opaca no modo VM, que não tem desfoque), borda de luz e brilho no topo.
    readonly property real glassAlpha: vm ? 0.94 : glassOpacity
    readonly property color glass: light ? Qt.rgba(1, 1, 1, Math.min(0.96, glassAlpha + 0.08))
                                         : Qt.rgba(24 / 255, 24 / 255, 34 / 255, glassAlpha)
    readonly property color edge: light ? Qt.rgba(0, 0, 0, 0.10) : Qt.rgba(1, 1, 1, 0.16)
    readonly property color highlight: light ? Qt.rgba(1, 1, 1, 0.9) : Qt.rgba(1, 1, 1, 0.28)
    readonly property color hover: light ? Qt.rgba(0, 0, 0, 0.06) : Qt.rgba(1, 1, 1, 0.08)
    readonly property color selection: Qt.rgba(accent.r, accent.g, accent.b, light ? 0.14 : 0.20)
    readonly property color faint: light ? Qt.rgba(0, 0, 0, 0.22) : Qt.rgba(1, 1, 1, 0.28)   // pontos, trilhos
    readonly property color scrim: Qt.rgba(0, 0, 0, light ? 0.18 : 0.3)                         // fundo atrás de painéis

    // Fonte da interface e escala do texto (Configurações → Fontes; Prefs escreve).
    property string font: "Geist"
    property real fontScale: 1
    readonly property string mono: "Geist Mono"

    // Cantos (botão, campo, cartão, painel), vezes `roundness` (Configurações → Aparência:
    // 0 retos, 0.55 suaves, 1 normais, 1.4 redondos).
    property real roundness: 1
    readonly property int rButton: Math.round(8 * roundness)
    readonly property int rField: Math.round(14 * roundness)
    readonly property int rCard: Math.round(20 * roundness)
    readonly property int rPanel: Math.round(28 * roundness)

    // Durações (ms): hover, painéis, janelas, vezes `motion` (0 desligadas, 0.6 rápidas,
    // 1 normais, 1.4 suaves). Modo VM encurta. Desligadas = 1 ms (as Behaviors continuam
    // válidas, só que instantâneas).
    property real motion: 1
    readonly property real motionK: Math.max(0.006, motion) * (vm ? 0.65 : 1)
    readonly property int fast: Math.round(160 * motionK)
    readonly property int panel: Math.round(260 * motionK)
    readonly property int slow: Math.round(420 * motionK)

    // Telas estreitas (painéis e Configurações se rearrumam abaixo disto)
    readonly property int narrow: 1000
}
