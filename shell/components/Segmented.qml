import QtQuick
import qs.theme

// Controle segmentado: as opções lado a lado num bloco só, a escolhida com um fundo que
// desliza até ela (follow-through com leve overshoot).
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
    // Fundo da opção escolhida
    Rectangle {
        visible: root.index >= 0
        readonly property Item target: root.index >= 0 ? rep.itemAt(root.index) : null
        x: target ? row.x + target.x : 3
        y: 3
        width: target ? target.width : 0
        height: parent.height - 6
        radius: Math.min(height / 2, Tok.rField - 3)
        color: Tok.accent
        Behavior on x { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        Behavior on width { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutCubic } }
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
                Rectangle {
                    anchors.fill: parent
                    radius: Math.min(height / 2, Tok.rField - 3)
                    color: area.containsMouse && !parent.sel ? Tok.hover : "transparent"
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
