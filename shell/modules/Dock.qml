import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Dock de vidro: apps fixados + apps abertos. Ponto embaixo = app aberto.
// Clique: foca a janela (ou abre o app). A janela ocupa a borda inteira com altura fixa
// (transparente; só o dock recebe clique), para o desenho por software não falhar.
PanelWindow {
    id: dock
    required property var modelData
    screen: modelData
    anchors { bottom: true; left: true; right: true }
    implicitHeight: 140                       // dock + folga para o nome do app no hover
    exclusiveZone: 82
    color: "transparent"
    mask: Region { item: pill }
    WlrLayershell.namespace: "nullyzos-dock"

    readonly property int iconSize: 46

    // Fixados primeiro, depois abertos que não estão fixados. Lê Apps.all para refazer a
    // lista quando os .desktop terminam de carregar (antes, no login, o dock ficava sem o
    // Dolphin e com o kitty como "K" para sempre).
    readonly property var items: {
        void Apps.all.length;
        const list = [];
        for (const id of Apps.pinned) {
            const e = Apps.byId(id);
            if (e) list.push({ id: e.id, entry: e });
        }
        for (const t of Hypr.toplevels) {
            const appId = t.appId || "";
            if (!appId || list.some(x => x.id.toLowerCase() === appId.toLowerCase())) continue;
            list.push({ id: appId, entry: Apps.byId(appId) });
        }
        return list;
    }

    Glass {
        id: pill
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 12 }
        width: row.implicitWidth + 24
        height: dock.iconSize + 24
        radius: 26
        Behavior on width { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutCubic } }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8
            Repeater {
                model: dock.items
                Item {
                    id: slot
                    required property var modelData
                    readonly property int open: Hypr.windowsOf(modelData.id)
                    width: dock.iconSize; height: dock.iconSize

                    AppIcon {
                        id: icon
                        x: 0
                        size: dock.iconSize
                        entry: slot.modelData.entry
                        fallbackName: slot.modelData.id
                        // Hover: sobe e cresce um pouco; clique: amassa (antecipação) e volta.
                        y: area.containsMouse ? -6 : 0
                        scale: area.pressed ? 0.88 : (area.containsMouse ? 1.1 : 1)
                        Behavior on y { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                    }
                    Rectangle {
                        anchors { horizontalCenter: parent.horizontalCenter; top: parent.bottom; topMargin: 4 }
                        width: slot.open > 0 ? 5 : 0; height: 5; radius: 2.5
                        color: Tok.text
                        opacity: slot.open > 0 ? 0.9 : 0
                        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
                    }
                    // Nome do app acima do ícone
                    Rectangle {
                        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.top; bottomMargin: 14 }
                        width: label.implicitWidth + 20; height: 28; radius: 10
                        color: Tok.surface
                        border { width: 1; color: Tok.edge }
                        opacity: area.containsMouse ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
                        Txt { id: label; anchors.centerIn: parent; size: 13
                              text: slot.modelData.entry ? slot.modelData.entry.name : slot.modelData.id }
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Hypr.activate(slot.modelData.id, slot.modelData.entry)
                        Accessible.name: slot.modelData.entry ? slot.modelData.entry.name : slot.modelData.id
                    }
                }
            }
        }
    }
}
