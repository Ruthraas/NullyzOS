import QtQuick
import qs.theme
import qs.services
import qs.components

// Miniatura de imagem que dá para escolher (fundo da área de trabalho e do bloqueio).
// Hover cresce um pouco, clique amassa (antecipação), escolhida ganha borda e um visto.
Item {
    id: root
    property string path: ""
    property string label: ""
    property bool selected: false
    signal picked()

    width: 156
    height: label !== "" ? 124 : 98

    Item {
        id: frame
        width: parent.width; height: 98
        scale: area.pressed ? 0.95 : (area.containsMouse ? 1.04 : 1)
        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }

        Rectangle {
            anchors.fill: parent
            radius: Tok.rButton + 2
            color: Tok.surfaceHi
        }
        Image {
            anchors { fill: parent; margins: 3 }
            source: root.path ? Prefs.url(root.path) : ""
            sourceSize: Qt.size(312, 196)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            opacity: status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Tok.panel } }
        }
        Rectangle {
            anchors.fill: parent
            radius: Tok.rButton + 2
            color: "transparent"
            border { width: root.selected ? 2 : 1; color: root.selected ? Tok.accent : Tok.edge }
            Behavior on border.color { ColorAnimation { duration: Tok.fast } }
        }
        // Visto: entra crescendo com overshoot
        Rectangle {
            anchors { right: parent.right; top: parent.top; margins: 8 }
            width: 22; height: 22; radius: 11
            color: Tok.accent
            scale: root.selected ? 1 : 0
            Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
            Ico { anchors.centerIn: parent; size: 14; stroke: 2.4; color: Tok.textOnAccent; d: Icons.check }
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.picked()
            Accessible.name: root.label || root.path.split("/").pop()
        }
    }
    Txt {
        visible: root.label !== ""
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: root.label
        size: 13
        color: root.selected ? Tok.text : Tok.muted
    }
}
