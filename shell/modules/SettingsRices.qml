import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Rices: os rices do catálogo verificado (rices/*/rice.toml), com autor,
// licença e link. "Usar" roda o nullyzos-rice (cópia do que muda e, se o rice instala
// pacotes ou arquivos, snapshot antes); "Desfazer" volta como estava.
SettingsPage {
    id: page
    title: "Rices"
    subtitle: "Visuais prontos para o seu desktop. Dá para voltar quando quiser."

    property var rices: []
    property string current: "nullyz"
    property string busy: ""            // id em aplicação ("-" = desfazendo)
    property var log: []
    readonly property string desktop: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").indexOf("KDE") >= 0 ? "kde" : "hyprland"

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

    Repeater {
        model: page.rices
        Rectangle {
            id: card
            required property var modelData
            readonly property bool here: modelData.desktop === page.desktop || modelData.id === "nullyz"
            readonly property bool using: page.current === modelData.id
            width: parent.width
            height: info.implicitHeight + 32
            radius: Tok.rField
            color: Tok.surface
            border { width: card.using ? 2 : 1; color: card.using ? Tok.accent : Tok.border }
            opacity: card.here ? 1 : 0.55
            Behavior on border.color { ColorAnimation { duration: Tok.fast } }

            Column {
                id: info
                x: 18; y: 16
                width: parent.width - 36 - action.width - 16
                spacing: 4
                Row {
                    spacing: 8
                    Txt { text: card.modelData.nome; size: 16; font.weight: Font.DemiBold }
                    Rectangle {
                        visible: card.using
                        anchors.verticalCenter: parent.verticalCenter
                        width: tagUse.implicitWidth + 14; height: 20; radius: 10
                        color: Tok.accent
                        Txt { id: tagUse; anchors.centerIn: parent; text: "Em uso"; size: 11; color: Tok.textOnAccent; font.weight: Font.DemiBold }
                    }
                    Rectangle {
                        visible: !card.here
                        anchors.verticalCenter: parent.verticalCenter
                        width: tagDesk.implicitWidth + 14; height: 20; radius: 10
                        color: Tok.surfaceHi
                        Txt { id: tagDesk; anchors.centerIn: parent; text: card.modelData.desktop === "kde" ? "Só KDE" : "Só Hyprland"; size: 11; muted: true }
                    }
                }
                Txt { width: parent.width; text: card.modelData.descricao; muted: true; size: 13; wrapMode: Text.Wrap; elide: Text.ElideNone }
                Txt {
                    width: parent.width
                    text: "Por " + card.modelData.autor + " · " + card.modelData.licenca
                        + (card.modelData.tipo === "arquivos" ? " · instala arquivos e pacotes (com snapshot antes)" : "")
                    size: 12; muted: true
                }
                Txt {
                    visible: card.modelData.autor !== "NullyzOS"
                    text: "Ver o original"
                    size: 12; color: Tok.accent
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally(card.modelData.origem) }
                }
            }
            Chip {
                id: action
                anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                visible: card.here && !card.using
                text: page.busy === card.modelData.id ? "Aplicando…" : "Usar"
                active: true
                onClicked: page.run(["aplicar", card.modelData.id], card.modelData.id)
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
            font { family: "Geist Mono"; pixelSize: Math.round(12 * Tok.fontScale) }
        }
    }

    Txt {
        width: parent.width
        text: "Rices de outras pessoas entram com o autor avisado e a licença conferida, e nunca rodam scripts: só copiam os arquivos listados na receita. Quer sugerir um? Abra uma issue em github.com/Ruthraas/NullyzOS."
        muted: true; size: 12
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
}
