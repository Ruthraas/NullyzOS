import QtQuick
import qs.theme

// Botão redondo só com ícone (painel rápido). `danger` pinta de vermelho (confirmar ação).
// Hover clareia, clique amassa um pouco (antecipação).
Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property bool danger: false
    signal clicked()

    width: 32; height: 32; radius: 16
    color: danger ? Tok.error : (area.containsMouse ? Tok.hover : Tok.surfaceHi)
    Behavior on color { ColorAnimation { duration: Tok.fast } }
    scale: area.pressed ? 0.9 : 1
    Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }

    Ico { anchors.centerIn: parent; size: 17; d: root.icon; color: root.danger ? Tok.textOnAccent : Tok.text }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        Accessible.name: root.label
    }
}
