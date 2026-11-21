// Tela durante a instalação (NullyzOS): o N pixelado acendendo pixel a pixel e mensagens
// sobre o sistema que trocam com fade (a cada 8 s), com pontinhos de progresso.
import QtQuick
import calamares.slideshow 1.0

Presentation {
    id: presentation

    // Fundo da área inteira (sem isto o Calamares deixa uma moldura branca em volta dos slides).
    Rectangle { anchors.fill: parent; color: "#0e0e13"; z: -1 }

    property int shown: 0
    readonly property var messages: [
        ["Instalando o NullyzOS", "Copiando o sistema e baixando o desktop que você escolheu. Leva alguns minutos; pode relaxar."],
        ["Começa do zero", "Um Arch Linux limpo, com o visual Nullyz pronto. Nada de AUR nem script de terceiros: só pacotes oficiais e assinados."],
        ["Do seu jeito", "Super + vírgula abre as Configurações: tema claro ou escuro, cor de destaque, dock, fontes, terminal e muito mais."],
        ["Seguro para atualizar", "Antes de cada atualização é tirado um snapshot. Se algo quebrar, é só escolher o ponto anterior no menu do boot."],
        ["Apps", "O Brave já vem como navegador. Outros apps saem do Flathub pelas Configurações, sem senha."]
    ]

    Timer {
        interval: 8000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: fade.restart()
    }
    SequentialAnimation {
        id: fade
        NumberAnimation { target: textBlock; property: "opacity"; to: 0; duration: 350; easing.type: Easing.InCubic }
        ScriptAction { script: presentation.shown = (presentation.shown + 1) % presentation.messages.length }
        ParallelAnimation {
            NumberAnimation { target: textBlock; property: "opacity"; to: 1; duration: 500; easing.type: Easing.OutCubic }
            NumberAnimation { target: textBlock; property: "y"; from: 12; to: 0; duration: 500; easing.type: Easing.OutCubic }
        }
    }

    Slide {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#171429" }
                GradientStop { position: 0.55; color: "#0e0e13" }
                GradientStop { position: 1.0; color: "#0b0b10" }
            }
        }

        Column {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.72, 620)
            spacing: 34

            // N acendendo pixel a pixel (em loop, devagar)
            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                spacing: 4
                Repeater {
                    model: "##...#####..######.####.######..#####...####...##".split("")
                    Rectangle {
                        required property string modelData
                        required property int index
                        width: 16; height: 16; radius: 3
                        color: modelData === "#" ? "#a99aff" : "#201d31"
                        opacity: modelData === "#" ? 0.25 : 1
                        SequentialAnimation on opacity {
                            running: modelData === "#"
                            loops: Animation.Infinite
                            PauseAnimation { duration: index * 45 }
                            NumberAnimation { to: 1; duration: 420; easing.type: Easing.OutCubic }
                            PauseAnimation { duration: 2600 }
                            NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutQuad }
                            PauseAnimation { duration: (49 - index) * 45 }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: textBlock.implicitHeight
                Column {
                    id: textBlock
                    width: parent.width
                    spacing: 12
                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: presentation.messages[presentation.shown][0]
                        color: "#ededf2"
                        font { family: "Geist"; pixelSize: 32; weight: Font.DemiBold }
                    }
                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: presentation.messages[presentation.shown][1]
                        color: "#a3a3b3"
                        lineHeight: 1.25
                        font { family: "Geist"; pixelSize: 17 }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Repeater {
                    model: presentation.messages.length
                    Rectangle {
                        required property int index
                        width: index === presentation.shown ? 22 : 7; height: 7; radius: 3.5
                        color: index === presentation.shown ? "#a99aff" : "#343442"
                        Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
                    }
                }
            }
        }
    }
}
