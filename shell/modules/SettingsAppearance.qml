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

    // ---- tema ----------------------------------------------------------------------------
    Txt { text: "Tema"; font.weight: Font.DemiBold }
    Row {
        spacing: 12
        Repeater {
            model: [["escuro", "Escuro"], ["claro", "Claro"]]
            Item {
                id: th
                required property var modelData
                readonly property bool dark: modelData[0] === "escuro"
                readonly property var pal: Tok.palettes[modelData[0]]
                readonly property bool chosen: Tok.light !== dark
                width: 156; height: 124
                // Miniatura desenhada: barra, janela e dock nas cores do tema
                Rectangle {
                    id: mini
                    width: parent.width; height: 98
                    radius: Tok.rButton + 2
                    color: th.pal.bg
                    border { width: th.chosen ? 2 : 1; color: th.chosen ? Tok.accent : Tok.edge }
                    scale: thArea.pressed ? 0.95 : (thArea.containsMouse ? 1.04 : 1)
                    Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                    Rectangle { x: 3; y: 3; width: parent.width - 6; height: 10; radius: 3; color: th.pal.surface }
                    Rectangle {
                        x: 22; y: 24; width: 92; height: 56; radius: 6
                        color: th.pal.surface
                        border { width: 1; color: th.pal.border }
                        Rectangle { x: 8; y: 10; width: 46; height: 5; radius: 2; color: th.pal.text }
                        Rectangle { x: 8; y: 20; width: 64; height: 4; radius: 2; color: th.pal.muted }
                        Rectangle { x: 8; y: 36; width: 30; height: 10; radius: 5; color: th.dark ? Tok.accentEntry.color : Tok.accentEntry.light }
                    }
                }
                Txt {
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
                    text: th.modelData[1]
                    size: 13
                    color: th.chosen ? Tok.text : Tok.muted
                }
                MouseArea {
                    id: thArea
                    anchors.fill: mini
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Prefs.set("theme", th.modelData[0])
                    Accessible.name: "Tema " + th.modelData[1]
                }
            }
        }
    }

    Item { width: 1; height: 6 }

    // ---- cor de destaque ---------------------------------------------------------------
    Item {
        width: parent.width; height: 20
        Txt { text: "Cor de destaque"; font.weight: Font.DemiBold }
        Txt { anchors.right: parent.right; text: (Tok.accents[Tok.accentName] || Tok.accents.violeta).name; muted: true; size: 13}
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

    SettingsRow {
        title: "Transparência do vidro"
        description: Tok.vm ? "Em máquina virtual o vidro fica quase opaco (sem desfoque)." : "Barra de menus, busca e painéis: quanto do fundo aparece através deles."
        Slider {
            width: 220
            enabled: !Tok.vm
            // Direita = mais transparente
            value: (0.9 - Prefs.glassOpacity) / 0.55
            onMoved: v => Prefs.set("glassOpacity", Math.round((0.9 - v * 0.55) * 100) / 100)
        }
    }
    SettingsRow {
        title: "Tamanho do cursor"
        description: "O ponteiro do mouse."
        Row {
            spacing: 8
            Repeater {
                model: [[24, "Normal"], [32, "Grande"], [48, "Enorme"]]
                Chip {
                    required property var modelData
                    text: modelData[1]
                    active: Prefs.cursorSize === modelData[0]
                    onClicked: Prefs.set("cursorSize", modelData[0])
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
        size: 13
    }
}
