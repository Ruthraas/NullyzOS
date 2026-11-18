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


    // Paletas completas (os temas da prévia do Nullyz: Nulo, Papel, Ouro, Brasa, Cru, Areia,
    // Musgo e Sol). Um rice escolhe uma (Prefs.palette) e ela troca todos os papéis; vazio =
    // as paletas Nullyz escuro/claro de sempre, com a cor de destaque escolhida.
    property string paletteName: ""
    readonly property var schemes: ({
        nulo:  { name: "Nulo",  light: false, bg: "#0e0e11", surface: "#16161a", surfaceHi: "#202026", border: "#2a2a31", accent: "#9d8cff", onAccent: "#100c24", text: "#e8e8ee", muted: "#9898a4", success: "#62d394", warning: "#f0c35a", error: "#f06a6a" },
        papel: { name: "Papel", light: true,  bg: "#f4f2ee", surface: "#fbfaf8", surfaceHi: "#ebe8e2", border: "#d9d5cc", accent: "#2f5bd3", onAccent: "#ffffff", text: "#1d1c1a", muted: "#5f5c56", success: "#1f7a4a", warning: "#8a5a00", error: "#b42318" },
        ouro:  { name: "Ouro",  light: false, bg: "#0a0908", surface: "#13110e", surfaceHi: "#1d1a15", border: "#2b261d", accent: "#e3b341", onAccent: "#1a1406", text: "#efe9dc", muted: "#a39a88", success: "#7fc98f", warning: "#f2a541", error: "#e8705e" },
        brasa: { name: "Brasa", light: false, bg: "#0f0b0b", surface: "#181111", surfaceHi: "#231919", border: "#33221f", accent: "#ff5a4e", onAccent: "#1f0503", text: "#f2e6e4", muted: "#a8918e", success: "#6ccf8c", warning: "#f3b54a", error: "#ff7b72" },
        cru:   { name: "Cru",   light: true,  bg: "#efece4", surface: "#f7f5ef", surfaceHi: "#e4e0d5", border: "#d3cec1", accent: "#1a1a1a", onAccent: "#f7f5ef", text: "#161616", muted: "#5a5850", success: "#2a6e3f", warning: "#7d5800", error: "#a8281c" },
        areia: { name: "Areia", light: true,  bg: "#ece3d3", surface: "#f5eee2", surfaceHi: "#e2d6c2", border: "#cfc0a6", accent: "#a8461f", onAccent: "#fff7ef", text: "#2b2219", muted: "#62553f", success: "#356b3a", warning: "#7a5200", error: "#a32a1d" },
        musgo: { name: "Musgo", light: false, bg: "#0b0d0b", surface: "#121612", surfaceHi: "#1b211b", border: "#263026", accent: "#5fd17a", onAccent: "#06170b", text: "#e3ece3", muted: "#8fa08f", success: "#5fd17a", warning: "#e6c35c", error: "#ef6f6a" },
        sol:   { name: "Sol",   light: false, bg: "#111111", surface: "#1a1a19", surfaceHi: "#252523", border: "#32322e", accent: "#ffd23f", onAccent: "#1c1600", text: "#f1efe8", muted: "#a3a196", success: "#7dd38f", warning: "#ffb347", error: "#f27066" }
    })
    readonly property var schemeOrder: ["nulo", "papel", "ouro", "brasa", "cru", "areia", "musgo", "sol"]
    readonly property var scheme: schemes[paletteName] || null
    // Paleta ativa como objeto (terminal, apps Qt/GTK e KDE geram a partir daqui)
    readonly property var pal: ({ bg: String(bg), surface: String(surface), surfaceHi: String(surfaceHi),
                                  border: String(border), text: String(text), muted: String(muted) })

    // 16 cores do terminal (kitty). No claro, tons mais fechados para ler no fundo branco.
    readonly property var ansiDark: ["#17171f", "#f06a6a", "#5fd18b", "#f0b45e", "#6e8cff", "#9d8cff", "#2bb6c9", "#c8c8d4",
                                     "#4a4a5a", "#ff8f8f", "#86e3a8", "#f7cb85", "#96acff", "#bcb0ff", "#5fd0de", "#ededf2"]
    readonly property var ansiLight: ["#2b2b37", "#c93a3a", "#1f8a4c", "#a8650f", "#3a5ad9", "#5b46e0", "#0f8394", "#5a5a6a",
                                      "#4a4a5a", "#e05252", "#2aa862", "#c27a14", "#5672e8", "#7560ee", "#1aa0b3", "#15151c"]

    readonly property color bg: scheme ? scheme.bg : (light ? "#f4f4f7" : "#0e0e13")
    readonly property color surface: scheme ? scheme.surface : (light ? "#ffffff" : "#17171f")
    readonly property color surfaceHi: scheme ? scheme.surfaceHi : (light ? "#ececf1" : "#1f1f29")
    readonly property color border: scheme ? scheme.border : (light ? "#d9d9e2" : "#2b2b37")
    readonly property color text: scheme ? scheme.text : (light ? "#15151c" : "#ededf2")
    readonly property color muted: scheme ? scheme.muted : (light ? "#5a5a6a" : "#a3a3b3")
    readonly property color error: scheme ? scheme.error : (light ? "#c93a3a" : "#f06a6a")
    readonly property color success: scheme ? scheme.success : (light ? "#1f8a4c" : "#5fd18b")
    readonly property color warning: scheme ? scheme.warning : (light ? "#a8650f" : "#f0b45e")

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
    // "auto" = cor tirada do wallpaper (modules/AccentSampler): no escuro a amostra, no claro
    // uma versão mais fechada para ter contraste.
    property color autoAccent: "#9d8cff"
    // "tema" = a cor da paleta do rice (Ouro dourado, Brasa vermelho…)
    readonly property var accentEntry: accentName === "auto"
        ? { name: "Do wallpaper", color: autoAccent, light: Qt.darker(autoAccent, 1.55) }
        : (accentName === "tema" && scheme) ? { name: "Do tema " + scheme.name, color: scheme.accent, light: scheme.accent }
        : (accents[accentName] || accents.violeta)
    readonly property color accent: light ? accentEntry.light : accentEntry.color
    readonly property color textOnAccent: (accentName === "tema" && scheme) ? scheme.onAccent : (light ? "#ffffff" : "#0e0e13")

    // Vidro: tinta (mais opaca no modo VM, que não tem desfoque), borda de luz e brilho no topo.
    readonly property real glassAlpha: vm ? 0.94 : glassOpacity
    readonly property color glass: light ? Qt.rgba(surface.r, surface.g, surface.b, Math.min(0.96, glassAlpha + 0.08))
                                         : Qt.rgba(surface.r, surface.g, surface.b, glassAlpha)
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
