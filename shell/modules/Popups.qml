import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Notificações no canto superior direito, abaixo da barra. Entram deslizando da borda com
// overshoot; clique dispensa. Janela de tamanho fixo e transparente (só os cartões recebem
// clique): no desenho por software, janela que nasce pequena e cresce não é redesenhada.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; right: true }
    margins { top: 8; right: 10 }
    implicitWidth: 380
    implicitHeight: 560
    exclusionMode: ExclusionMode.Normal
    color: "transparent"
    mask: Region { item: column }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-notifications"
    // Com o painel rápido aberto a notificação já aparece no histórico dele
    visible: !Panels.quick

    Column {
        id: column
        width: parent.width
        spacing: 8
        move: Transition { NumberAnimation { properties: "y"; duration: Tok.panel; easing.type: Easing.OutCubic } }

        Repeater {
            model: Notifs.popups
            Glass {
                id: card
                required property var modelData
                readonly property var n: modelData.notification
                width: column.width
                height: content.implicitHeight + 28
                radius: Tok.rCard
                x: column.width + 20
                Component.onCompleted: x = 0
                Behavior on x { NumberAnimation { duration: Tok.slow; easing.type: Easing.OutBack } }

                Row {
                    id: content
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                    spacing: 12
                    Image {
                        width: 36; height: 36
                        sourceSize: Qt.size(72, 72)
                        source: card.n.image || (card.n.appIcon ? Quickshell.iconPath(card.n.appIcon, "dialog-information") : "")
                        visible: source != ""
                    }
                    Column {
                        width: parent.width - 48
                        spacing: 2
                        Txt { width: parent.width; text: card.n.appName || "Notificação"; muted: true; size: 12}
                        Txt { width: parent.width; text: card.n.summary; font.weight: Font.DemiBold; size: 15}
                        Txt {
                            width: parent.width
                            visible: text !== ""
                            text: card.n.body || ""
                            muted: true
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            size: 13
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: card.modelData.hovered = containsMouse
                    onClicked: card.n.dismiss()
                }
            }
        }
    }
}
