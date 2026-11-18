import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Impressoras: as impressoras do CUPS e qual é a padrão. Adicionar e mexer
// na fila abre o configurador do sistema (system-config-printer).
SettingsPage {
    id: page
    title: "Impressoras"
    subtitle: "Impressoras e scanners ligados no computador ou na rede."

    property var printers: []           // [{ name, state }]
    property string standard: ""
    property bool cupsOff: false

    Process {
        running: true
        command: ["sh", "-c", "lpstat -p -d 2>&1 || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = [];
                page.cupsOff = /not running|não está|scheduler/i.test(text) && text.indexOf("printer ") < 0;
                for (const l of text.split("\n")) {
                    let m = /^(?:printer|impressora) (\S+) (.*)$/.exec(l);
                    if (m) p.push({ name: m[1], state: /idle|ociosa/i.test(m[2]) ? "Pronta" : /disabled|desativ/i.test(m[2]) ? "Desligada" : "Imprimindo" });
                    m = /(?:system default destination|destino padrão do sistema): (\S+)/.exec(l);
                    if (m) page.standard = m[1];
                }
                page.printers = p;
            }
        }
    }

    Txt {
        visible: page.printers.length === 0
        width: parent.width
        text: page.cupsOff ? "O serviço de impressão está desligado." : "Nenhuma impressora ainda. Ligue a impressora (USB ou na mesma rede) e clique em Adicionar."
        muted: true; size: 13
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
    Rectangle {
        visible: page.printers.length > 0
        width: parent.width; height: prCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: prCol
            width: parent.width
            Repeater {
                model: page.printers
                Item {
                    required property var modelData
                    required property int index
                    width: prCol.width; height: 52
                    Column {
                        x: 16; anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Txt { text: parent.parent.modelData.name.replace(/_/g, " "); font.weight: Font.DemiBold }
                        Txt { text: parent.parent.modelData.state + (parent.parent.modelData.name === page.standard ? " · padrão" : ""); muted: true; size: 12 }
                    }
                    Chip {
                        visible: parent.modelData.name !== page.standard
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        text: "Usar como padrão"
                        onClicked: { Quickshell.execDetached(["lpoptions", "-d", parent.modelData.name]); page.standard = parent.modelData.name; }
                    }
                    Rectangle {
                        visible: parent.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                }
            }
        }
    }
    Row {
        spacing: 8
        Chip { text: "Adicionar impressora"; active: true; onClicked: Quickshell.execDetached(["system-config-printer"]) }
        Chip { text: "Abrir o configurador"; onClicked: Quickshell.execDetached(["system-config-printer"]) }
    }
}
