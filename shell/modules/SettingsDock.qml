import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Dock: prévia ao vivo e todas as opções do dock. Fixar, tirar e mudar a
// ordem dos apps é pelo botão direito no próprio dock.
SettingsPage {
    id: page
    title: "Dock"
    subtitle: "Os apps na borda da tela. Botão direito num ícone: fixar, tirar, mudar de lugar."


    // ---- prévia: uma "tela" com o dock na posição, estilo e tamanho escolhidos -----------
    Rectangle {
        id: screen
        width: parent.width; height: 170
        radius: Tok.rField
        color: Tok.surfaceHi
        border { width: 1; color: Tok.border }
        clip: true
        opacity: Prefs.dock ? 1 : 0.45
        Behavior on opacity { NumberAnimation { duration: Tok.panel } }
        Image {
            anchors { fill: parent; margins: 1 }
            source: Prefs.wallpaperUrl
            sourceSize: Qt.size(640, 360)
            fillMode: Image.PreserveAspectCrop
            opacity: 0.85
        }
        // barra de menus
        Rectangle { x: 1; y: 1; width: parent.width - 2; height: 10; color: Tok.glass }

        readonly property bool vertical: Prefs.dockPosition !== "baixo"
        readonly property real k: 0.42                       // escala da miniatura
        readonly property real ic: Prefs.dockIcon * k
        readonly property int n: Math.max(2, Apps.pinned.length + (Prefs.dockShowOpen ? 1 : 0))
        Rectangle {
            id: mini
            readonly property real len: screen.n * screen.ic + (screen.n - 1) * 4 + 10
            readonly property real th: screen.ic + 10
            width: screen.vertical ? th : len
            height: screen.vertical ? len : th
            radius: Math.min(11, th / 2)
            color: Prefs.dockStyle === "solido" ? Tok.surface : Prefs.dockStyle === "transparente" ? "transparent" : Tok.glass
            border { width: Prefs.dockStyle === "transparente" ? 0 : 1; color: Tok.edge }
            x: Prefs.dockPosition === "esquerda" ? 6 : Prefs.dockPosition === "direita" ? screen.width - width - 6 : (screen.width - width) / 2
            y: screen.vertical ? 10 + (screen.height - 10 - height) / 2 : screen.height - height - 6
            Behavior on x { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
            Behavior on y { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
            Behavior on width { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutCubic } }
            Grid {
                anchors.centerIn: parent
                columns: screen.vertical ? 1 : screen.n
                spacing: 4
                Repeater {
                    model: screen.n
                    Rectangle {
                        required property int index
                        width: screen.ic; height: screen.ic; radius: screen.ic * 0.28
                        color: index === 0 ? Tok.accent : Tok.surfaceHi
                        border { width: 1; color: Tok.edge }
                        // indicador
                        Rectangle {
                            visible: Prefs.dockIndicator !== "nenhum" && index < 2
                            readonly property bool line: Prefs.dockIndicator === "traco"
                            width: screen.vertical ? 2 : (line ? 7 : 3); height: screen.vertical ? (line ? 7 : 3) : 2
                            radius: 1
                            color: Tok.text
                            x: Prefs.dockPosition === "esquerda" ? -4 : Prefs.dockPosition === "direita" ? parent.width + 2 : (parent.width - width) / 2
                            y: screen.vertical ? (parent.height - height) / 2 : parent.height + 2
                        }
                    }
                }
            }
        }
        Txt {
            visible: !Prefs.dock
            anchors.centerIn: parent
            text: "Dock desligado"
            font.weight: Font.DemiBold
        }
    }

    SettingsRow {
        title: "Mostrar dock"
        description: "Desligado, as janelas usam a tela inteira e os apps abrem pela busca (Super + Espaço)."
        Toggle { checked: Prefs.dock; onToggled: v => Prefs.set("dock", v) }
    }

    Column {
        width: parent.width
        spacing: 14
        enabled: Prefs.dock
        opacity: Prefs.dock ? 1 : 0.45
        Behavior on opacity { NumberAnimation { duration: Tok.panel } }

        SettingsRow {
            title: "Posição"
            description: "Em que borda da tela."
            Segmented {
                options: [["esquerda", "Esquerda"], ["baixo", "Embaixo"], ["direita", "Direita"]]
                current: Prefs.dockPosition
                onPicked: v => Prefs.set("dockPosition", v)
            }
        }
        SettingsRow {
            title: "Tamanho dos ícones"
            description: Prefs.dockIcon + " px"
            Segmented {
                options: [[38, "Pequeno"], [46, "Normal"], [56, "Grande"], [64, "Enorme"]]
                current: Prefs.dockIcon
                onPicked: v => Prefs.set("dockIcon", v)
            }
        }
        SettingsRow {
            title: "Ampliar ao passar o mouse"
            description: "O ícone embaixo do mouse cresce e os vizinhos acompanham, em onda."
            Segmented {
                options: [[0, "Não"], [0.35, "Pouco"], [0.7, "Muito"]]
                current: Prefs.dockMagnify
                onPicked: v => Prefs.set("dockMagnify", v)
            }
        }
        SettingsRow {
            title: "Ocultar automaticamente"
            description: "Some quando não está em uso; encoste o mouse na borda para ele voltar."
            Toggle { checked: Prefs.dockAutohide; onToggled: v => Prefs.set("dockAutohide", v) }
        }
        SettingsRow {
            title: "Estilo"
            description: "O fundo da cápsula do dock."
            Segmented {
                options: [["vidro", "Vidro"], ["solido", "Sólido"], ["transparente", "Sem fundo"]]
                current: Prefs.dockStyle
                onPicked: v => Prefs.set("dockStyle", v)
            }
        }
        SettingsRow {
            title: "Indicador de app aberto"
            description: "A marca perto do ícone dos apps com janela aberta."
            Segmented {
                options: [["ponto", "Ponto"], ["traco", "Traço"], ["nenhum", "Nenhum"]]
                current: Prefs.dockIndicator
                onPicked: v => Prefs.set("dockIndicator", v)
            }
        }
        SettingsRow {
            title: "Mostrar apps abertos"
            description: "Além dos fixados, os apps com janela aberta aparecem no fim do dock."
            Toggle { checked: Prefs.dockShowOpen; onToggled: v => Prefs.set("dockShowOpen", v) }
        }
    }
}
