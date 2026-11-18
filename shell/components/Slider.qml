import QtQuick
import qs.theme

// Controle deslizante 0..1 (volume, brilho). Arrastar ou rolar a roda muda o valor; a bolinha
// cresce ao segurar (antecipação) e volta com overshoot ao soltar.
Item {
    id: root
    property real value: 0
    signal moved(real value)

    implicitWidth: 200
    implicitHeight: 24
    opacity: enabled ? 1 : 0.4

    property real local: 0
    readonly property real shown: area.pressed ? local : Math.max(0, Math.min(1, value))

    function pick(x) {
        local = Math.max(0, Math.min(1, x / width));
        root.moved(local);
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 6; radius: 3
        color: Tok.surfaceHi
        Rectangle {
            width: Math.max(height, root.shown * parent.width)
            height: parent.height; radius: parent.radius
            color: Tok.accent
        }
    }
    Rectangle {
        id: knob
        width: 18; height: 18; radius: 9
        anchors.verticalCenter: parent.verticalCenter
        x: root.shown * (root.width - width)
        color: Tok.text
        border { width: 1; color: Tok.edge }
        scale: area.pressed ? 1.25 : (area.containsMouse ? 1.1 : 1)
        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
    }

    MouseArea {
        id: area
        anchors { fill: parent; topMargin: -6; bottomMargin: -6 }
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.pick(mouse.x)
        onPositionChanged: mouse => { if (pressed) root.pick(mouse.x); }
    }
    WheelHandler {
        enabled: root.enabled
        onWheel: event => root.moved(Math.max(0, Math.min(1, root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
