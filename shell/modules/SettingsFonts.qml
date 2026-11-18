import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Fontes: fonte e tamanho do texto da interface, fonte do terminal.
// Cada opção aparece desenhada na própria fonte. As conhecidas que faltam ganham "Instalar"
// (pacote oficial da lista em /usr/lib/nullyzos/limpeza, via pkexec).
SettingsPage {
    id: page
    title: "Fontes"
    subtitle: "As letras da interface e do terminal."

    // [família, pacote oficial que instala]
    readonly property var uiFonts: [
        ["Geist", ""], ["Inter", "inter-font"], ["Noto Sans", "noto-fonts"], ["Roboto", "ttf-roboto"],
        ["IBM Plex Sans", "ttf-ibm-plex"], ["Fira Sans", "ttf-fira-sans"], ["Ubuntu", "ttf-ubuntu-font-family"],
        ["Open Sans", "ttf-opensans"], ["Cantarell", "cantarell-fonts"], ["Geist Mono", ""]
    ]
    readonly property var monoFonts: [
        ["Geist Mono", ""], ["JetBrains Mono", "ttf-jetbrains-mono"], ["Fira Code", "ttf-fira-code"],
        ["Cascadia Code", "ttf-cascadia-code"], ["IBM Plex Mono", "ttf-ibm-plex"], ["Hack", "ttf-hack"],
        ["Source Code Pro", "adobe-source-code-pro-fonts"], ["DejaVu Sans Mono", "ttf-dejavu"]
    ]
    readonly property var installed: Qt.fontFamilies()
    property string busy: ""
    property string message: ""

    function has(family) { return page.installed.includes(family); }
    function install(pkg) {
        if (busy) return;
        busy = pkg;
        message = "";
        job.command = ["pkexec", "/usr/lib/nullyzos/limpeza", "fonte", pkg];
        job.running = true;
        Panels.settingsAside = true;
    }
    Process {
        id: job
        onExited: code => {
            Panels.settingsAside = false;
            page.message = code === 0 ? "instalada" : code === 126 ? "" : "Não deu para instalar (erro " + code + ").";
            page.busy = "";
        }
    }

    // Cartão de fonte: "Aa" e o nome, na própria fonte
    component FontCard: Rectangle {
        id: fc
        property string family
        property string pkg
        property bool chosen: false
        property string sample: "Aa"
        readonly property bool available: page.has(family)
        signal picked()
        width: 140; height: 92
        radius: Tok.rField
        color: area.containsMouse && available ? Tok.hover : Tok.surface
        border { width: chosen ? 2 : 1; color: chosen ? Tok.accent : Tok.border }
        scale: area.pressed && available ? 0.96 : 1
        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: Tok.fast } }
        Txt {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 12 }
            text: fc.sample
            size: fc.sample.length > 3 ? 15 : 28
            font.family: fc.available ? fc.family : Tok.font
            opacity: fc.available ? 1 : 0.35
        }
        Txt {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 10 }
            width: parent.width - 16
            horizontalAlignment: Text.AlignHCenter
            visible: fc.available || !fc.pkg
            text: fc.family
            size: 12
            muted: !fc.chosen
            font.family: fc.available ? fc.family : Tok.font
        }
        Chip {
            visible: !fc.available && fc.pkg !== ""
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 8 }
            height: 26
            text: page.busy === fc.pkg ? "Instalando…" : "Instalar " + fc.family
            onClicked: page.install(fc.pkg)
        }
        MouseArea {
            id: area
            anchors.fill: parent
            enabled: fc.available
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: fc.picked()
            z: -1
        }
    }

    // ---- interface ---------------------------------------------------------------------
    Txt { text: "Fonte da interface"; font.weight: Font.DemiBold }
    Flow {
        width: parent.width
        spacing: 10
        Repeater {
            model: page.uiFonts
            FontCard {
                required property var modelData
                family: modelData[0]
                pkg: modelData[1]
                chosen: Tok.font === modelData[0]
                onPicked: Prefs.set("uiFont", modelData[0])
            }
        }
    }

    SettingsRow {
        title: "Tamanho do texto"
        description: "Barra, painéis e Configurações. Os apps têm o próprio ajuste."
        Row {
            spacing: 8
            Repeater {
                model: [[0.9, "Pequeno"], [1, "Normal"], [1.1, "Grande"], [1.25, "Enorme"]]
                Chip {
                    required property var modelData
                    text: modelData[1]
                    active: Math.abs(Tok.fontScale - modelData[0]) < 0.01
                    onClicked: Prefs.set("textScale", modelData[0])
                }
            }
        }
    }

    Item { width: 1; height: 6 }

    // ---- terminal ----------------------------------------------------------------------
    Txt { text: "Fonte do terminal"; font.weight: Font.DemiBold }
    Flow {
        width: parent.width
        spacing: 10
        Repeater {
            model: page.monoFonts
            FontCard {
                required property var modelData
                family: modelData[0]
                pkg: modelData[1]
                sample: "~ › ls"
                chosen: Terminal.fontFamily === modelData[0]
                onPicked: Terminal.set("fontFamily", modelData[0])
            }
        }
    }

    Row {
        visible: page.message !== ""
        spacing: 10
        Txt {
            anchors.verticalCenter: parent.verticalCenter
            text: page.message === "instalada" ? "Fonte instalada. Ela aparece aqui depois de reiniciar o shell." : page.message
            color: page.message === "instalada" ? Tok.text : Tok.error
            size: 13
        }
        Chip {
            visible: page.message === "instalada"
            text: "Reiniciar o shell"
            onClicked: Quickshell.execDetached(["sh", "-c", "sleep 0.3; pkill -x qs; sleep 0.6; qs -n -c nullyzos -d"])
        }
    }
}
