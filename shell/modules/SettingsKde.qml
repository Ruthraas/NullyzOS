import QtQuick
import Quickshell
import qs.theme
import qs.services
import qs.components

// Configurações → Sistema do KDE: no Plasma, aparência, monitores, teclado, rede, som e o
// resto ficam nas Configurações do Sistema do próprio KDE (completas, e o visual Nullyz já
// vem aplicado). Aqui, atalhos direto para cada módulo.
SettingsPage {
    id: page
    title: "Sistema do KDE"
    subtitle: "O resto do sistema fica nas Configurações do Sistema do KDE."

    readonly property var modules: [
        ["kcm_lookandfeel", "Tema global", "Visual NullyzOS, cores, ícones e cursor", Icons.palette],
        ["kcm_colors", "Cores", "Nullyz Escuro, Nullyz Claro e outros esquemas", Icons.palette],
        ["kcm_kscreen", "Monitores", "Resolução, escala e posição das telas", Icons.monitor],
        ["kcm_keyboard", "Teclado", "Layout (ABNT2), atalhos e repetição", Icons.keyboard],
        ["kcm_networkmanagement", "Rede", "Wi‑Fi, cabo e VPN", Icons.wifi],
        ["kcm_pulseaudio", "Som", "Saída, microfone e volume por app", Icons.volumeHigh],
        ["kcm_bluetooth", "Bluetooth", "Fones, mouses e outros aparelhos", Icons.bluetooth],
        ["kcm_powerdevilprofilesconfig", "Energia", "Suspender, tela e bateria", Icons.bolt],
        ["kcm_regionandlang", "Idioma e região", "Língua, formatos de data e números", Icons.globe],
        ["kcm_clock", "Data e hora", "Fuso horário e relógio", Icons.clock]
    ]

    Repeater {
        model: page.modules
        Rectangle {
            id: row
            required property var modelData
            width: parent.width; height: 56
            radius: Tok.rField
            color: area.containsMouse ? Tok.hover : Tok.surface
            border { width: 1; color: Tok.border }
            Behavior on color { ColorAnimation { duration: Tok.fast } }
            Rectangle {
                x: 14; anchors.verticalCenter: parent.verticalCenter
                width: 30; height: 30; radius: Tok.rButton
                color: Tok.accent
                Ico { anchors.centerIn: parent; size: 16; d: row.modelData[3]; color: Tok.textOnAccent }
            }
            Column {
                x: 58; anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 100
                Txt { text: row.modelData[1]; font.weight: Font.Medium }
                Txt { width: parent.width; text: row.modelData[2]; muted: true; size: 12 }
            }
            Ico { anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter } size: 16; d: Icons.chevronRight; color: Tok.muted }
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["systemsettings", row.modelData[0]])
                Accessible.name: "Abrir " + row.modelData[1]
            }
        }
    }
    Chip {
        text: "Abrir as Configurações do Sistema"
        active: true
        onClicked: Quickshell.execDetached(["systemsettings"])
    }
}
