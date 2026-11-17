import QtQuick
import qs.theme

// Texto padrão do shell: Geist, cor de texto, corte com reticências.
Text {
    property bool muted: false
    color: muted ? Tok.muted : Tok.text
    font.family: Tok.font
    font.pixelSize: 14
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
