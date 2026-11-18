import QtQuick
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Bluetooth: ligar, procurar, parear e conectar fones, mouses e teclados
// (bluetoothctl, via scripts/bluetooth.sh). Relê a cada 3 s com a página aberta.
SettingsPage {
    id: page
    title: "Bluetooth"
    subtitle: "Fones, caixas de som, mouses e teclados sem fio."

    property string power: "?"          // yes | no | none
    property var devices: []            // [{ mac, paired, connected, name }]
    property bool scanning: false
    property string busy: ""

    readonly property string script: Qt.resolvedUrl("../scripts/bluetooth.sh").toString().replace("file://", "")
    function refresh() { if (!query.running) query.running = true; }
    function act(args, mac) {
        busy = mac || args[0];
        job.command = ["sh", page.script, "acao"].concat(args);
        job.running = true;
    }

    Process {
        id: query
        command: ["sh", page.script]
        stdout: StdioCollector {
            onStreamFinished: {
                const d = [];
                for (const l of text.split("\n")) {
                    const f = l.split(" ");
                    if (f[0] === "power") page.power = f[1];
                    else if (f[0] === "dev") d.push({ mac: f[1], paired: f[2] === "1", connected: f[3] === "1", name: f.slice(4).join(" ") || f[1] });
                }
                d.sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name));
                page.devices = d;
            }
        }
    }
    Process {
        id: job
        onExited: { page.busy = ""; page.scanning = false; page.refresh(); }
    }
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: page.refresh() }

    Txt {
        visible: page.power === "none"
        width: parent.width
        text: "Nenhum adaptador Bluetooth encontrado (ou o serviço está desligado)."
        muted: true; size: 13
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }

    SettingsRow {
        visible: page.power === "yes" || page.power === "no"
        title: "Bluetooth"
        description: page.power === "yes" ? "Ligado" : "Desligado"
        Toggle { checked: page.power === "yes"; onToggled: v => { page.power = v ? "yes" : "no"; page.act([v ? "power-on" : "power-off"]); } }
    }

    Item {
        visible: page.power === "yes"
        width: parent.width; height: 32
        Txt { anchors.verticalCenter: parent.verticalCenter; text: "Aparelhos"; font.weight: Font.DemiBold }
        Chip {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            text: page.scanning ? "Procurando…" : "Procurar aparelhos"
            onClicked: { page.scanning = true; page.act(["scan"]); }
        }
    }
    Txt {
        visible: page.power === "yes" && page.devices.length === 0
        width: parent.width
        text: "Nenhum aparelho ainda. Deixe o aparelho em modo de pareamento e clique em Procurar."
        muted: true; size: 13
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
    Rectangle {
        visible: page.power === "yes" && page.devices.length > 0
        width: parent.width; height: devCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: devCol
            width: parent.width
            Repeater {
                model: page.devices
                Item {
                    id: dv
                    required property var modelData
                    required property int index
                    width: devCol.width; height: 52
                    Column {
                        x: 16; anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 220
                        spacing: 2
                        Txt { width: parent.width; text: dv.modelData.name; font.weight: dv.modelData.connected ? Font.DemiBold : Font.Normal }
                        Txt {
                            width: parent.width; size: 12
                            text: dv.modelData.connected ? "Conectado" : dv.modelData.paired ? "Pareado" : "Disponível"
                            color: dv.modelData.connected ? Tok.accent : Tok.muted
                        }
                    }
                    Row {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        spacing: 6
                        Chip {
                            text: page.busy === dv.modelData.mac ? "…" : dv.modelData.connected ? "Desconectar" : "Conectar"
                            active: !dv.modelData.connected
                            onClicked: page.act([dv.modelData.connected ? "disconnect" : "connect", dv.modelData.mac], dv.modelData.mac)
                        }
                        Chip {
                            visible: dv.modelData.paired
                            text: "Esquecer"
                            onClicked: page.act(["remove", dv.modelData.mac], dv.modelData.mac)
                        }
                    }
                    Rectangle {
                        visible: dv.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                }
            }
        }
    }
}
