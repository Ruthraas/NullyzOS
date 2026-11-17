import QtQuick
import qs.theme

// O símbolo do NullyzOS: N de 7×7 pixels (docs/IDENTIDADE.md).
Grid {
    id: root
    property real cell: 3
    property color color: Tok.accent
    columns: 7
    spacing: Math.max(0.5, cell * 0.25)
    Repeater {
        model: "##...#####..######.####.######..#####...####...##".split("")
        Rectangle {
            width: root.cell; height: root.cell
            radius: root.cell * 0.18
            color: modelData === "#" ? root.color : "transparent"
        }
    }
}
