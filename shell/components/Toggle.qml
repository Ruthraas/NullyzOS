import QtQuick
import qs.theme

// Interruptor liga/desliga. A bolinha estica no meio do caminho (squash & stretch) e passa
// um pouco do ponto antes de assentar (overshoot).
Item {
    id: root
    property bool checked: false
    signal toggled(bool value)

    implicitWidth: 44
    implicitHeight: 26
    Accessible.role: Accessible.CheckBox
    Accessible.checked: checked

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Tok.accent : Tok.surfaceHi
        border { width: root.checked ? 0 : 1; color: Tok.border }
        Behavior on color { ColorAnimation { duration: Tok.panel } }
    }

    Rectangle {
        id: knob
        y: 3
        height: parent.height - 6
        width: slide.running ? height * 1.35 : height
        x: root.checked ? parent.width - height - 3 : 3
        radius: height / 2
        color: root.checked ? Tok.textOnAccent : Tok.muted
        Behavior on x { NumberAnimation { id: slide; duration: Tok.panel; easing.type: Easing.OutBack; easing.overshoot: 1.4 } }
        Behavior on width { NumberAnimation { duration: Tok.fast } }
        Behavior on color { ColorAnimation { duration: Tok.panel } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
