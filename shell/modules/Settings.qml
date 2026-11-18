import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services

// Configurações no Hyprland (Super + vírgula, ou "Configurações" na busca): janela de camada
// do tamanho da tela com o cartão no meio (tamanho fixo para o desenho por software); Esc ou
// clique fora fecha. O conteúdo é o SettingsView.
PanelWindow {
    id: win
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-settings"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    visible: !Panels.settingsAside

    SettingsView { anchors.fill: parent }
}
