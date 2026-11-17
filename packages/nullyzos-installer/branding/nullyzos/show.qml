// Slideshow durante a instalação (NullyzOS): três mensagens curtas com o N pixelado.
import QtQuick
import calamares.slideshow 1.0

Presentation {
    id: presentation

    // Fundo da área inteira (sem isto o Calamares deixa uma moldura branca em volta dos slides).
    Rectangle { anchors.fill: parent; color: "#0e0e13"; z: -1 }

    function nextSlide() { presentation.goToNextSlide(); }

    Timer {
        interval: 7000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.nextSlide()
    }

    component NSlide: Slide {
        property string title
        property string body
        Rectangle { anchors.fill: parent; color: "#0e0e13" }
        Column {
            anchors.centerIn: parent
            spacing: 22
            width: parent.width * 0.7
            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                spacing: 3
                Repeater {
                    model: "##...#####..######.####.######..#####...####...##".split("")
                    Rectangle { width: 12; height: 12; radius: 2; color: modelData === "#" ? "#9d8cff" : "transparent" }
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: title
                color: "#ededf2"
                font { family: "Geist"; pixelSize: 28; weight: Font.DemiBold }
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: body
                color: "#a3a3b3"
                font { family: "Geist"; pixelSize: 16 }
            }
        }
    }

    NSlide { title: "Instalando o NullyzOS"; body: "Copiando o sistema e baixando o desktop que você escolheu. Pode levar alguns minutos." }
    NSlide { title: "Do seu jeito"; body: "Depois de instalado, a loja de rices deixa trocar todo o visual, com uma foto do sistema antes de cada troca." }
    NSlide { title: "Seguro por padrão"; body: "Sem AUR e sem scripts de terceiros: tudo vem dos repositórios oficiais do Arch ou do repositório NullyzOS, assinado." }
}
