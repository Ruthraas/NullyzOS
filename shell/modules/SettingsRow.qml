import QtQuick
import qs.theme
import qs.components

// Linha de configuração em cartão: título e descrição à esquerda, controle à direita.
// Responsiva: se o controle não deixa pelo menos 220 px para o texto, ele desce para
// baixo do título (tela estreita, texto grande, controles largos).
//   SettingsRow { title: "Mostrar dock"; description: "…"; Toggle { … } }
Item {
    id: row
    property string title
    property string description
    default property alias control: slot.data
    readonly property int pad: 16
    readonly property bool stacked: slot.width > row.width - pad * 3 - 220

    width: parent ? parent.width : 0
    implicitHeight: stacked ? texts.implicitHeight + 12 + slot.height + pad * 2
                            : Math.max(slot.height, texts.implicitHeight) + pad * 2

    Rectangle {
        anchors.fill: parent
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
    }
    Column {
        id: texts
        x: row.pad
        y: row.stacked ? row.pad : (row.height - implicitHeight) / 2
        width: row.stacked ? row.width - row.pad * 2 : row.width - row.pad * 3 - slot.width
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
        x: row.stacked ? row.pad : row.width - row.pad - width
        y: row.stacked ? row.pad + texts.implicitHeight + 12 : (row.height - height) / 2
        width: childrenRect.width
        height: childrenRect.height
    }
}
