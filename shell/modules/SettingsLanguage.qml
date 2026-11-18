import QtQuick
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Idioma: a língua do sistema e dos apps (localectl; pede a senha). Vale a
// partir do próximo login. O teclado fica em Teclado e mouse.
SettingsPage {
    id: page
    title: "Idioma"
    subtitle: "A língua do sistema e dos apps. Vale a partir do próximo login."

    readonly property var names: ({
        "pt_BR.UTF-8": "Português (Brasil)", "pt_PT.UTF-8": "Português (Portugal)",
        "en_US.UTF-8": "English (United States)", "en_GB.UTF-8": "English (United Kingdom)",
        "es_ES.UTF-8": "Español (España)", "es_MX.UTF-8": "Español (México)",
        "fr_FR.UTF-8": "Français", "de_DE.UTF-8": "Deutsch", "it_IT.UTF-8": "Italiano",
        "ja_JP.UTF-8": "日本語", "zh_CN.UTF-8": "中文 (简体)"
    })
    property string current: ""
    property var available: []
    property bool changed: false

    Process {
        id: status
        running: true
        command: ["sh", "-c", "localectl status | awk -F= '/LANG=/ { print $2; exit }'; localectl list-locales"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n").map(x => x.trim()).filter(x => x);
                page.current = l[0] || "";
                page.available = l.slice(1).filter(x => page.names[x]);
            }
        }
    }
    Process { id: job; onExited: code => { Panels.settingsAside = false; if (code === 0) page.changed = true; status.running = true; } }

    Rectangle {
        width: parent.width; height: langCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: langCol
            width: parent.width
            Repeater {
                model: Object.keys(page.names)
                Rectangle {
                    id: lr
                    required property string modelData
                    required property int index
                    readonly property bool ok: page.available.includes(modelData)
                    readonly property bool chosen: page.current === modelData
                    width: langCol.width; height: 42
                    radius: Tok.rField
                    color: lArea.containsMouse && ok ? Tok.hover : "transparent"
                    opacity: ok ? 1 : 0.45
                    Txt { x: 16; anchors.verticalCenter: parent.verticalCenter; text: page.names[lr.modelData]; font.weight: lr.chosen ? Font.DemiBold : Font.Normal }
                    Txt { visible: !lr.ok; anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter } text: "não instalado"; muted: true; size: 12 }
                    Ico { visible: lr.chosen; anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter } size: 16; d: Icons.check; color: Tok.accent }
                    MouseArea {
                        id: lArea
                        anchors.fill: parent
                        enabled: lr.ok && !lr.chosen
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Panels.settingsAside = true; job.command = ["localectl", "set-locale", "LANG=" + lr.modelData]; job.running = true; }
                    }
                }
            }
        }
    }
    Txt {
        visible: page.changed
        width: parent.width
        text: "Pronto. Saia da sessão e entre de novo para ver o sistema na língua nova."
        color: Tok.accent; size: 13
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
}
