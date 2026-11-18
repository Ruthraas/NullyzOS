import QtQuick
import Quickshell
import qs.theme
import qs.services
import qs.components

// Conteúdo de cada monitor bloqueado: o mesmo visual da tela de login (nullyzos-sddm):
// fundo em manchas, relógio grande, cartão de vidro com o N pixelado e o campo de senha.
Item {
    id: root
    property var lock

    // Fundo escolhido em Configurações → Tela de bloqueio, escurecido se pedido.
    Image {
        anchors.fill: parent
        source: Prefs.lockUrl
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.height)
        smooth: true
    }
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
        visible: Prefs.lockDim
    }

    // Relógio, data e cartão numa coluna só, centralizada: não se sobrepõem em tela baixa.
    Column {
        anchors.centerIn: parent
        spacing: 36

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Clock.time
                font { pixelSize: Math.min(112, root.height * 0.13); weight: Font.Light; letterSpacing: -3 }
            }
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Clock.dateLong
                color: Qt.rgba(0.93, 0.93, 0.95, 0.86)
                font { pixelSize: 24; weight: Font.Medium }
            }
        }

        Glass {
            id: card
            anchors.horizontalCenter: parent.horizontalCenter
            width: 380; height: 250
            radius: Tok.rPanel
            color: Qt.rgba(24 / 255, 24 / 255, 34 / 255, 0.6)

            Column {
                anchors.centerIn: parent
                width: parent.width - 56
                spacing: 14

                PixelN { anchors.horizontalCenter: parent.horizontalCenter; cell: 7 }
                Txt {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Quickshell.env("USER") || ""
                    font { pixelSize: 20; weight: Font.DemiBold }
                }

                Rectangle {
                    width: parent.width; height: 48; radius: Tok.rField
                    color: Qt.rgba(1, 1, 1, 0.07)
                    border { width: 2; color: Tok.accent }
                    transform: Translate { id: shake }

                    TextInput {
                        id: field
                        anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        color: Tok.text
                        font { family: Tok.font; pixelSize: 16 }
                        enabled: !root.lock.busy
                        focus: true
                        Component.onCompleted: forceActiveFocus()
                        Keys.onReturnPressed: { root.lock.submit(text); text = ""; }
                        Keys.onEnterPressed: { root.lock.submit(text); text = ""; }
                        Keys.onEscapePressed: text = ""
                        Accessible.name: "Senha"
                    }
                    Txt {
                        anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                        visible: field.text.length === 0
                        text: root.lock.busy ? "Conferindo…" : "Senha"
                        muted: true
                        font.pixelSize: 16
                    }
                }

                Txt {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 18
                    text: root.lock.status
                    color: Tok.error
                    font.pixelSize: 14
                }
            }
        }
    }

    // Senha errada: tremida curta (antecipação + amortecimento)
    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: shake; property: "x"; to: -12; duration: 50 }
        NumberAnimation { target: shake; property: "x"; to: 10; duration: 70 }
        NumberAnimation { target: shake; property: "x"; to: -6; duration: 60 }
        NumberAnimation { target: shake; property: "x"; to: 0; duration: 90; easing.type: Easing.OutCubic }
    }
    Connections {
        target: root.lock
        function onStatusChanged() { if (root.lock.status !== "") shakeAnim.start(); }
    }
}
