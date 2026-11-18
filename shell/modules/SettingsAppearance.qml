import QtQuick
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Aparência: fundo da área de trabalho e o dock.
Flickable {
    id: page
    contentHeight: col.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    property var images: []
    readonly property string current: Prefs.currentWallpaper

    Process {
        running: true
        command: ["sh", Qt.resolvedUrl("../scripts/wallpapers.sh").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = text.split("\n").filter(l => l !== "");
                if (!list.includes(Prefs.defaultWallpaper)) list.unshift(Prefs.defaultWallpaper);
                // O escolhido fica na lista mesmo se estiver fora das pastas vasculhadas.
                if (!list.includes(page.current)) list.push(page.current);
                page.images = list;
            }
        }
    }

    Column {
        id: col
        width: page.width
        spacing: 14

        SettingsHeader { title: "Aparência"; subtitle: "O fundo e o que aparece na área de trabalho." }

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

        Item { width: 1; height: 6 }

        SettingsRow {
            title: "Mostrar dock"
            description: "Apps fixados e abertos numa barra na parte de baixo da tela. Desligado, as janelas usam a tela até embaixo."
            Toggle { checked: Prefs.dock; onToggled: v => Prefs.set("dock", v) }
        }
    }
}
