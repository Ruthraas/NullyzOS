import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme

// Fundo da área de trabalho: as manchas de cor do Nullyz (mesma imagem da tela de login).
// A escolha de wallpaper chega com as Configurações (#14).
PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Tok.bg
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "nullyzos-wallpaper"

    Image {
        anchors.fill: parent
        source: "file:///usr/share/nullyzos/wallpapers/padrao.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
    }
}
