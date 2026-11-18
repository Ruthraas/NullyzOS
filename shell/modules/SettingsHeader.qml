import QtQuick
import qs.components

// Título e subtítulo de uma página das Configurações.
Column {
    property string title
    property string subtitle
    width: parent ? parent.width : 0
    spacing: 4
    bottomPadding: 6
    Txt { text: parent.title; size: 24; font { weight: Font.DemiBold; letterSpacing: -0.3 } }
    Txt { width: parent.width; text: parent.subtitle; muted: true; visible: text !== ""; wrapMode: Text.Wrap; elide: Text.ElideNone }
}
