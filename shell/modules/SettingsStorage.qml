import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Armazenamento: quanto do disco está usado e o que ocupa mais na pasta
// pessoal (Downloads, Imagens, Vídeos…). Clique abre a pasta no Dolphin.
SettingsPage {
    id: page
    title: "Armazenamento"
    subtitle: "O espaço do disco e o que ocupa mais na sua pasta."

    property real used: 0
    property real total: 0
    property var folders: []            // [{ name, path, bytes }]
    property bool loading: true

    function gb(b) { return b >= 1e9 ? (b / 1e9).toFixed(1).replace(".", ",") + " GB" : Math.round(b / 1e6) + " MB"; }

    Process {
        running: true
        command: ["sh", "-c", "df -B1 --output=used,size \"$HOME\" | awk 'NR==2 { print \"disco\", $1, $2 }'; for d in DOWNLOAD PICTURES VIDEOS MUSIC DOCUMENTS DESKTOP; do p=$(xdg-user-dir $d 2>/dev/null); [ -d \"$p\" ] && [ \"$p\" != \"$HOME\" ] && echo \"pasta $(du -sb \"$p\" 2>/dev/null | cut -f1) $p\"; done; echo \"pasta $(du -sb \"$HOME/.cache\" 2>/dev/null | cut -f1) $HOME/.cache\"; echo \"pasta $(du -sb \"$HOME/.local/share/flatpak\" 2>/dev/null | cut -f1) $HOME/.local/share/flatpak\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = [];
                for (const l of text.split("\n")) {
                    const p = l.split(" ");
                    if (p[0] === "disco") { page.used = +p[1]; page.total = +p[2]; }
                    else if (p[0] === "pasta" && +p[1] > 0) {
                        const path = p.slice(2).join(" ");
                        const base = path.split("/").pop();
                        f.push({ path: path, bytes: +p[1], name: base === ".cache" ? "Cache dos apps" : base === "flatpak" ? "Apps do Flathub" : base });
                    }
                }
                page.folders = f.sort((a, b) => b.bytes - a.bytes);
                page.loading = false;
            }
        }
    }

    Rectangle {
        width: parent.width; height: 104
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            x: 20; y: 18
            width: parent.width - 40
            spacing: 10
            Item {
                width: parent.width; height: 26
                Txt { text: page.total ? page.gb(page.used) + " usados" : "Calculando…"; size: 20; font.weight: Font.DemiBold }
                Txt { anchors { right: parent.right; bottom: parent.bottom } text: page.total ? "de " + page.gb(page.total) + " · " + page.gb(page.total - page.used) + " livres" : ""; muted: true; size: 13 }
            }
            Rectangle {
                width: parent.width; height: 12; radius: 6
                color: Tok.surfaceHi
                Rectangle {
                    width: page.total ? Math.max(12, parent.width * page.used / page.total) : 0
                    height: parent.height; radius: 6
                    color: page.total && page.used / page.total > 0.9 ? Tok.error : Tok.accent
                    Behavior on width { NumberAnimation { duration: Tok.slow; easing.type: Easing.OutCubic } }
                }
            }
        }
    }

    Txt { text: "Na sua pasta"; font.weight: Font.DemiBold }
    Txt { visible: page.loading; text: "Somando as pastas…"; muted: true; size: 13 }
    Rectangle {
        visible: page.folders.length > 0
        width: parent.width; height: fCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: fCol
            width: parent.width
            Repeater {
                model: page.folders
                Rectangle {
                    id: fr
                    required property var modelData
                    required property int index
                    width: fCol.width; height: 52
                    radius: Tok.rField
                    color: frArea.containsMouse ? Tok.hover : "transparent"
                    Column {
                        x: 16; anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 32
                        spacing: 6
                        Item {
                            width: parent.width; height: 18
                            Txt { text: fr.modelData.name; size: 13 }
                            Txt { anchors.right: parent.right; text: page.gb(fr.modelData.bytes); muted: true; size: 12; font.features: { "tnum": 1 } }
                        }
                        Rectangle {
                            width: parent.width; height: 4; radius: 2
                            color: Tok.surfaceHi
                            Rectangle {
                                width: page.folders.length ? Math.max(4, parent.width * fr.modelData.bytes / page.folders[0].bytes) : 0
                                height: parent.height; radius: 2
                                color: Tok.accent
                                opacity: 0.8
                            }
                        }
                    }
                    MouseArea { id: frArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["xdg-open", fr.modelData.path]) }
                }
            }
        }
    }
}
