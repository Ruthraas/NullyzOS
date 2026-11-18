import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Seletor de busca em dois modos:
//  - "clip"  (Super + Shift + V): histórico da área de transferência (cliphist); Enter copia
//    de volta e cola no app em que você estava.
//  - "emoji" (Super + ponto): emojis (nome em inglês, do Unicode); Enter digita no app.
// Setas escolhem, Esc fecha.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    readonly property string mode: Panels.picker          // clip | emoji
    readonly property bool emoji: mode === "emoji"
    property var items: []                                // clip: [{ line, text }]; emoji: [{ ch, name }]
    property int current: 0
    readonly property var shown: {
        const q = field.text.trim().toLowerCase();
        const l = q ? root.items.filter(i => (root.emoji ? i.name : i.text.toLowerCase()).includes(q)) : root.items;
        return l.slice(0, root.emoji ? 80 : 30);
    }
    onShownChanged: current = 0
    readonly property int cols: 10

    function choose(i) {
        if (!i) return;
        Panels.closeAll();
        if (root.emoji)
            Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy; sleep 0.2; wtype \"$1\"", "sh", i.ch]);
        else
            Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy; sleep 0.2; wtype -M ctrl v -m ctrl", "sh", i.line]);
    }
    function move(d) { root.current = Math.max(0, Math.min(root.shown.length - 1, root.current + d)); }

    Process {
        running: !root.emoji
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.items = text.split("\n").filter(l => l).slice(0, 200).map(l => {
                const t = l.slice(l.indexOf("\t") + 1);
                return { line: l, text: /^\[\[ binary data/.test(t) ? "Imagem " + t.replace(/^\[\[ binary data |\]\]$/g, "") : t };
            })
        }
    }
    FileView {
        path: root.emoji ? Qt.resolvedUrl("../data/emoji.txt").toString().replace("file://", "") : ""
        onLoaded: root.items = text().split("\n").filter(l => l).map(l => {
            const f = l.split("\t");
            return { ch: f[0], name: f[1] || "" };
        })
    }

    Rectangle { anchors.fill: parent; color: Tok.scrim; MouseArea { anchors.fill: parent; onClicked: Panels.closeAll() } }

    Glass {
        id: card
        width: Math.min(root.emoji ? 560 : 640, root.width - 48)
        height: Math.min(header.height + body.implicitHeight + 24, root.height - 120)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(56, root.height * 0.14)
        clip: true
        opacity: 0
        scale: 0.96
        Component.onCompleted: { opacity = 1; scale = 1; field.forceActiveFocus(); }
        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
        Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
        MouseArea { anchors.fill: parent }

        Item {
            id: header
            width: parent.width; height: 60
            Txt { x: 22; anchors.verticalCenter: parent.verticalCenter; text: root.emoji ? "😀" : "⧉"; size: 20; muted: !root.emoji }
            TextInput {
                id: field
                anchors { left: parent.left; leftMargin: 56; right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
                color: Tok.text
                font { family: Tok.font; pixelSize: Math.round(18 * Tok.fontScale) }
                clip: true
                Keys.onEscapePressed: Panels.closeAll()
                Keys.onReturnPressed: root.choose(root.shown[root.current])
                Keys.onEnterPressed: root.choose(root.shown[root.current])
                Keys.onDownPressed: root.move(root.emoji ? root.cols : 1)
                Keys.onUpPressed: root.move(root.emoji ? -root.cols : -1)
                Keys.onRightPressed: event => { if (root.emoji) root.move(1); else event.accepted = false; }
                Keys.onLeftPressed: event => { if (root.emoji) root.move(-1); else event.accepted = false; }
            }
            Txt {
                anchors { left: field.left; verticalCenter: parent.verticalCenter }
                visible: field.text === ""
                text: root.emoji ? "Procurar emoji (em inglês: heart, fire, smile…)" : "Procurar no que você copiou"
                muted: true; size: 18
            }
            Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Tok.border }
        }

        Item {
            id: body
            y: header.height + 12
            x: 12
            width: parent.width - 24
            implicitHeight: root.emoji ? emojiGrid.implicitHeight : (root.shown.length ? clipList.implicitHeight : 40)

            Txt {
                visible: root.shown.length === 0
                x: 10
                text: root.emoji ? "Nenhum emoji com esse nome." : "Nada copiado ainda."
                muted: true; size: 13
            }
            Grid {
                id: emojiGrid
                visible: root.emoji
                columns: root.cols
                spacing: 4
                Repeater {
                    model: root.emoji ? root.shown : []
                    Rectangle {
                        required property var modelData
                        required property int index
                        width: (body.width - (root.cols - 1) * 4) / root.cols; height: width
                        radius: Tok.rButton
                        color: index === root.current ? Tok.selection : (eArea.containsMouse ? Tok.hover : "transparent")
                        Text { anchors.centerIn: parent; text: parent.modelData.ch; font.pixelSize: parent.width * 0.55 }
                        MouseArea { id: eArea; anchors.fill: parent; hoverEnabled: true; onEntered: root.current = parent.index; onClicked: root.choose(parent.modelData) }
                    }
                }
            }
            Column {
                id: clipList
                visible: !root.emoji
                width: parent.width
                Repeater {
                    model: root.emoji ? [] : root.shown
                    Rectangle {
                        required property var modelData
                        required property int index
                        width: clipList.width; height: 40
                        radius: Tok.rButton + 2
                        color: index === root.current ? Tok.selection : (cArea.containsMouse ? Tok.hover : "transparent")
                        Txt { x: 12; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 24; text: parent.modelData.text.replace(/\s+/g, " ") }
                        MouseArea { id: cArea; anchors.fill: parent; hoverEnabled: true; onEntered: root.current = parent.index; onClicked: root.choose(parent.modelData) }
                    }
                }
            }
        }
    }
}
