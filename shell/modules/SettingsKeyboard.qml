import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Teclado e mouse: layout, campo de teste, repetição, ponteiro e rolagem.
// Grava em HyprConf (gera ~/.config/nullyzos/hyprland.lua e recarrega o Hyprland).
SettingsPage {
    id: page
    title: "Teclado e mouse"
    subtitle: "Layout do teclado, ponteiro e rolagem."

    // [nome, layout, variante]; "" = o escolhido na instalação
    readonly property var layouts: [
        ["Como na instalação", "", ""],
        ["Português (Brasil, ABNT2)", "br", ""],
        ["Inglês (EUA)", "us", ""],
        ["Inglês (EUA, internacional)", "us", "intl"],
        ["Português (Portugal)", "pt", ""],
        ["Espanhol", "es", ""],
        ["Inglês (Reino Unido)", "gb", ""]
    ]

    Txt { text: "Layout do teclado"; font.weight: Font.DemiBold }
    Rectangle {
        width: parent.width
        height: list.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: list
            width: parent.width
            Repeater {
                model: page.layouts
                Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool chosen: HyprConf.kbLayout === modelData[1] && HyprConf.kbVariant === modelData[2]
                    width: list.width; height: 42
                    radius: Tok.rField
                    color: area.containsMouse ? Tok.hover : "transparent"
                    Rectangle {
                        x: 16; anchors.verticalCenter: parent.verticalCenter
                        width: 18; height: 18; radius: 9
                        color: "transparent"
                        border { width: 2; color: parent.chosen ? Tok.accent : Tok.border }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 8; height: 8; radius: 4
                            color: Tok.accent
                            scale: parent.parent.chosen ? 1 : 0
                            Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
                        }
                    }
                    Txt { x: 48; anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[0] }
                    Rectangle {
                        visible: parent.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { HyprConf.set("kbVariant", parent.modelData[2]); HyprConf.set("kbLayout", parent.modelData[1]); }
                    }
                }
            }
        }
    }

    // Campo de teste: digitar aqui mostra se acentos e ç saem certo.
    Rectangle {
        width: parent.width; height: 44
        radius: Tok.rButton + 2
        color: Tok.surfaceHi
        border { width: 1; color: test.activeFocus ? Tok.accent : Tok.border }
        TextInput {
            id: test
            anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
            verticalAlignment: TextInput.AlignVCenter
            color: Tok.text
            font { family: Tok.font; pixelSize: Math.round(15 * Tok.fontScale) }
            Keys.onEscapePressed: text = ""
        }
        Txt { x: 14; anchors.verticalCenter: parent.verticalCenter; visible: test.text === ""; text: "Digite aqui para testar: ação, pão, você…"; muted: true }
    }

    Item { width: 1; height: 4 }

    SettingsRow {
        title: "Repetição de tecla"
        description: "Quantas vezes por segundo a letra repete ao segurar a tecla."
        Row {
            spacing: 12
            Txt { anchors.verticalCenter: parent.verticalCenter; text: (HyprConf.repeatRate || 35) + "/s"; muted: true; width: 40; size: 13}
            Slider {
                anchors.verticalCenter: parent.verticalCenter; width: 200
                value: ((HyprConf.repeatRate || 35) - 15) / 45
                onMoved: v => HyprConf.set("repeatRate", Math.round(15 + v * 45))
            }
        }
    }
    SettingsRow {
        title: "Velocidade do ponteiro"
        description: "Mouse e touchpad."
        Slider {
            width: 252
            value: (HyprConf.pointerSpeed + 1) / 2
            onMoved: v => HyprConf.set("pointerSpeed", Math.round((v * 2 - 1) * 20) / 20)
        }
    }
    SettingsRow {
        title: "Rolagem natural no touchpad"
        description: "O conteúdo acompanha os dedos, como no celular."
        Toggle { checked: HyprConf.naturalScroll; onToggled: v => HyprConf.set("naturalScroll", v) }
    }
}
