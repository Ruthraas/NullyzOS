import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Desempenho: uso ao vivo (processador, memória, disco, temperatura), perfil
// de energia, efeitos visuais e limpeza. Lê scripts/uso.sh a cada 2 s enquanto a página
// está aberta; o que precisa de root passa por /usr/lib/nullyzos/limpeza (pkexec).
SettingsPage {
    id: page
    title: "Desempenho"
    subtitle: "Como o computador está e o que deixa ele mais leve."

    property real cpu: 0                 // 0..1
    property var lastCpu: null
    property real memUsed: 0; property real memTotal: 0
    property real diskUsed: 0; property real diskTotal: 0
    property string temp: "-"
    property string profile: "-"
    property real cacheBytes: -1; property int cacheFiles: 0
    property int orphans: -1
    property real thumbs: -1
    property string busy: ""             // ação de limpeza em andamento
    property string confirm: ""          // "orfaos" aguardando o segundo clique
    property string message: ""

    readonly property string script: Qt.resolvedUrl("../scripts/uso.sh").toString().replace("file://", "")

    function gb(b) { return b >= 1e9 ? (b / 1e9).toFixed(1).replace(".", ",") + " GB" : Math.round(b / 1e6) + " MB"; }
    function parse(text) {
        for (const line of text.split("\n")) {
            const f = line.split(" ");
            if (f[0] === "cpu") {
                const t = +f[1], idle = +f[2];
                if (page.lastCpu && t > page.lastCpu.t) page.cpu = 1 - (idle - page.lastCpu.idle) / (t - page.lastCpu.t);
                page.lastCpu = { t: t, idle: idle };
            } else if (f[0] === "mem") { page.memTotal = +f[1] * 1024; page.memUsed = (+f[1] - +f[2]) * 1024; }
            else if (f[0] === "disco") { page.diskUsed = +f[1]; page.diskTotal = +f[2]; }
            else if (f[0] === "temp") page.temp = f[1];
            else if (f[0] === "perfil") page.profile = f[1] || "-";
            else if (f[0] === "cache") { page.cacheBytes = +f[1] || 0; page.cacheFiles = +f[2] || 0; }
            else if (f[0] === "orfaos") page.orphans = +f[1] || 0;
            else if (f[0] === "miniaturas") page.thumbs = +f[1] || 0;
        }
    }
    function root(action) {
        if (busy) return;
        if (action === "orfaos" && confirm !== "orfaos") { confirm = "orfaos"; confirmTimer.restart(); return; }
        confirm = "";
        busy = action;
        message = "";
        job.command = ["pkexec", "/usr/lib/nullyzos/limpeza", action];
        job.running = true;
        Panels.settingsAside = true;            // o pedido de senha fica por baixo das Configurações
    }

    Process {
        id: usage
        command: ["sh", page.script]
        stdout: StdioCollector { onStreamFinished: page.parse(text) }
    }
    Process {
        id: cleanInfo
        running: true
        command: ["sh", page.script, "--limpeza"]
        stdout: StdioCollector { onStreamFinished: page.parse(text) }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!usage.running) usage.running = true }
    Timer { id: confirmTimer; interval: 4000; onTriggered: page.confirm = "" }
    Process {
        id: job
        onExited: code => {
            Panels.settingsAside = false;
            page.message = code === 0 ? "Pronto." : code === 126 ? "" : "Não deu certo (erro " + code + ").";
            page.busy = "";
            cleanInfo.running = true;
            usage.running = true;
        }
    }

    // ---- uso agora -------------------------------------------------------------------
    Txt { text: "Agora"; font.weight: Font.DemiBold }
    Grid {
        width: parent.width
        columns: 2
        columnSpacing: 12; rowSpacing: 12
        Meter { label: "Processador"; value: page.cpu; detail: Math.round(page.cpu * 100) + "%" }
        Meter { label: "Memória"; value: page.memTotal ? page.memUsed / page.memTotal : 0; detail: page.gb(page.memUsed) + " de " + page.gb(page.memTotal) }
        Meter { label: "Disco"; value: page.diskTotal ? page.diskUsed / page.diskTotal : 0; detail: page.gb(page.diskUsed) + " de " + page.gb(page.diskTotal) }
        Meter {
            label: "Temperatura"
            value: page.temp === "-" ? 0 : Math.min(1, +page.temp / 100)
            detail: page.temp === "-" ? "Sem sensor" : page.temp + " °C"
            warn: page.temp !== "-" && +page.temp >= 85
        }
    }

    Item { width: 1; height: 6 }

    // ---- perfil de energia -----------------------------------------------------------
    SettingsRow {
        title: "Perfil de energia"
        description: page.profile === "-" ? "O serviço de perfis está desligado." : "Economia gasta menos bateria; Desempenho deixa o processador no máximo."
        Row {
            spacing: 8
            Chip { visible: page.profile === "-"; text: page.busy === "energia" ? "Ligando…" : "Ligar"; onClicked: page.root("energia") }
            Repeater {
                model: page.profile === "-" ? [] : [["power-saver", "Economia"], ["balanced", "Equilibrado"], ["performance", "Desempenho"]]
                Chip {
                    required property var modelData
                    text: modelData[1]
                    active: page.profile === modelData[0]
                    onClicked: { page.profile = modelData[0]; Quickshell.execDetached(["powerprofilesctl", "set", modelData[0]]); }
                }
            }
        }
    }

    SettingsRow {
        title: "Efeitos visuais"
        description: "Leve tira animações, desfoque e sombras das janelas: ajuda em computador mais fraco."
        Row {
            spacing: 8
            Chip { text: "Completo"; active: !HyprConf.light; onClicked: HyprConf.setEffects(true) }
            Chip { text: "Leve"; active: HyprConf.light; onClicked: HyprConf.setEffects(false) }
        }
    }

    Item { width: 1; height: 6 }

    // ---- limpeza ---------------------------------------------------------------------
    Txt { text: "Limpeza"; font.weight: Font.DemiBold }
    SettingsRow {
        title: "Cache de pacotes"
        description: page.cacheBytes < 0 ? "Calculando…"
            : page.gb(page.cacheBytes) + " em " + page.cacheFiles + " arquivos. Guarda as 2 últimas versões de cada pacote, para poder voltar atrás."
        Chip { text: page.busy === "pacotes" ? "Limpando…" : "Limpar"; onClicked: page.root("pacotes") }
    }
    SettingsRow {
        title: "Pacotes sem uso"
        description: page.orphans < 0 ? "Calculando…"
            : page.orphans === 0 ? "Nenhum: tudo que está instalado é usado por alguma coisa."
            : page.orphans + (page.orphans === 1 ? " pacote instalado como dependência que nada mais usa." : " pacotes instalados como dependência que nada mais usa.")
        Chip {
            visible: page.orphans > 0
            text: page.busy === "orfaos" ? "Removendo…" : page.confirm === "orfaos" ? "Clique de novo" : "Remover"
            active: page.confirm === "orfaos"
            onClicked: page.root("orfaos")
        }
    }
    SettingsRow {
        title: "Miniaturas"
        description: page.thumbs < 0 ? "Calculando…" : page.gb(page.thumbs) + " de prévias de imagens; são refeitas quando precisar."
        Chip {
            text: "Limpar"
            onClicked: {
                Quickshell.execDetached(["sh", "-c", "rm -rf \"$HOME/.cache/thumbnails\""]);
                page.thumbs = 0;
            }
        }
    }
    Txt {
        visible: page.message !== ""
        text: page.message
        color: page.message === "Pronto." ? Tok.accent : Tok.error
        size: 13
    }

    // Medidor: título, valor e barra que enche com a cor de destaque (vermelho se alto).
    component Meter: Rectangle {
        id: m
        property string label
        property string detail
        property real value: 0
        property bool warn: value >= 0.9
        width: (parent.width - 12) / 2
        height: 74
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Txt { x: 16; y: 14; text: m.label; muted: true; size: 13}
        Txt { anchors.right: parent.right; anchors.rightMargin: 16; y: 14; text: m.detail; size: 13; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
        Rectangle {
            x: 16; y: 46
            width: parent.width - 32; height: 8; radius: 4
            color: Tok.surfaceHi
            Rectangle {
                width: Math.max(parent.height, Math.min(1, m.value) * parent.width)
                height: parent.height; radius: parent.radius
                color: m.warn ? Tok.error : Tok.accent
                Behavior on width { NumberAnimation { duration: Tok.slow; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: Tok.panel } }
            }
        }
    }
}
