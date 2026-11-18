/* Navegação do instalador do NullyzOS: Cancelar à esquerda, Voltar e Próximo à direita
   (Próximo em pílula na cor de destaque). Rótulos e estados vêm do ViewManager do Calamares.
   Baseado no exemplo do Calamares (GPL-3.0-or-later). */
import io.calamares.ui 1.0
import io.calamares.core 1.0

import QtQuick

Rectangle {
    id: nav
    color: "#0e0e13"
    height: 76

    readonly property color accent: "#9d8cff"
    // Última tela (Concluir): o botão de sair vira "Concluído" (reinicia se marcado)
    readonly property bool last: ViewManager.currentStepIndex === ViewManager.rowCount() - 1

    Rectangle { anchors { left: parent.left; right: parent.right; top: parent.top } height: 1; color: "#2b2b37" }

    component NavButton: Rectangle {
        id: b
        property string label
        property bool primary: false
        property bool active: true
        signal clicked()
        height: 44
        width: Math.max(120, t.implicitWidth + 44)
        radius: 22
        opacity: active ? 1 : 0.4
        color: primary ? (area.containsMouse && active ? Qt.lighter(nav.accent, 1.08) : nav.accent)
                       : (area.containsMouse && active ? "#262632" : "#1f1f29")
        border { width: primary ? 0 : 1; color: "#2b2b37" }
        scale: area.pressed && active ? 0.96 : 1
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: 140 } }
        Text {
            id: t
            anchors.centerIn: parent
            text: b.label.replace("&", "")
            color: b.primary ? "#0e0e13" : "#ededf2"
            font { family: "Geist"; pixelSize: 15; weight: b.primary ? Font.DemiBold : Font.Medium }
        }
        MouseArea {
            id: area
            anchors.fill: parent
            enabled: b.active
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: b.clicked()
        }
    }

    // Cancelar: só texto, discreto
    Text {
        visible: ViewManager.quitVisible && !nav.last
        anchors { left: parent.left; leftMargin: 32; verticalCenter: parent.verticalCenter }
        text: ViewManager.quitLabel.replace("&", "")
        color: quitArea.containsMouse ? "#ededf2" : "#a3a3b3"
        font { family: "Geist"; pixelSize: 14 }
        MouseArea { id: quitArea; anchors.fill: parent; enabled: ViewManager.quitEnabled; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: ViewManager.quit() }
    }

    Row {
        anchors { right: parent.right; rightMargin: 32; verticalCenter: parent.verticalCenter }
        spacing: 12
        NavButton { visible: ViewManager.backAndNextVisible && !nav.last; label: ViewManager.backLabel; active: ViewManager.backEnabled; onClicked: ViewManager.back() }
        NavButton { visible: ViewManager.backAndNextVisible && !nav.last; label: ViewManager.nextLabel; primary: true; active: ViewManager.nextEnabled; onClicked: ViewManager.next() }
        NavButton { visible: nav.last && ViewManager.quitVisible; label: ViewManager.quitLabel; primary: true; active: ViewManager.quitEnabled; onClicked: ViewManager.quit() }
    }
}
