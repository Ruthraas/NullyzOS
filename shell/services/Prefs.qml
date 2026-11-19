pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

// Preferências do usuário em ~/.config/nullyzos/shell.json (Hyprland) ou kde.json (KDE: cada
// desktop com o seu rice, paleta e fundo), escritas pelas Configurações.
// Sem o arquivo, o shell cria um com os padrões (assim dá para vigiar desde o começo);
// mudou o arquivo (pelas Configurações ou à mão), aplica na hora.
//   dock           mostra o dock (padrão no Hyprland: desligado)
//   wallpaper      caminho da imagem de fundo ("" = fundo padrão do Nullyz)
//   lockWallpaper  fundo da tela de bloqueio: "padrao" ou "desktop" (o mesmo da área de trabalho)
//   lockDim        escurece o fundo do bloqueio para o relógio e a senha ficarem legíveis
//   loginWallpaper imagem copiada para a tela de login ("" = fundo Nullyz); só registro, quem
//                  aplica é /usr/lib/nullyzos/fundo-login (root, via pkexec)
//   accent         cor de destaque (nome em Tok.accents)
//   clockSeconds, showDate, showAppName   o que a barra de menus mostra
//   idleLock, idleSuspend                 minutos parado até bloquear / suspender (0 = nunca)
//   theme ("escuro" | "claro"), glassOpacity (0.35..0.9), cursorSize (24, 32, 48)
//   clock24, dateStyle ("curta" | "longa" | "numerica"), weekStart ("domingo" | "segunda")
//   showLogo, showWorkspaces, workspaceCount, showStatus, barSize ("compacta" | "normal" | "alta")
//   uiFont (família da interface), textScale (0.9 | 1 | 1.1 | 1.25)
//   theme também aceita "auto" (claro das 7h às 19h); roundness, motion (multiplicadores);
//   wallpaperFit (preencher | ajustar | centralizar), wallpaperDim (0..0.6),
//   wallpaperCycle (minutos para trocar sozinho; 0 = não troca)
//   dock*: posição (baixo | esquerda | direita), ícone (px), ampliar (0..0.8), ocultar sozinho,
//          estilo (vidro | solido | transparente), indicador (ponto | traco | nenhum),
//          mostrar abertos, fixados (JSON com ids de .desktop)
Singleton {
    id: root

    readonly property string defaultWallpaper: "/usr/share/nullyzos/wallpapers/padrao.png"
    readonly property bool kde: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").indexOf("KDE") >= 0
    readonly property string dir: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/nullyzos"

    readonly property bool dock: prefs.dock
    readonly property string wallpaper: prefs.wallpaper
    readonly property string lockWallpaper: prefs.lockWallpaper
    readonly property bool lockDim: prefs.lockDim
    readonly property string loginWallpaper: prefs.loginWallpaper
    readonly property string currentWallpaper: prefs.wallpaper || defaultWallpaper
    readonly property string accent: prefs.accent
    readonly property bool clockSeconds: prefs.clockSeconds
    readonly property bool showDate: prefs.showDate
    readonly property bool showAppName: prefs.showAppName
    readonly property int idleLock: prefs.idleLock
    readonly property int idleSuspend: prefs.idleSuspend

    // Paleta de rice (Tok.schemes): define claro/escuro sozinha
    readonly property string palette: prefs.palette
    readonly property bool kdeGlass: prefs.kdeGlass
    readonly property bool wallpaperTint: prefs.wallpaperTint
    Binding { target: Tok; property: "tintGlass"; value: prefs.wallpaperTint }
    readonly property real kdeAnim: prefs.kdeAnim
    readonly property bool kdeButtonsLeft: prefs.kdeButtonsLeft
    readonly property bool light: Tok.schemes[prefs.palette] ? Tok.schemes[prefs.palette].light : prefs.theme === "claro" || (prefs.theme === "auto" && Clock.now.getHours() >= 7 && Clock.now.getHours() < 19)
    readonly property string theme: prefs.theme
    readonly property real roundness: prefs.roundness
    readonly property real motion: prefs.motion
    readonly property string wallpaperFit: prefs.wallpaperFit
    readonly property real wallpaperDim: prefs.wallpaperDim
    readonly property int wallpaperCycle: prefs.wallpaperCycle
    readonly property bool dnd: prefs.dnd
    readonly property bool nightLight: prefs.nightLight
    readonly property bool nightAuto: prefs.nightAuto
    readonly property int nightTemp: prefs.nightTemp
    readonly property var startupApps: { try { return JSON.parse(prefs.startupApps); } catch (e) { return []; } }
    readonly property int notifSeconds: prefs.notifSeconds
    readonly property bool welcomed: prefs.welcomed
    readonly property real glassOpacity: prefs.glassOpacity
    readonly property int cursorSize: prefs.cursorSize
    readonly property bool clock24: prefs.clock24
    readonly property string dateStyle: prefs.dateStyle
    readonly property bool weekStartsMonday: prefs.weekStart === "segunda"
    readonly property bool showLogo: prefs.showLogo
    readonly property bool showWorkspaces: prefs.showWorkspaces
    readonly property int workspaceCount: prefs.workspaceCount
    readonly property bool showStatus: prefs.showStatus
    readonly property int barHeight: ({ compacta: 30, normal: 36, alta: 42 })[prefs.barSize] || 36
    // Estilo (Configurações → Barra): clássica (de ponta a ponta), flutuante (solta das bordas),
    // ilhas (cada grupo uma pílula) ou sem fundo. Os soltos ganham um respiro em cima.
    readonly property string barStyle: prefs.barStyle
    readonly property int barGap: (prefs.barStyle === "flutuante" || prefs.barStyle === "ilhas") ? 6 : 0
    // Tudo o que a barra ocupa no topo: os painéis abrem logo abaixo disso
    readonly property int barSpace: barHeight + barGap
    Binding { target: Tok; property: "accentName"; value: prefs.accent }
    Binding { target: Tok; property: "paletteName"; value: prefs.palette }
    // Destaque do wallpaper: a cor amostrada mudou → borda das janelas e terminal acompanham
    Connections {
        target: Tok
        function onAutoAccentChanged() { if (prefs.accent === "auto" || prefs.palette === "wallpaper") autoSave.restart(); }
        function onAutoHueChanged() { if (prefs.palette === "wallpaper") autoSave.restart(); }
    }
    Timer { id: autoSave; interval: 600; onTriggered: { HyprConf.save(); Terminal.save(); } }
    Binding { target: Tok; property: "light"; value: root.light }
    Binding { target: Tok; property: "roundness"; value: prefs.roundness }
    Binding { target: Tok; property: "motion"; value: prefs.motion }
    // Tema automático: ao virar claro/escuro, borda das janelas e terminal acompanham.
    onLightChanged: if (prefs.theme === "auto") { HyprConf.save(); Terminal.save(); }
    Binding { target: Tok; property: "glassOpacity"; value: prefs.glassOpacity }
    Binding { target: Tok; property: "font"; value: prefs.uiFont || "Geist" }
    Binding { target: Tok; property: "fontScale"; value: prefs.textScale || 1 }
    readonly property string uiFont: prefs.uiFont
    readonly property real textScale: prefs.textScale
    readonly property string dockPosition: prefs.dockPosition
    readonly property int dockIcon: prefs.dockIcon
    readonly property real dockMagnify: prefs.dockMagnify
    readonly property bool dockAutohide: prefs.dockAutohide
    readonly property string dockStyle: prefs.dockStyle
    readonly property string dockIndicator: prefs.dockIndicator
    readonly property bool dockShowOpen: prefs.dockShowOpen
    readonly property var dockPinned: { try { return JSON.parse(prefs.dockPinned); } catch (e) { return []; } }
    function setPinned(list) { set("dockPinned", JSON.stringify(list)); }

    readonly property string wallpaperUrl: url(prefs.wallpaper || defaultWallpaper)
    readonly property string lockUrl: prefs.lockWallpaper === "desktop" ? wallpaperUrl : url(defaultWallpaper)

    // Caminho → URL de arquivo (espaços, acentos e # no nome não quebram a imagem).
    function url(path) { return "file://" + path.split("/").map(encodeURIComponent).join("/"); }

    function set(key, value) {
        if (prefs[key] === value) return;
        prefs[key] = value;
        file.writeAdapter();
        if (key === "accent" || key === "theme" || key === "palette") { HyprConf.save(); Terminal.save(); }   // borda e terminal na cor nova
        if (key === "roundness") HyprConf.set("rounding", Math.round(14 * value));   // janelas acompanham
        if (key === "cursorSize") {
            Quickshell.execDetached(["hyprctl", "setcursor", "Adwaita", String(value)]);
            HyprConf.save();                                           // XCURSOR_SIZE para os apps
        }
    }

    // Várias de uma vez (rices): muda tudo e grava uma vez só. Com set() em sequência, a
    // releitura do arquivo (watchChanges) chegava com uma gravação anterior e desfazia parte.
    function setMany(obj) {
        const changed = Object.keys(obj).filter(k => prefs[k] !== obj[k]);
        if (!changed.length) return;
        for (const k of changed) prefs[k] = obj[k];
        file.writeAdapter();
        if (changed.includes("roundness") && !("rounding" in obj)) HyprConf.set("rounding", Math.round(14 * obj.roundness));
        if (changed.includes("accent") || changed.includes("theme") || changed.includes("palette")) { HyprConf.save(); Terminal.save(); }
    }

    FileView {
        id: file
        path: root.dir + (root.kde ? "/kde.json" : "/shell.json")
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => { if (err === FileViewError.FileNotFound) mkdir.running = true; }
        // Arquivo de versão antiga (sem as opções novas): regrava uma vez com todas, para quem
        // edita à mão enxergar tudo. Não entra em laço: na releitura já não falta nenhuma.
        onLoaded: {
            const t = text();
            const keys = ["dock", "wallpaper", "lockWallpaper", "lockDim", "loginWallpaper", "accent",
                          "clockSeconds", "showDate", "showAppName", "idleLock", "idleSuspend",
                          "theme", "glassOpacity", "cursorSize", "clock24", "dateStyle", "weekStart",
                          "showLogo", "showWorkspaces", "workspaceCount", "showStatus", "barSize", "barStyle", "palette", "kdeGlass", "kdeAnim", "kdeButtonsLeft", "wallpaperTint", "uiFont", "textScale",
                          "dockPosition", "dockIcon", "dockMagnify", "dockAutohide", "dockStyle", "dockIndicator",
                          "dockShowOpen", "dockPinned", "roundness", "motion", "wallpaperFit", "wallpaperDim",
                          "wallpaperCycle", "dnd", "nightLight", "nightAuto", "nightTemp", "startupApps", "notifSeconds",
                          "welcomed"];
            if (keys.some(k => !t.includes('"' + k + '"'))) writeAdapter();
        }
        adapter: JsonAdapter {
            id: prefs
            property bool dock: false
            property string wallpaper: ""
            property string lockWallpaper: "padrao"
            property bool lockDim: true
            property string loginWallpaper: ""
            property string accent: "violeta"
            property bool clockSeconds: false
            property bool showDate: true
            property bool showAppName: true
            property int idleLock: 10
            property int idleSuspend: 0
            property string theme: "escuro"
            property real glassOpacity: 0.55
            property int cursorSize: 24
            property bool clock24: true
            property string dateStyle: "curta"
            property string weekStart: "domingo"
            property bool showLogo: true
            property bool showWorkspaces: true
            property int workspaceCount: 5
            property bool showStatus: true
            property string barSize: "normal"
            property string barStyle: "classica"
            property string palette: ""
            property bool kdeGlass: true
            property bool wallpaperTint: false
            property real kdeAnim: 1
            property bool kdeButtonsLeft: true
            property string uiFont: "Geist"
            property real textScale: 1
            property string dockPosition: "baixo"
            property int dockIcon: 46
            property real dockMagnify: 0.35
            property bool dockAutohide: false
            property string dockStyle: "vidro"
            property string dockIndicator: "ponto"
            property bool dockShowOpen: true
            property string dockPinned: '["kitty", "org.kde.dolphin"]'
            property real roundness: 1
            property real motion: 1
            property string wallpaperFit: "preencher"
            property real wallpaperDim: 0
            property int wallpaperCycle: 0
            property bool dnd: false
            property bool nightLight: false
            property bool nightAuto: false
            property int nightTemp: 4000
            property string startupApps: "[]"
            property int notifSeconds: 6
            property bool welcomed: false
        }
    }

    // Troca sozinha de fundo: a cada `wallpaperCycle` minutos, a próxima imagem da lista.
    Timer {
        interval: Math.max(1, prefs.wallpaperCycle) * 60000
        running: prefs.wallpaperCycle > 0
        repeat: true
        onTriggered: if (!cycleList.running) cycleList.running = true
    }
    Process {
        id: cycleList
        command: ["sh", Qt.resolvedUrl("../scripts/wallpapers.sh").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n").filter(x => x);
                if (l.length < 2) return;
                const i = l.indexOf(root.currentWallpaper);
                const next = l[(i + 1) % l.length];
                root.set("wallpaper", next === root.defaultWallpaper ? "" : next);
            }
        }
    }

    Process {
        id: mkdir
        command: ["mkdir", "-p", root.dir]
        onExited: file.writeAdapter()
    }
}
