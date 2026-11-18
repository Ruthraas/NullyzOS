import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Visão geral (Super + Tab): os workspaces lado a lado, cada um com as janelas dele (ícone e
// título). Clique num workspace vai para ele; clique numa janela foca ela. Esc fecha.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-overview"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    readonly property var spaces: {
        const ids = [];
        for (let i = 1; i <= Math.max(Prefs.workspaceCount, 1); i++) ids.push(i);
        for (const w of Hypr.workspaces) if (!ids.includes(w.id)) ids.push(w.id);
        return ids.sort((a, b) => a - b);
    }
    function windowsOn(id) {
        return Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === id);
    }

    Rectangle {
        anchors.fill: parent
        color: Tok.scrim
        MouseArea { anchors.fill: parent; onClicked: Panels.closeAll() }
    }

    Flow {
        id: grid
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 5 * 260 + 4 * 20)
        spacing: 20
        focus: true
        Keys.onEscapePressed: Panels.closeAll()
        Component.onCompleted: forceActiveFocus()

        Repeater {
            model: root.spaces
            Glass {
                id: ws
                required property int modelData
                required property int index
                readonly property bool active: modelData === Hypr.activeWs
                readonly property var wins: root.windowsOn(modelData)
                width: 240; height: 170
                radius: Tok.rCard
                border { width: active ? 2 : 1; color: active ? Tok.accent : Tok.edge }
                opacity: 0
                scale: 0.9
                Component.onCompleted: appear.start()
                SequentialAnimation {
                    id: appear
                    PauseAnimation { duration: ws.index * 30 }
                    ParallelAnimation {
                        NumberAnimation { target: ws; property: "opacity"; to: 1; duration: Tok.panel }
                        NumberAnimation { target: ws; property: "scale"; to: 1; duration: Tok.panel; easing.type: Easing.OutBack }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: { Hypr.focusWorkspace(ws.modelData); Panels.closeAll(); }
                }
                Txt { x: 14; y: 10; text: "Workspace " + ws.modelData; size: 12; muted: !ws.active; font.weight: Font.DemiBold }
                Txt {
                    visible: ws.wins.length === 0
                    anchors.centerIn: parent
                    text: "vazio"; muted: true; size: 12
                }
                Flow {
                    x: 12; y: 36
                    width: parent.width - 24
                    spacing: 8
                    Repeater {
                        model: ws.wins.slice(0, 6)
                        Rectangle {
                            id: win
                            required property var modelData
                            readonly property var entry: Apps.byId(modelData.wayland ? (modelData.wayland.appId || "") : "")
                            width: 100; height: 56
                            radius: Tok.rButton + 2
                            color: winArea.containsMouse ? Tok.hover : Tok.surfaceHi
                            AppIcon {
                                x: 8; anchors.verticalCenter: parent.verticalCenter
                                size: 30
                                entry: win.entry
                                fallbackName: win.modelData.title
                            }
                            Txt { x: 44; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 50; text: win.modelData.title; size: 11 }
                            MouseArea {
                                id: winArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: { if (win.modelData.wayland) win.modelData.wayland.activate(); Panels.closeAll(); }
                            }
                        }
                    }
                }
            }
        }
    }
}
