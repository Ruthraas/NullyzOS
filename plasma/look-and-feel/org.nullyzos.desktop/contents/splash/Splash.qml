// Tela de abertura do Plasma no NullyzOS: o N pixelado acendendo, como no boot.
import QtQuick

Rectangle {
    id: root
    color: "#0e0e13"
    property int stage

    Grid {
        anchors.centerIn: parent
        columns: 7
        spacing: 4
        Repeater {
            model: "##...#####..######.####.######..#####...####...##".split("")
            Rectangle {
                required property string modelData
                required property int index
                width: 14; height: 14; radius: 3
                color: modelData === "#" ? "#9d8cff" : "transparent"
                opacity: modelData === "#" ? (index / 49 < root.stage / 6 ? 1 : 0.25) : 0
                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }
        }
    }
}
