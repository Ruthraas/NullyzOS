import QtQuick
import Quickshell.Io
import qs.theme
import qs.components

// Configurações → Atalhos: todos os atalhos de teclado com descrição, lidos do próprio
// Hyprland (`hyprctl binds -j`), então mostra também os que o usuário criou.
SettingsPage {
    id: page
    title: "Atalhos"
    subtitle: "Teclas para fazer as coisas mais rápido. Super é a tecla do Windows."

    property var binds: []

    readonly property var keyNames: ({
        space: "Espaço", Return: "Enter", Escape: "Esc", comma: ",", period: ".", Tab: "Tab",
        left: "←", right: "→", up: "↑", down: "↓", Left: "←", Right: "→", Up: "↑", Down: "↓", h: "H", j: "J", k: "K", l: "L",
        mouse_down: "Roda ↓", mouse_up: "Roda ↑", "mouse:272": "Clique", "mouse:273": "Clique direito",
        Print: "Print"
    })
    function keys(b) {
        const out = [];
        if (b.modmask & 64) out.push("Super");
        if (b.modmask & 4) out.push("Ctrl");
        if (b.modmask & 8) out.push("Alt");
        if (b.modmask & 1) out.push("Shift");
        const k = String(b.key || "");
        out.push(page.keyNames[k] || (k.length === 1 ? k.toUpperCase() : k.replace(/^XF86/, "")));
        return out;
    }

    Process {
        running: true
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let list = [];
                try { list = JSON.parse(text); } catch (e) { list = []; }
                const seen = {};
                page.binds = list.filter(b => b.description && b.has_description !== false)
                    .filter(b => { const k = b.description; if (seen[k]) return false; seen[k] = true; return true; });
            }
        }
    }

    Rectangle {
        visible: page.binds.length > 0
        width: parent.width
        height: list.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: list
            width: parent.width
            Repeater {
                model: page.binds
                Item {
                    required property var modelData
                    required property int index
                    width: list.width; height: 42
                    Txt { x: 16; anchors.verticalCenter: parent.verticalCenter; width: parent.width - keyRow.width - 48; text: parent.modelData.description }
                    Row {
                        id: keyRow
                        anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                        spacing: 4
                        Repeater {
                            model: page.keys(parent.parent.modelData)
                            Rectangle {
                                required property string modelData
                                width: Math.max(26, kl.implicitWidth + 14); height: 24
                                radius: 6
                                color: Tok.surfaceHi
                                border { width: 1; color: Tok.border }
                                Txt { id: kl; anchors.centerIn: parent; text: parent.modelData; font { family: Tok.mono; pixelSize: 12 } }
                            }
                        }
                    }
                    Rectangle {
                        visible: parent.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                }
            }
        }
    }
    Txt { visible: page.binds.length === 0; text: "Lendo os atalhos…"; muted: true }
}
