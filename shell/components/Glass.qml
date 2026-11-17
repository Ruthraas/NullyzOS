import QtQuick
import qs.theme

// Superfície de vidro (docs/IDENTIDADE.md): tinta + borda de luz + brilho no topo.
// O desfoque de verdade vem do Hyprland (regra de camada); no modo VM a tinta fica quase sólida.
Rectangle {
    id: root
    property bool topLight: true
    color: Tok.glass
    radius: Tok.rPanel
    border { width: 1; color: Tok.edge }

    Rectangle {
        visible: root.topLight
        x: root.radius; y: 1
        width: Math.max(0, root.width - root.radius * 2); height: 1
        color: Tok.highlight
    }
}
