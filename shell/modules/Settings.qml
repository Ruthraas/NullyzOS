import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Configurações (Super + vírgula, ou "Configurações" na busca). Janela de camada do
// tamanho da tela com o cartão no meio: tamanho fixo para o desenho por software, Esc ou
// clique fora fecha. Cada mudança é gravada em Prefs e aplica na hora.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-settings"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    visible: !Panels.settingsAside

    // Páginas por tópico; a ordem aqui é a da lateral.
    readonly property var pages: [
        { id: "aparencia", label: "Aparência", icon: Icons.palette, file: "SettingsAppearance.qml", group: "Personalização" },
        { id: "bloqueio", label: "Tela de bloqueio", icon: Icons.lock, file: "SettingsLock.qml", group: "Personalização" },
        { id: "barra", label: "Barra e dock", icon: Icons.bar, file: "SettingsBar.qml", group: "Personalização" },
        { id: "janelas", label: "Janelas", icon: Icons.windows, file: "SettingsWindows.qml", group: "Personalização" },
        { id: "rede", label: "Rede", icon: Icons.wifi, file: "SettingsNetwork.qml", group: "Sistema" },
        { id: "som", label: "Som", icon: Icons.volumeHigh, file: "SettingsSound.qml", group: "Sistema" },
        { id: "teclado", label: "Teclado e mouse", icon: Icons.keyboard, file: "SettingsKeyboard.qml", group: "Sistema" },
        { id: "monitores", label: "Monitores", icon: Icons.monitor, file: "SettingsDisplays.qml", group: "Sistema" },
        { id: "energia", label: "Energia", icon: Icons.bolt, file: "SettingsPower.qml", group: "Sistema" },
        { id: "atalhos", label: "Atalhos", icon: Icons.command, file: "SettingsShortcuts.qml", group: "Geral" },
        { id: "sobre", label: "Sobre", icon: Icons.info, file: "SettingsAbout.qml", group: "Geral" }
    ]
    readonly property int pageIndex: Math.max(0, pages.findIndex(p => p.id === Panels.settingsPage))

    // Fundo escurecido: clicar fora fecha.
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        opacity: card.opacity
        MouseArea { anchors.fill: parent; onClicked: Panels.closeAll() }
    }

    Rectangle {
        id: card
        width: Math.min(900, root.width - 48)
        height: Math.min(660, root.height - 72)
        anchors.centerIn: parent
        radius: Tok.rPanel
        color: Tok.bg
        border { width: 1; color: Tok.edge }
        clip: true
        focus: true
        Keys.onEscapePressed: Panels.closeAll()

        // Entrada: cresce de 96% com leve overshoot.
        opacity: 0
        scale: 0.96
        Component.onCompleted: { opacity = 1; scale = 1; forceActiveFocus(); }
        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
        Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
        MouseArea { anchors.fill: parent; onClicked: card.forceActiveFocus() }

        // ---- lateral ----------------------------------------------------------------
        Rectangle {
            id: side
            width: 232
            height: parent.height
            color: Tok.surface
            radius: Tok.rPanel
            // Canto direito reto (só o cartão é arredondado)
            Rectangle { anchors.right: parent.right; width: parent.radius; height: parent.height; color: parent.color }
            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Tok.border }

            Row {
                id: brand
                x: 20; y: 22
                spacing: 12
                PixelN { anchors.verticalCenter: parent.verticalCenter; cell: 3.4 }
                Txt { anchors.verticalCenter: parent.verticalCenter; text: "Configurações"; font { pixelSize: 16; weight: Font.DemiBold } }
            }

            Column {
                anchors { top: brand.bottom; topMargin: 20; left: parent.left; right: parent.right; leftMargin: 12; rightMargin: 12 }
                spacing: 2
                Repeater {
                    model: root.pages
                    Column {
                        id: nav
                        required property var modelData
                        required property int index
                        readonly property bool current: index === root.pageIndex
                        readonly property bool firstOfGroup: index === 0 || root.pages[index - 1].group !== modelData.group
                        width: parent.width
                        spacing: 2
                        // Título do tópico
                        Txt {
                            visible: nav.firstOfGroup
                            x: 12
                            topPadding: nav.index === 0 ? 0 : 12
                            bottomPadding: 4
                            text: nav.modelData.group.toUpperCase()
                            muted: true
                            font { pixelSize: 11; weight: Font.DemiBold; letterSpacing: 1.1 }
                        }
                        Rectangle {
                            width: parent.width; height: 36
                            radius: Tok.rButton + 2
                            color: nav.current ? Tok.selection : (navArea.containsMouse ? Tok.hover : "transparent")
                            Behavior on color { ColorAnimation { duration: Tok.fast } }
                            Row {
                                x: 12
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12
                                Ico { anchors.verticalCenter: parent.verticalCenter; size: 18; d: nav.modelData.icon; color: nav.current ? Tok.accent : Tok.muted }
                                Txt {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: nav.modelData.label
                                    color: nav.current ? Tok.text : Tok.muted
                                    font.weight: nav.current ? Font.DemiBold : Font.Normal
                                }
                            }
                            MouseArea {
                                id: navArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Panels.settingsPage = nav.modelData.id
                                Accessible.name: nav.modelData.label
                            }
                        }
                    }
                }
            }
        }

        // ---- conteúdo ---------------------------------------------------------------
        Loader {
            id: content
            anchors { left: side.right; right: parent.right; top: parent.top; bottom: parent.bottom; margins: 32 }
            source: root.pages[root.pageIndex].file
            // Troca de página: o conteúdo novo entra subindo um pouco (follow-through).
            onLoaded: { item.opacity = 0; slideIn.restart(); }
            ParallelAnimation {
                id: slideIn
                NumberAnimation { target: content.item; property: "opacity"; from: 0; to: 1; duration: Tok.panel; easing.type: Easing.OutCubic }
                NumberAnimation { target: content.item; property: "y"; from: 10; to: 0; duration: Tok.panel; easing.type: Easing.OutCubic }
            }
        }

        // Fechar
        Rectangle {
            anchors { right: parent.right; top: parent.top; margins: 16 }
            width: 32; height: 32; radius: 16
            color: closeArea.containsMouse ? Tok.hover : "transparent"
            Behavior on color { ColorAnimation { duration: Tok.fast } }
            Ico { anchors.centerIn: parent; size: 16; d: "M6 6l12 12 M18 6L6 18"; color: Tok.muted }
            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Panels.closeAll()
                Accessible.name: "Fechar"
            }
        }
    }
}
