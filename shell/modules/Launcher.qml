import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Busca (Super + Espaço): digite para filtrar apps; ↑↓ escolhem, Enter abre, Esc fecha.
// Só existe enquanto aberta (LazyLoader no shell.qml): fechada não gasta memória.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property int current: 0
    // Quantos resultados cabem entre a busca e o dock (52 px cada), no máximo 7.
    readonly property int fits: Math.max(3, Math.min(7, Math.floor((root.height * 0.82 - 64 - 140) / 54)))
    readonly property var results: Apps.search(field.text).slice(0, fits)
    onResultsChanged: current = 0

    function open(entry) {
        if (!entry) return;
        entry.execute();
        Panels.closeAll();
    }

    // Fundo escurecido: clicar fora fecha.
    Rectangle {
        anchors.fill: parent
        color: Tok.scrim
        opacity: card.opacity
        MouseArea { anchors.fill: parent; onClicked: Panels.closeAll() }
    }

    Glass {
        id: card
        width: Math.min(640, root.width - 48)
        height: header.height + list.height + (root.results.length ? 20 : 0)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(56, root.height * 0.14)
        clip: true
        // Entrada: cresce de 96% com leve overshoot e aparece; a saída é o próprio fechar.
        opacity: 0
        scale: 0.96
        Component.onCompleted: { opacity = 1; scale = 1; field.forceActiveFocus(); }
        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
        Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
        Behavior on height { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutCubic } }
        MouseArea { anchors.fill: parent }        // clique dentro não fecha

        Item {
            id: header
            width: parent.width
            height: 64
            Ico {
                anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter }
                size: 20
                color: Tok.muted
                d: "M11 4a7 7 0 1 0 0 14a7 7 0 1 0 0-14 M20 20l-4-4"
            }
            TextInput {
                id: field
                anchors { left: parent.left; leftMargin: 56; right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
                color: Tok.text
                font { family: Tok.font; pixelSize: Math.round(21 * Tok.fontScale); weight: Font.Medium }
                selectionColor: Tok.accent
                clip: true
                Keys.onEscapePressed: Panels.closeAll()
                Keys.onReturnPressed: root.open(root.results[root.current])
                Keys.onEnterPressed: root.open(root.results[root.current])
                Keys.onDownPressed: root.current = Math.min(root.results.length - 1, root.current + 1)
                Keys.onUpPressed: root.current = Math.max(0, root.current - 1)
                Accessible.name: "Buscar apps"
            }
            Txt {
                anchors { left: field.left; verticalCenter: parent.verticalCenter }
                visible: field.text.length === 0
                text: "Buscar apps"
                muted: true
                size: 21
            }
            Rectangle {
                visible: root.results.length > 0
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: Tok.edge
            }
        }

        ListView {
            id: list
            anchors { top: header.bottom; topMargin: 10; left: parent.left; right: parent.right; margins: 10 }
            height: contentHeight
            interactive: false
            spacing: 2
            model: root.results
            delegate: Rectangle {
                id: row
                required property var modelData
                required property int index
                readonly property bool sel: index === root.current
                width: list.width
                height: 52
                radius: Tok.rCard - 6
                color: sel ? Tok.selection : (rowArea.containsMouse ? Tok.hover : "transparent")
                Behavior on color { ColorAnimation { duration: Tok.fast } }
                AppIcon {
                    id: appIcon
                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    size: 32
                    entry: row.modelData
                }
                Column {
                    anchors { left: appIcon.right; leftMargin: 14; right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                    spacing: 1
                    Txt { width: parent.width; text: row.modelData.name; font.weight: Font.Medium; size: 15}
                    Txt {
                        width: parent.width
                        visible: text !== ""
                        text: row.modelData.genericName || row.modelData.comment || ""
                        muted: true
                        size: 12
                    }
                }
                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    // Só segue o mouse quando ele se mexe (não quando a lista aparece embaixo dele).
                    onPositionChanged: root.current = row.index
                    onClicked: root.open(row.modelData)
                }
            }
        }
    }
}
