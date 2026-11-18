import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Configurações (Super + vírgula, ou "Configurações" na busca). Janela de camada do tamanho
// da tela com o cartão no meio (tamanho fixo para o desenho por software); Esc ou clique fora
// fecha. Lateral: busca (é só começar a digitar), cartão do usuário e os tópicos com ícone
// em quadradinho colorido. Conteúdo com largura máxima. Cada mudança aplica na hora.
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

    // Páginas por tópico (a ordem é a da lateral); `k` = palavras para a busca.
    readonly property var pages: [
        { id: "aparencia", label: "Aparência", icon: Icons.palette, file: "SettingsAppearance.qml", group: "Personalização", k: "tema claro escuro cor destaque wallpaper fundo vidro cursor cantos animações" },
        { id: "bloqueio", label: "Tela de bloqueio", icon: Icons.lock, file: "SettingsLock.qml", group: "Personalização", k: "login senha fundo" },
        { id: "barra", label: "Barra", icon: Icons.bar, file: "SettingsBar.qml", group: "Personalização", k: "relógio hora data workspaces menu" },
        { id: "dock", label: "Dock", icon: Icons.dock, file: "SettingsDock.qml", group: "Personalização", k: "apps fixados ampliar ocultar" },
        { id: "janelas", label: "Janelas", icon: Icons.windows, file: "SettingsWindows.qml", group: "Personalização", k: "espaço cantos animações desfoque" },
        { id: "fontes", label: "Fontes", icon: Icons.type, file: "SettingsFonts.qml", group: "Personalização", k: "letra texto tamanho instalar" },
        { id: "terminal", label: "Terminal", icon: Icons.terminal, file: "SettingsTerminal.qml", group: "Personalização", k: "kitty prompt fastfetch logo" },
        { id: "rede", label: "Rede", icon: Icons.wifi, file: "SettingsNetwork.qml", group: "Sistema", k: "wifi internet cabo" },
        { id: "bluetooth", label: "Bluetooth", icon: Icons.bluetooth, file: "SettingsBluetooth.qml", group: "Sistema", k: "fone mouse parear" },
        { id: "som", label: "Som", icon: Icons.volumeHigh, file: "SettingsSound.qml", group: "Sistema", k: "volume microfone saída" },
        { id: "monitores", label: "Monitores", icon: Icons.monitor, file: "SettingsDisplays.qml", group: "Sistema", k: "tela resolução escala hz" },
        { id: "teclado", label: "Teclado e mouse", icon: Icons.keyboard, file: "SettingsKeyboard.qml", group: "Sistema", k: "layout abnt2 ponteiro touchpad" },
        { id: "impressoras", label: "Impressoras", icon: Icons.printer, file: "SettingsPrinters.qml", group: "Sistema", k: "imprimir scanner" },
        { id: "notificacoes", label: "Notificações", icon: Icons.bell, file: "SettingsNotifications.qml", group: "Sistema", k: "não perturbe avisos" },
        { id: "energia", label: "Energia", icon: Icons.bolt, file: "SettingsPower.qml", group: "Sistema", k: "bloquear suspender bateria" },
        { id: "desempenho", label: "Desempenho", icon: Icons.gauge, file: "SettingsPerformance.qml", group: "Sistema", k: "memória processador limpeza leve perfil" },
        { id: "armazenamento", label: "Armazenamento", icon: Icons.disk, file: "SettingsStorage.qml", group: "Sistema", k: "disco espaço pastas" },
        { id: "data", label: "Data e hora", icon: Icons.clock, file: "SettingsDateTime.qml", group: "Sistema", k: "fuso horário relógio" },
        { id: "idioma", label: "Idioma", icon: Icons.globe, file: "SettingsLanguage.qml", group: "Sistema", k: "língua português inglês" },
        { id: "usuario", label: "Usuário", icon: Icons.user, file: "SettingsUsers.qml", group: "Geral", k: "foto nome senha conta" },
        { id: "apps", label: "Apps", icon: Icons.apps, file: "SettingsApps.qml", group: "Geral", k: "flathub loja instalar navegador brave padrão" },
        { id: "iniciar", label: "Apps ao iniciar", icon: Icons.rocket, file: "SettingsStartup.qml", group: "Geral", k: "abrir sozinho login" },
        { id: "atualizacoes", label: "Atualizações", icon: Icons.download, file: "SettingsUpdates.qml", group: "Geral", k: "atualizar snapshot pacman" },
        { id: "atalhos", label: "Atalhos", icon: Icons.command, file: "SettingsShortcuts.qml", group: "Geral", k: "teclas super" },
        { id: "sobre", label: "Sobre", icon: Icons.info, file: "SettingsAbout.qml", group: "Geral", k: "versão computador boas-vindas" }
    ]
    readonly property int pageIndex: Math.max(0, pages.findIndex(p => p.id === Panels.settingsPage))
    // Cor do quadradinho de cada tópico
    function groupColor(g) {
        return g === "Personalização" ? Tok.accent : g === "Sistema" ? (Tok.light ? Tok.accents.azul.light : Tok.accents.azul.color) : Tok.muted;
    }
    property string query: ""
    readonly property var found: {
        const q = root.query.trim().toLowerCase();
        if (!q) return [];
        return root.pages.filter(p => (p.label + " " + p.k + " " + p.group).toLowerCase().includes(q));
    }
    function open(id) { Panels.settingsPage = id; search.text = ""; card.forceActiveFocus(); }

    // Nome completo e foto do usuário (cartão no topo da lateral)
    property string fullName: ""
    property int faceStamp: 0
    Process {
        running: true
        command: ["sh", "-c", "getent passwd \"$USER\" | cut -d: -f5 | cut -d, -f1"]
        stdout: StdioCollector { onStreamFinished: root.fullName = text.trim() }
    }

    // Fundo escurecido: clicar fora fecha.
    Rectangle {
        anchors.fill: parent
        color: Tok.scrim
        opacity: card.opacity
        MouseArea { anchors.fill: parent; onClicked: Panels.closeAll() }
    }

    Rectangle {
        id: card
        // Responsivo: até 980×720; em tela pequena encolhe e a lateral vira só ícones.
        width: Math.min(980, root.width - (root.width < Tok.narrow ? 16 : 64))
        height: Math.min(720, root.height - Prefs.barHeight - (root.height < 700 ? 16 : 64))
        readonly property bool rail: width < 760
        x: (root.width - width) / 2
        y: Math.max(Prefs.barHeight + 8, (root.height - height) / 2)
        radius: Tok.rPanel
        color: Tok.bg
        border { width: 1; color: Tok.edge }
        clip: true
        focus: true
        Keys.onEscapePressed: { if (search.text) search.text = ""; else Panels.closeAll(); }
        // Digitar com as Configurações abertas já procura
        Keys.onPressed: event => {
            if (!card.rail && event.text && event.text.trim() && !(event.modifiers & Qt.ControlModifier)) {
                search.forceActiveFocus();
                search.text += event.text;
                event.accepted = true;
            }
        }

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
            width: card.rail ? 68 : 252
            Behavior on width { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutCubic } }
            height: parent.height
            color: Tok.surface
            radius: Tok.rPanel
            // Canto direito reto (só o cartão é arredondado)
            Rectangle { anchors.right: parent.right; width: parent.radius; height: parent.height; color: parent.color }
            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Tok.border }

            // Busca
            Rectangle {
                id: searchBox
                visible: !card.rail
                x: 14; y: 16
                width: parent.width - 28; height: 36
                radius: Tok.rButton + 2
                color: Tok.surfaceHi
                border { width: 1; color: search.activeFocus ? Tok.accent : "transparent" }
                Ico { x: 10; anchors.verticalCenter: parent.verticalCenter; size: 15; d: Icons.search; color: Tok.muted }
                TextInput {
                    id: search
                    anchors { fill: parent; leftMargin: 32; rightMargin: 10 }
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    color: Tok.text
                    font { family: Tok.font; pixelSize: Math.round(13 * Tok.fontScale) }
                    onTextChanged: root.query = text
                    Keys.onReturnPressed: if (root.found.length) root.open(root.found[0].id)
                    Keys.onEscapePressed: { text = ""; card.forceActiveFocus(); }
                }
                Txt { x: 32; anchors.verticalCenter: parent.verticalCenter; visible: search.text === ""; text: "Procurar"; muted: true; size: 13 }
            }

            // Cartão do usuário (abre a página Usuário)
            Rectangle {
                id: userCard
                x: card.rail ? 10 : 10
                y: card.rail ? 16 : searchBox.y + searchBox.height + 10
                width: parent.width - 20; height: card.rail ? 48 : 56
                radius: Tok.rField
                color: userArea.containsMouse || Panels.settingsPage === "usuario" ? Tok.hover : "transparent"
                Behavior on color { ColorAnimation { duration: Tok.fast } }
                Rectangle {
                    id: av
                    x: card.rail ? (parent.width - width) / 2 : 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40; height: 40; radius: 20
                    color: Tok.accent
                    clip: true
                    Txt { anchors.centerIn: parent; visible: face.status !== Image.Ready; text: (root.fullName || Quickshell.env("USER") || "?").charAt(0).toUpperCase(); size: 17; color: Tok.textOnAccent; font.weight: Font.DemiBold }
                    Image {
                        id: face
                        anchors.fill: parent
                        source: "file://" + Quickshell.env("HOME") + "/.face"
                        sourceSize: Qt.size(80, 80)
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                        visible: status === Image.Ready
                    }
                }
                Column {
                    visible: !card.rail
                    x: 56; anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 62
                    spacing: 1
                    Txt { width: parent.width; text: root.fullName || Quickshell.env("USER") || ""; font.weight: Font.DemiBold; size: 14 }
                    Txt { width: parent.width; text: "Conta e senha"; muted: true; size: 12 }
                }
                MouseArea { id: userArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.open("usuario") }
            }

            // Tópicos (ou os resultados da busca). Rola quando não cabem.
            Flickable {
                id: navFlick
                anchors { top: userCard.bottom; topMargin: 10; bottom: parent.bottom; bottomMargin: 12; left: parent.left; right: parent.right; leftMargin: card.rail ? 8 : 10; rightMargin: card.rail ? 8 : 10 }
                contentHeight: navCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: navCol
                    width: navFlick.width
                    spacing: 1
                    Txt {
                        visible: root.query !== "" && root.found.length === 0
                        x: 12; topPadding: 6
                        text: "Nada com \"" + root.query + "\""
                        muted: true; size: 13
                    }
                    Repeater {
                        model: root.query !== "" ? root.found : root.pages
                        Column {
                            id: nav
                            required property var modelData
                            required property int index
                            readonly property bool current: modelData.id === root.pages[root.pageIndex].id
                            readonly property var list: root.query !== "" ? root.found : root.pages
                            readonly property bool firstOfGroup: root.query === "" && (index === 0 || list[index - 1].group !== modelData.group)
                            width: parent.width
                            spacing: 1
                            // No desenho por software os ícones ignoram o recorte: o que sai da
                            // parte visível da lista some (antes vazava para fora do cartão).
                            opacity: y + height - navFlick.contentY <= navFlick.height + 1 && y - navFlick.contentY >= -height ? 1 : 0
                            Rectangle {
                                visible: nav.firstOfGroup && card.rail && nav.index > 0
                                width: parent.width; height: 13
                                color: "transparent"
                                Rectangle { anchors.centerIn: parent; width: parent.width - 16; height: 1; color: Tok.border }
                            }
                            Txt {
                                visible: nav.firstOfGroup && !card.rail
                                x: 10
                                topPadding: nav.index === 0 ? 4 : 14
                                bottomPadding: 4
                                text: nav.modelData.group
                                muted: true
                                size: 12; font.weight: Font.DemiBold
                            }
                            Rectangle {
                                id: navBtn
                                width: parent.width; height: card.rail ? 44 : 36
                                radius: Tok.rButton + 2
                                color: nav.current ? Tok.selection : (navArea.containsMouse ? Tok.hover : "transparent")
                                Behavior on color { ColorAnimation { duration: Tok.fast } }
                                // Ícone num quadradinho colorido (cor do tópico)
                                Rectangle {
                                    id: tile
                                    x: card.rail ? (navBtn.width - width) / 2 : 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 26; height: 26; radius: Math.max(5, Tok.rButton - 1)
                                    color: root.groupColor(nav.modelData.group)
                                    Ico { anchors.centerIn: parent; size: 16; stroke: 2; d: nav.modelData.icon; color: Tok.textOnAccent }
                                }
                                Txt {
                                    visible: !card.rail
                                    x: 44; anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 52
                                    text: nav.modelData.label
                                    font.weight: nav.current ? Font.DemiBold : Font.Normal
                                    size: 14
                                }
                                MouseArea {
                                    id: navArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.open(nav.modelData.id)
                                    Accessible.name: nav.modelData.label
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---- conteúdo: largura máxima, centralizado ---------------------------------
        Item {
            id: contentArea
            anchors { left: side.right; right: parent.right; top: parent.top; bottom: parent.bottom }
            Loader {
                id: content
                width: Math.min(720, contentArea.width - (card.rail ? 36 : 80))
                height: contentArea.height - (card.rail ? 36 : 56)
                x: (contentArea.width - width) / 2
                y: card.rail ? 18 : 28
                source: root.pages[root.pageIndex].file
                // Troca de página: o conteúdo novo entra subindo um pouco (follow-through).
                onLoaded: { item.opacity = 0; slideIn.restart(); }
                ParallelAnimation {
                    id: slideIn
                    NumberAnimation { target: content.item; property: "opacity"; from: 0; to: 1; duration: Tok.panel; easing.type: Easing.OutCubic }
                    NumberAnimation { target: content.item; property: "y"; from: 10; to: 0; duration: Tok.panel; easing.type: Easing.OutCubic }
                }
            }
        }

        // Fechar
        Rectangle {
            anchors { right: parent.right; top: parent.top; margins: 16 }
            width: 32; height: 32; radius: 16
            color: closeArea.containsMouse ? Tok.hover : "transparent"
            Behavior on color { ColorAnimation { duration: Tok.fast } }
            Ico { anchors.centerIn: parent; size: 16; d: Icons.close; color: Tok.muted }
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
