import QtQuick
import Quickshell.Io
import qs.theme
import qs.components

// Configurações → Sobre: o símbolo e os dados do computador (scripts/sobre.sh).
Flickable {
    id: page
    contentHeight: col.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    property var info: []
    readonly property var labels: ["Versão", "Computador", "Processador", "Memória", "Vídeo", "Kernel"]

    Process {
        running: true
        command: ["sh", Qt.resolvedUrl("../scripts/sobre.sh").toString().replace("file://", "")]
        stdout: StdioCollector { onStreamFinished: page.info = text.split("\n") }
    }

    Column {
        id: col
        width: page.width
        spacing: 22

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 8
            spacing: 14
            PixelN { anchors.horizontalCenter: parent.horizontalCenter; cell: 11 }
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "NullyzOS"
                font { pixelSize: 28; weight: Font.DemiBold; letterSpacing: -0.5 }
            }
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.info[0] ? "Versão " + page.info[0] + " · Hyprland" : "Hyprland"
                muted: true
            }
        }

        Rectangle {
            width: parent.width
            height: rows.implicitHeight
            radius: Tok.rField
            color: Tok.surface
            border { width: 1; color: Tok.border }
            Column {
                id: rows
                width: parent.width
                Repeater {
                    model: page.labels.length - 1
                    Item {
                        required property int index
                        width: rows.width; height: 46
                        Txt { x: 16; anchors.verticalCenter: parent.verticalCenter; text: page.labels[index + 1]; muted: true }
                        Txt {
                            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                            width: Math.min(implicitWidth, parent.width * 0.62)
                            horizontalAlignment: Text.AlignRight
                            text: page.info[index + 1] || "…"
                        }
                        Rectangle {
                            visible: index > 0
                            anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                            height: 1
                            color: Tok.border
                        }
                    }
                }
            }
        }

        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "github.com/Ruthraas/NullyzOS"
            muted: true
            font.pixelSize: 13
        }
    }
}
