import QtQuick
import qs.theme

// Controle segmentado: as opções lado a lado num bloco só; a escolhida ganha o fundo na
// cor de destaque, que entra crescendo com leve overshoot.
//   Segmented { options: [["a", "Uma"], ["b", "Outra"]]; current: x; onPicked: v => … }
Item {
    id: root
    property var options: []            // [[valor, rótulo], …]
    property var current
    signal picked(var value)

    readonly property int index: {
        for (let i = 0; i < options.length; i++) {
            const v = options[i][0];
            if (v === current || (typeof v === "number" && Math.abs(v - Number(current)) < 0.001)) return i;
        }
        return -1;
    }
    implicitWidth: row.implicitWidth + 6
    implicitHeight: 34

    Rectangle {
        anchors.fill: parent
        radius: Math.min(height / 2, Tok.rField)
        color: Tok.surfaceHi
        border { width: 1; color: Tok.border }
    }
    Row {
        id: row
        x: 3; y: 3
        height: parent.height - 6
        Repeater {
            id: rep
            model: root.options
            Item {
                required property var modelData
                required property int index
                readonly property bool sel: index === root.index
                width: label.implicitWidth + 24
                height: row.height
                // Fundo da escolhida: entra crescendo com leve overshoot
                Rectangle {
                    anchors.fill: parent
                    radius: Math.min(height / 2, Tok.rField - 3)
                    color: parent.sel ? Tok.accent : (area.containsMouse ? Tok.hover : "transparent")
                    scale: parent.sel ? 1 : 0.92
                    Behavior on color { ColorAnimation { duration: Tok.fast } }
                    Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
                }
                Txt {
                    id: label
                    anchors.centerIn: parent
                    text: parent.modelData[1]
                    size: 13
                    color: parent.sel ? Tok.textOnAccent : Tok.text
                    font.weight: parent.sel ? Font.DemiBold : Font.Normal
                    Behavior on color { ColorAnimation { duration: Tok.fast } }
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.picked(parent.modelData[0])
                    Accessible.name: parent.modelData[1]
                }
            }
        }
    }
}
