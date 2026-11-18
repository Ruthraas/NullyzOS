import QtQuick
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Aparência: fundo da área de trabalho e o dock.
SettingsPage {
    id: page
    title: "Aparência"
    subtitle: "O fundo e o que aparece na área de trabalho."

    property var images: []
    readonly property string current: Prefs.currentWallpaper

    Process {
        running: true
        command: ["sh", Qt.resolvedUrl("../scripts/wallpapers.sh").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                // O padrão sempre primeiro; o resto na ordem das pastas.
                const list = text.split("\n").filter(l => l !== "" && l !== Prefs.defaultWallpaper);
                list.unshift(Prefs.defaultWallpaper);
                // O escolhido fica na lista mesmo se estiver fora das pastas vasculhadas.
                if (!list.includes(page.current)) list.push(page.current);
                page.images = list;
            }
        }
    }

    // ---- cor de destaque ---------------------------------------------------------------
    Item {
        width: parent.width; height: 20
        Txt { text: "Cor de destaque"; font.weight: Font.DemiBold }
        Txt { anchors.right: parent.right; text: (Tok.accents[Tok.accentName] || Tok.accents.violeta).name; muted: true; font.pixelSize: 13 }
    }
    Row {
        spacing: 14
        Repeater {
            model: Tok.accentOrder
            Item {
                id: dot
                required property string modelData
                readonly property bool chosen: Tok.accentName === modelData
                width: 36; height: 36
                // Anel do escolhido: entra crescendo com overshoot
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border { width: 2; color: Tok.accents[dot.modelData].color }
                    scale: dot.chosen ? 1 : 0.6
                    opacity: dot.chosen ? 1 : 0
                    Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
                    Behavior on opacity { NumberAnimation { duration: Tok.fast } }
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 26; height: 26; radius: 13
                    color: Tok.accents[dot.modelData].color
                    scale: dotArea.pressed ? 0.85 : (dotArea.containsMouse ? 1.1 : 1)
                    Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                }
                MouseArea {
                    id: dotArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Prefs.set("accent", dot.modelData)
                    Accessible.name: "Cor " + Tok.accents[dot.modelData].name
                }
            }
        }
    }

    Item { width: 1; height: 6 }

    Txt { text: "Fundo da área de trabalho"; font.weight: Font.DemiBold }
    Flow {
        width: parent.width
        spacing: 12
        Repeater {
            model: page.images
            SettingsThumb {
                required property string modelData
                path: modelData
                selected: modelData === page.current
                onPicked: Prefs.set("wallpaper", modelData === Prefs.defaultWallpaper ? "" : modelData)
            }
        }
    }
    Txt {
        width: parent.width
        text: "Para aparecer aqui, coloque a imagem na pasta Imagens."
        muted: true
        font.pixelSize: 13
    }
}
