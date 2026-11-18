import QtQuick
import qs.theme

// Texto padrão do shell: a fonte da interface, cor de texto, corte com reticências.
// `size` é o tamanho de referência; o que aparece escala com Configurações → Fontes.
Text {
    property bool muted: false
    property real size: 14
    color: muted ? Tok.muted : Tok.text
    font.family: Tok.font
    font.pixelSize: Math.round(size * Tok.fontScale)
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
