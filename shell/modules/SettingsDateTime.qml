import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Data e hora: fuso horário (com busca) e acertar o relógio pela internet
// (timedatectl; trocar pede a senha pelo polkit). Formato 24 h/12 h fica em Barra.
SettingsPage {
    id: page
    title: "Data e hora"
    subtitle: "Fuso horário e relógio certo pela internet."

    property string zone: ""
    property bool ntp: true
    property var zones: []
    property string query: ""
    readonly property var shown: {
        const q = page.query.trim().toLowerCase().replace(/ /g, "_");
        return (q ? page.zones.filter(z => z.toLowerCase().includes(q)) : []).slice(0, 12);
    }

    function zoneLabel(z) { return z.replace(/_/g, " ").replace("/", " · "); }
    function run(args) {
        Panels.settingsAside = true;          // pedido de senha por cima
        job.command = ["timedatectl"].concat(args);
        job.running = true;
    }

    Process {
        id: status
        running: true
        command: ["timedatectl", "show", "-p", "Timezone", "-p", "NTP"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const l of text.split("\n")) {
                    if (l.startsWith("Timezone=")) page.zone = l.slice(9);
                    if (l.startsWith("NTP=")) page.ntp = l.slice(4) === "yes";
                }
            }
        }
    }
    Process {
        running: true
        command: ["timedatectl", "list-timezones"]
        stdout: StdioCollector { onStreamFinished: page.zones = text.split("\n").filter(z => z) }
    }
    Process {
        id: job
        onExited: { Panels.settingsAside = false; status.running = true; }
    }

    Rectangle {
        width: parent.width; height: 96
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            x: 20; anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            Txt { text: Clock.timeSec; size: 34; font { weight: Font.Light; features: { "tnum": 1 } } }
            Txt { text: Clock.dateLong + (page.zone ? " · " + page.zoneLabel(page.zone) : ""); muted: true; size: 13 }
        }
    }

    SettingsRow {
        title: "Acertar pela internet"
        description: page.ntp ? "O relógio se acerta sozinho." : "Desligado: o relógio fica como está."
        Toggle { checked: page.ntp; onToggled: v => { page.ntp = v; page.run(["set-ntp", v ? "true" : "false"]); } }
    }

    Txt { text: "Fuso horário"; font.weight: Font.DemiBold }
    Rectangle {
        width: parent.width; height: 40
        radius: Tok.rButton + 2
        color: Tok.surfaceHi
        border { width: 1; color: zInput.activeFocus ? Tok.accent : Tok.border }
        TextInput {
            id: zInput
            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Tok.text
            font { family: Tok.font; pixelSize: Math.round(14 * Tok.fontScale) }
            onTextChanged: page.query = text
        }
        Txt { x: 12; anchors.verticalCenter: parent.verticalCenter; visible: zInput.text === ""; text: "Procurar cidade: Sao Paulo, Lisboa, Manaus…"; muted: true }
    }
    Rectangle {
        visible: page.shown.length > 0
        width: parent.width; height: zCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: zCol
            width: parent.width
            Repeater {
                model: page.shown
                Rectangle {
                    required property string modelData
                    width: zCol.width; height: 38
                    radius: Tok.rField
                    color: zArea.containsMouse ? Tok.hover : "transparent"
                    Txt { x: 16; anchors.verticalCenter: parent.verticalCenter; text: page.zoneLabel(parent.modelData); font.weight: parent.modelData === page.zone ? Font.DemiBold : Font.Normal }
                    Ico { visible: parent.modelData === page.zone; anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter } size: 16; d: Icons.check; color: Tok.accent }
                    MouseArea { id: zArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: page.run(["set-timezone", parent.modelData]) }
                }
            }
        }
    }
}
