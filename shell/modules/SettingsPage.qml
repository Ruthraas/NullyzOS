import QtQuick
import qs.theme

// Página das Configurações: título fixo no topo e o conteúdo rolando embaixo dele.
// Rolou, aparece uma linha sob o título e a barrinha de rolagem à direita.
//   SettingsPage { title: "Aparência"; subtitle: "…"; Txt { … } SettingsRow { … } }
Item {
    id: page
    property string title
    property string subtitle
    property int spacing: 14
    default property alias content: col.data

    SettingsHeader {
        id: head
        visible: page.title !== ""
        height: visible ? implicitHeight : 0
        title: page.title
        subtitle: page.subtitle
    }

    Flickable {
        id: flick
        anchors { top: head.bottom; topMargin: head.visible ? 8 : 0; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentHeight: col.implicitHeight + 12
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: flick.width - 14          // folga para a barrinha de rolagem
            spacing: page.spacing
        }
    }

    // Linha sob o título: só quando o conteúdo já rolou para baixo dela
    Rectangle {
        anchors { top: flick.top; left: parent.left; right: parent.right }
        height: 1
        color: Tok.border
        opacity: flick.contentY > 2 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
    }

    // Barrinha de rolagem (só aparece quando há o que rolar)
    Rectangle {
        readonly property real ratio: flick.height / Math.max(1, flick.contentHeight)
        visible: ratio < 1
        anchors.right: parent.right
        width: 4; radius: 2
        y: flick.y + flick.visibleArea.yPosition * flick.height
        height: Math.max(24, ratio * flick.height)
        color: Tok.muted
        opacity: flick.moving ? 0.7 : 0.3
        Behavior on opacity { NumberAnimation { duration: Tok.panel } }
    }
}
