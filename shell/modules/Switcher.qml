import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Alt+Tab: as janelas abertas em fila, com ícone e título. Cada Alt+Tab passa para a
// próxima (o atalho chama IPC switcher); soltar o Alt foca a escolhida. Esc cancela.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-switcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    readonly property var windows: Hypr.toplevels.filter(t => t.appId || t.title)
    property int current: windows.length > 1 ? 1 : 0

    function next() { if (windows.length) current = (current + 1) % windows.length; }
    function pick() {
        const t = windows[current];
        Panels.closeAll();
        if (t) t.activate();
    }
    Connections { target: Panels; function onSwitcherNext() { root.next(); } }

    Glass {
        id: card
        anchors.centerIn: parent
        width: Math.min(row.implicitWidth + 40, parent.width - 40)
        height: 168
        radius: Tok.rPanel
        focus: true
        Keys.onReleased: event => { if (event.key === Qt.Key_Alt || event.key === Qt.Key_Meta) root.pick(); }
        Keys.onTabPressed: root.next()
        Keys.onEscapePressed: Panels.closeAll()
        Keys.onReturnPressed: root.pick()
        Keys.onRightPressed: root.next()
        Keys.onLeftPressed: root.current = (root.current - 1 + root.windows.length) % Math.max(1, root.windows.length)
        opacity: 0
        scale: 0.95
        Component.onCompleted: { opacity = 1; scale = 1; forceActiveFocus(); }
        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
        Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }

        Txt {
            visible: root.windows.length === 0
            anchors.centerIn: parent
            text: "Nenhuma janela aberta"
            muted: true
        }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 10
            Repeater {
                model: root.windows
                Rectangle {
                    id: w
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === root.current
                    readonly property var entry: Apps.byId(modelData.appId || "")
                    width: 120; height: 128
                    radius: Tok.rField
                    color: sel ? Tok.selection : (wArea.containsMouse ? Tok.hover : "transparent")
                    border { width: sel ? 2 : 0; color: Tok.accent }
                    Behavior on color { ColorAnimation { duration: Tok.fast } }
                    AppIcon {
                        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 16 }
                        size: 56
                        entry: w.entry
                        fallbackName: w.modelData.appId || w.modelData.title
                        scale: w.sel ? 1.08 : 1
                        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                    }
                    Txt {
                        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 12 }
                        width: parent.width - 16
                        horizontalAlignment: Text.AlignHCenter
                        text: w.modelData.title || (w.entry ? w.entry.name : w.modelData.appId)
                        size: 12
                        muted: !w.sel
                    }
                    MouseArea { id: wArea; anchors.fill: parent; hoverEnabled: true; onClicked: { root.current = w.index; root.pick(); } }
                }
            }
        }
    }
}
