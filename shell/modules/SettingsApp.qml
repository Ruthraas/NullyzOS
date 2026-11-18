import QtQuick
import Quickshell
import qs.theme
import qs.services

// Configurações como app (janela comum): no KDE, pelo nullyzos-configuracoes. Fechar a janela
// encerra.
FloatingWindow {
    id: win
    title: "Configurações do NullyzOS"
    implicitWidth: 1000
    implicitHeight: 700
    color: Tok.bg
    onClosed: Qt.quit()

    SettingsView { anchors.fill: parent; windowed: true }
}
