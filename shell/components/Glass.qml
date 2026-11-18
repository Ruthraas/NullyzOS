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

    // Brilho no topo: some aos poucos nas pontas (com ponta seca parecia um risco).
    Rectangle {
        visible: root.topLight
        x: root.radius * 0.6; y: 1
        width: Math.max(0, root.width - root.radius * 1.2); height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 0.5; color: Tok.highlight }
            GradientStop { position: 1; color: "transparent" }
        }
    }
}
