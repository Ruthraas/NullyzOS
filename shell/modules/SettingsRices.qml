import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Rices: um "monitor" no topo desenha o rice escolhido nas cores dele
// (wallpaper, barra no estilo do rice, terminal, app e dock) e, embaixo, os rices em chips
// com a amostra de cor. Clicar mostra; "Usar este" aplica pelo nullyzos-rice (cópia do que
// muda; snapshot antes se instalar pacotes ou arquivos). "Desfazer" volta como estava.
SettingsPage {
    id: page
    title: "Rices"
    subtitle: "Visuais prontos: paleta, barra, dock e cantos de uma vez. Dá para voltar quando quiser."

    property var rices: []
    property string current: "nullyz"
    property string shown: ""           // rice na prévia (padrão: o em uso)
    property string busy: ""            // id em aplicação ("-" = desfazendo)
    property var log: []
    readonly property string desktop: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").indexOf("KDE") >= 0 ? "kde" : "hyprland"
    readonly property var sel: {
        const id = shown || current;
        return rices.find(r => r.id === id) || rices[0] || null;
    }

    // Cores de um rice: a paleta dele (Tok.schemes) ou a do Nullyz (escuro/claro + destaque)
    function colorsOf(r) {
        const p = (r && r.preferencias) || {};
        const s = Tok.schemes[p.palette || ""];
        if (s) return s;
        const light = p.theme === "claro";
        const base = Tok.palettes[light ? "claro" : "escuro"];
        const a = Tok.accents[p.accent] || Tok.accents.violeta;
        return {
            name: "Nullyz", light: light, bg: base.bg, surface: base.surface, border: base.border,
            surfaceHi: light ? Tok.palettes.claro.bg : Tok.palettes.escuro.surface,
            text: base.text, muted: base.muted, accent: light ? a.light : a.color,
            onAccent: light ? base.surface : base.bg,
            success: Tok.success, warning: Tok.warning, error: Tok.error
        };
    }

    function refresh() { if (!list.running) list.running = true; }
    function run(args, id) {
        if (busy) return;
        busy = id; log = [];
        runner.command = ["nullyzos-rice"].concat(args);
        runner.running = true;
    }

    Process {
        id: list
        running: true
        command: ["sh", "-c", "nullyzos-rice lista; echo '@@'; nullyzos-rice atual"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("@@");
                try { page.rices = JSON.parse(parts[0]); } catch (e) { page.rices = []; }
                page.current = (parts[1] || "nullyz").trim() || "nullyz";
            }
        }
    }
    Process {
        id: runner
        stdout: SplitParser { onRead: line => page.log = page.log.concat([line]).slice(-60) }
        stderr: SplitParser { onRead: line => page.log = page.log.concat([line]).slice(-60) }
        onExited: { page.busy = ""; page.refresh(); }
    }

    // ---- o monitor -------------------------------------------------------------------------
    Rectangle {
        id: screen
        readonly property var c: page.colorsOf(page.sel)
        readonly property var pr: (page.sel && page.sel.preferencias) || {}
        readonly property real u: width / 100                 // 1% da largura
        readonly property real rad: u * 1.1 * (pr.roundness === undefined ? 1 : pr.roundness)
        readonly property string bar: pr.barStyle || "classica"
        width: parent.width
        height: Math.round(width * 0.56)
        radius: Tok.rCard
        color: c.bg
        clip: true
        border { width: 1; color: Tok.border }
        Behavior on color { ColorAnimation { duration: Tok.slow } }

        // wallpaper: duas manchas da cor de destaque
        Rectangle {
            x: parent.width * 0.52; y: -parent.height * 0.25
            width: parent.width * 0.7; height: width; radius: width / 2
            color: screen.c.accent; opacity: screen.c.light ? 0.22 : 0.30
            Behavior on color { ColorAnimation { duration: Tok.slow } }
        }
        Rectangle {
            x: -parent.width * 0.15; y: parent.height * 0.55
            width: parent.width * 0.5; height: width; radius: width / 2
            color: screen.c.accent; opacity: screen.c.light ? 0.12 : 0.16
            Behavior on color { ColorAnimation { duration: Tok.slow } }
        }

        // barra (clássica, flutuante, ilhas ou sem fundo)
        Item {
            id: pbar
            readonly property real g: screen.bar === "flutuante" || screen.bar === "ilhas" ? screen.u * 0.8 : 0
            x: g; y: g
            width: parent.width - 2 * g; height: screen.u * 3.4
            Rectangle {
                visible: screen.bar === "classica" || screen.bar === "flutuante"
                anchors.fill: parent
                radius: screen.bar === "flutuante" ? Math.min(height / 2, screen.rad) : 0
                color: screen.c.surface; opacity: 0.88
                border { width: screen.bar === "flutuante" ? 1 : 0; color: screen.c.border }
            }
            Rectangle {   // ilha esquerda
                visible: screen.bar === "ilhas"
                width: screen.u * 13; height: parent.height
                radius: Math.min(height / 2, screen.rad); color: screen.c.surface; opacity: 0.9
                border { width: 1; color: screen.c.border }
            }
            Rectangle {   // ilha do meio
                visible: screen.bar === "ilhas"
                x: (parent.width - width) / 2; width: screen.u * 16; height: parent.height
                radius: Math.min(height / 2, screen.rad); color: screen.c.surface; opacity: 0.9
                border { width: 1; color: screen.c.border }
            }
            Rectangle {   // ilha direita
                visible: screen.bar === "ilhas"
                x: parent.width - width; width: screen.u * 17; height: parent.height
                radius: Math.min(height / 2, screen.rad); color: screen.c.surface; opacity: 0.9
                border { width: 1; color: screen.c.border }
            }
            Row {
                x: screen.u * 1.4; anchors.verticalCenter: parent.verticalCenter
                spacing: screen.u * 0.7
                Rectangle { width: screen.u * 2.6; height: screen.u * 0.9; radius: height / 2; color: screen.c.accent }
                Repeater { model: 4; Rectangle { width: screen.u * 0.9; height: width; radius: width / 2; color: screen.c.muted; opacity: 0.6 } }
            }
            Text {
                anchors.centerIn: parent
                text: "seg 16 nov  14:32"
                color: screen.c.text
                font { family: Tok.font; pixelSize: Math.max(8, screen.u * 1.3); weight: Font.DemiBold }
            }
            Row {
                anchors { right: parent.right; rightMargin: screen.u * 1.6; verticalCenter: parent.verticalCenter }
                spacing: screen.u * 0.8
                Repeater { model: 3; Rectangle { width: screen.u * 1.3; height: width; radius: screen.u * 0.3; color: screen.c.text; opacity: 0.75 } }
            }
        }

        // janela de app (atrás)
        Rectangle {
            x: parent.width * 0.47; y: parent.height * 0.15
            width: parent.width * 0.44; height: parent.height * 0.58
            radius: screen.rad; color: screen.c.surface
            border { width: 1; color: screen.c.border }
            Rectangle {   // lateral
                x: 1; y: 1; width: parent.width * 0.28; height: parent.height - 2
                radius: screen.rad; color: screen.c.surfaceHi
                Column {
                    x: screen.u * 1.2; y: screen.u * 1.6; spacing: screen.u * 0.9
                    Repeater {
                        model: 5
                        Rectangle {
                            required property int index
                            width: screen.u * (index === 3 ? 6 : 8); height: screen.u * 0.8; radius: height / 2
                            color: index === 0 ? screen.c.accent : screen.c.text; opacity: index === 0 ? 1 : 0.2
                        }
                    }
                }
            }
            Column {
                x: parent.width * 0.33; y: screen.u * 1.6; spacing: screen.u * 0.9
                Text { text: "Configurações"; color: screen.c.text; font { family: Tok.font; pixelSize: Math.max(8, screen.u * 1.5); weight: Font.DemiBold } }
                Rectangle { width: screen.u * 20; height: screen.u * 0.7; radius: height / 2; color: screen.c.muted; opacity: 0.5 }
                Grid {
                    columns: 3; spacing: screen.u * 0.8
                    Repeater {
                        model: 6
                        Rectangle {
                            required property int index
                            width: screen.u * 6.4; height: screen.u * 4.4; radius: screen.rad * 0.6
                            color: index === 0 ? screen.c.accent : screen.c.surfaceHi
                            opacity: index === 0 ? 0.45 : 1
                            border { width: 1; color: screen.c.border }
                        }
                    }
                }
                Rectangle {
                    width: screen.u * 9; height: screen.u * 2.2; radius: screen.rad * 0.5
                    color: screen.c.accent
                    Text { anchors.centerIn: parent; text: "Aplicar"; color: screen.c.onAccent; font { family: Tok.font; pixelSize: Math.max(7, screen.u * 1.1); weight: Font.DemiBold } }
                }
            }
        }

        // terminal (na frente, ativo: borda na cor de destaque)
        Rectangle {
            x: parent.width * 0.09; y: parent.height * 0.28
            width: parent.width * 0.46; height: parent.height * 0.5
            radius: screen.rad; color: screen.c.bg
            border { width: Math.max(1, screen.u * 0.2); color: screen.c.accent }
            Column {
                x: screen.u * 1.6; y: screen.u * 1.6; spacing: screen.u * 0.35
                Repeater {
                    model: [["~/projetos/nullyz", "p"], ["❯ nullyzos-rice aplicar " + (page.sel ? page.sel.id : ""), "t"],
                            [":: rice: " + (page.sel ? page.sel.nome : ""), "m"], [":: pronto", "s"], ["", "t"], ["❯ ▍", "p"]]
                    Text {
                        required property var modelData
                        text: modelData[0]
                        color: modelData[1] === "p" ? screen.c.accent : modelData[1] === "m" ? screen.c.muted
                             : modelData[1] === "s" ? screen.c.success : screen.c.text
                        font { family: Tok.mono; pixelSize: Math.max(7, screen.u * 1.2) }
                    }
                }
            }
        }

        // dock (flutuante, vidro/sólido/sem fundo)
        Rectangle {
            readonly property string st: screen.pr.dockStyle || "vidro"
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: screen.u * 1.4 }
            width: dockRow.width + screen.u * 1.6; height: screen.u * 6
            radius: Math.min(height / 2, screen.rad * 1.4)
            color: st === "transparente" ? "transparent" : screen.c.surface
            opacity: st === "vidro" ? 0.85 : 1
            border { width: st === "transparente" ? 0 : 1; color: screen.c.border }
            Row {
                id: dockRow
                anchors.centerIn: parent
                spacing: screen.u * 0.8
                Repeater {
                    model: 5
                    Rectangle {
                        required property int index
                        width: screen.u * 4.2; height: width; radius: screen.rad * 0.8
                        color: index === 0 ? screen.c.accent : screen.c.surfaceHi
                        border { width: 1; color: screen.c.border }
                    }
                }
            }
        }

        // nome do rice na prévia
        Rectangle {
            anchors { left: parent.left; bottom: parent.bottom; margins: screen.u * 1.4 }
            width: tagName.implicitWidth + 20; height: 26; radius: 13
            color: Qt.rgba(0, 0, 0, 0.45)
            Txt { id: tagName; anchors.centerIn: parent; text: page.sel ? page.sel.nome : ""; size: 12; color: Tok.palettes.escuro.text; font.weight: Font.DemiBold }
        }
    }

    // ---- ação do rice na prévia ------------------------------------------------------------
    Item {
        width: parent.width; height: 48
        Column {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; right: useBtn.left; rightMargin: 12 }
            spacing: 2
            Txt { width: parent.width; text: page.sel ? page.sel.descricao : ""; size: 13; wrapMode: Text.Wrap; elide: Text.ElideNone }
            Txt { text: page.sel ? "Por " + page.sel.autor + " · " + page.sel.licenca : ""; size: 11; muted: true }
        }
        Chip {
            id: useBtn
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            readonly property bool here: page.sel && (page.sel.desktop === page.desktop || page.sel.desktop === "ambos")
            text: !page.sel ? "" : page.sel.id === page.current ? "Em uso" : !here ? (page.sel.desktop === "kde" ? "Só no KDE" : "Só no Hyprland")
                : page.busy === page.sel.id ? "Aplicando…" : "Usar este"
            active: page.sel && page.sel.id !== page.current && here
            onClicked: if (page.sel && page.sel.id !== page.current && here) page.run(["aplicar", page.sel.id], page.sel.id)
        }
    }

    // ---- os rices em chips -----------------------------------------------------------------
    Flow {
        width: parent.width
        spacing: 8
        Repeater {
            model: page.rices
            Rectangle {
                id: chip
                required property var modelData
                readonly property var c: page.colorsOf(modelData)
                readonly property bool picked: page.sel && page.sel.id === modelData.id
                width: 168; height: 52
                radius: Tok.rButton + 2
                color: chipArea.containsMouse ? Tok.hover : "transparent"
                border { width: picked ? 2 : 1; color: picked ? Tok.accent : Tok.border }
                scale: chipArea.pressed ? 0.96 : 1
                Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                // amostra: fundo da paleta com o canto na cor de destaque
                Rectangle {
                    x: 10; anchors.verticalCenter: parent.verticalCenter
                    width: 30; height: 30; radius: 8
                    color: chip.c.bg
                    clip: true
                    border { width: 1; color: Tok.edge }
                    Rectangle { x: 13; y: 13; width: 17; height: 17; radius: 6; color: chip.c.accent }
                }
                Column {
                    x: 50; anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 58
                    Row {
                        spacing: 6
                        Txt { text: chip.modelData.nome.replace("Nullyz ", ""); size: 14; font.weight: Font.Medium }
                        Rectangle {
                            visible: page.current === chip.modelData.id
                            anchors.verticalCenter: parent.verticalCenter
                            width: 7; height: 7; radius: 3.5; color: Tok.success
                        }
                    }
                    Txt { text: chip.c.light ? "Claro" : "Escuro"; size: 11; muted: true }
                }
                MouseArea {
                    id: chipArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.shown = chip.modelData.id
                    Accessible.name: "Ver " + chip.modelData.nome
                }
            }
        }
    }

    Row {
        spacing: 10
        Chip {
            text: page.busy === "-" ? "Desfazendo…" : "Desfazer o último"
            onClicked: page.run(["desfazer"], "-")
        }
        Txt { anchors.verticalCenter: parent.verticalCenter; text: "Volta as configurações de antes do último rice."; muted: true; size: 12 }
    }

    // Saída do nullyzos-rice (o que está fazendo, ou por que não deu)
    Rectangle {
        visible: page.log.length > 0
        width: parent.width
        height: logText.implicitHeight + 24
        radius: Tok.rField
        color: Tok.surfaceHi
        Text {
            id: logText
            x: 12; y: 12
            width: parent.width - 24
            text: page.log.join("\n")
            color: Tok.muted
            wrapMode: Text.Wrap
            font { family: Tok.mono; pixelSize: Math.round(12 * Tok.fontScale) }
        }
    }

    Txt {
        width: parent.width
        text: "Rices de outras pessoas entram com o autor avisado e a licença conferida, e nunca rodam scripts: só copiam os arquivos listados na receita. Quer sugerir um? Abra uma issue em github.com/Ruthraas/NullyzOS."
        muted: true; size: 12
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
}
