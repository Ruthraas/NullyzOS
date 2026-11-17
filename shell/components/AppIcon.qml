import QtQuick
import qs.theme
import qs.services

// Ícone de app: o do tema de ícones ou, se não houver, um quadrado com a inicial do nome
// (antes aparecia o xadrez magenta de "imagem não encontrada").
Item {
    id: root
    property var entry: null
    property string fallbackName: ""
    property real size: 46
    readonly property string src: Apps.icon(entry)
    implicitWidth: size
    implicitHeight: size

    Image {
        anchors.fill: parent
        visible: root.src !== ""
        source: root.src
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        smooth: true
    }
    Rectangle {
        anchors.fill: parent
        visible: root.src === ""
        radius: root.size * 0.28
        color: Tok.surfaceHi
        border { width: 1; color: Tok.edge }
        Txt {
            anchors.centerIn: parent
            text: ((root.entry ? root.entry.name : root.fallbackName) || "?").charAt(0).toUpperCase()
            font { pixelSize: root.size * 0.45; weight: Font.DemiBold }
            color: Tok.accent
        }
    }
}
