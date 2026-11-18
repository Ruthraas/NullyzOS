import QtQuick
import qs.theme
import qs.components

// Linha de configuração em cartão: título e descrição à esquerda, controle à direita.
//   SettingsRow { title: "Mostrar dock"; description: "…"; Toggle { … } }
Item {
    id: row
    property string title
    property string description
    default property alias control: slot.data
    readonly property int pad: 16

    width: parent ? parent.width : 0
    implicitHeight: Math.max(slot.height, texts.implicitHeight) + pad * 2

    Rectangle {
        anchors.fill: parent
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
    }
    Column {
        id: texts
        x: row.pad
        anchors.verticalCenter: parent.verticalCenter
        width: row.width - row.pad * 3 - slot.width
        spacing: 3
        Txt { width: parent.width; text: row.title; font.weight: Font.Medium; wrapMode: Text.Wrap; elide: Text.ElideNone }
        Txt {
            width: parent.width
            visible: text !== ""
            text: row.description
            muted: true
            size: 13
            wrapMode: Text.Wrap
            elide: Text.ElideNone
        }
    }
    Item {
        id: slot
        x: row.width - row.pad - width
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
