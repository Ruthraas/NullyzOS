import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Boas-vindas no primeiro login (Prefs.welcomed = false), também em Configurações → Sobre.
// "Seja bem-vindo(a) ao NullyzOS" e a frase do primeiro boot; depois três passos: o visual
// (tema e cor), o navegador (Brave) e os atalhos principais. "Começar" fecha de vez.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-welcome"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property int step: 0                // 0 frase, 1 visual, 2 navegador, 3 atalhos

    function finish() { Prefs.set("welcomed", true); Panels.welcome = false; }

    Rectangle { anchors.fill: parent; color: Tok.scrim }

    Rectangle {
        id: card
        width: Math.min(640, parent.width - 32)
        height: Math.min(520, parent.height - 48)
        anchors.centerIn: parent
        radius: Tok.rPanel
        color: Tok.bg
        border { width: 1; color: Tok.edge }
        clip: true
        focus: true
        Keys.onEscapePressed: root.finish()
        opacity: 0
        scale: 0.96
        Component.onCompleted: { opacity = 1; scale = 1; forceActiveFocus(); }
        Behavior on opacity { NumberAnimation { duration: Tok.slow } }
        Behavior on scale { NumberAnimation { duration: Tok.slow; easing.type: Easing.OutBack } }

        // ---- passo 0: boas-vindas + frase -------------------------------------------------
        Column {
            visible: root.step === 0
            anchors.centerIn: parent
            width: parent.width - 96
            spacing: 22
            PixelN { anchors.horizontalCenter: parent.horizontalCenter; cell: 9 }
            Txt {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Seja bem-vindo(a) ao NullyzOS"
                size: 28; font { family: Tok.mono; weight: Font.DemiBold }
                wrapMode: Text.Wrap; elide: Text.ElideNone
            }
            Txt {
                id: quote
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "\"É preciso ter o caos dentro de si para dar à luz uma estrela dançante.\"\n— Nietzsche"
                muted: true
                size: 15; font.family: Tok.mono
                wrapMode: Text.Wrap; elide: Text.ElideNone
                opacity: 0
                SequentialAnimation on opacity {
                    running: root.step === 0
                    PauseAnimation { duration: 700 }
                    NumberAnimation { to: 1; duration: 1200; easing.type: Easing.InOutQuad }
                }
            }
        }

        // ---- passo 1: visual --------------------------------------------------------------
        Column {
            visible: root.step === 1
            anchors.centerIn: parent
            width: parent.width - 96
            spacing: 18
            Txt { text: "Do seu jeito"; size: 26; font.weight: Font.DemiBold }
            Txt { width: parent.width; text: "Escolha o tema e a cor. Dá para mudar tudo depois em Configurações (Super + vírgula)."; muted: true; wrapMode: Text.Wrap; elide: Text.ElideNone }
            Row {
                spacing: 8
                Repeater {
                    model: [["escuro", "Escuro"], ["claro", "Claro"], ["auto", "Automático"]]
                    Chip { required property var modelData; text: modelData[1]; active: (Prefs.theme || "escuro") === modelData[0]; onClicked: Prefs.set("theme", modelData[0]) }
                }
            }
            Row {
                spacing: 14
                Repeater {
                    model: Tok.accentOrder
                    Rectangle {
                        required property string modelData
                        width: 32; height: 32; radius: 16
                        color: Tok.light ? Tok.accents[modelData].light : Tok.accents[modelData].color
                        border { width: Tok.accentName === modelData ? 3 : 0; color: Tok.text }
                        scale: wArea.pressed ? 0.88 : (wArea.containsMouse ? 1.1 : 1)
                        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                        MouseArea { id: wArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Prefs.set("accent", parent.modelData) }
                    }
                }
            }
            SettingsRow {
                title: "Dock"
                description: "Uma barra de apps embaixo da tela."
                Toggle { checked: Prefs.dock; onToggled: v => Prefs.set("dock", v) }
            }
        }

        // ---- passo 2: navegador -----------------------------------------------------------
        Column {
            visible: root.step === 2
            anchors.centerIn: parent
            width: parent.width - 96
            spacing: 18
            Txt { text: "Navegador"; size: 26; font.weight: Font.DemiBold }
            Txt {
                width: parent.width
                text: Flatpak.has("com.brave.Browser")
                    ? "O Brave já está instalado e é o navegador padrão. Ele bloqueia anúncios e rastreadores sem precisar de extensão."
                    : "O NullyzOS usa o Brave: rápido e com bloqueio de anúncios. Ele vem do Flathub, publicado pelo próprio Brave."
                muted: true; wrapMode: Text.Wrap; elide: Text.ElideNone
            }
            Chip {
                visible: !Flatpak.has("com.brave.Browser")
                text: Flatpak.busy === "com.brave.Browser" ? "Instalando… " + Flatpak.progress : "Instalar o Brave"
                active: true
                onClicked: Flatpak.install("com.brave.Browser")
            }
            Txt { width: parent.width; text: "Mais apps: Configurações → Apps (loja do Flathub, sem senha)."; muted: true; size: 13; wrapMode: Text.Wrap; elide: Text.ElideNone }
        }

        // ---- passo 3: atalhos -------------------------------------------------------------
        Column {
            visible: root.step === 3
            anchors.centerIn: parent
            width: parent.width - 96
            spacing: 12
            Txt { text: "Os atalhos que mais importam"; size: 24; font.weight: Font.DemiBold }
            Repeater {
                model: [["Super + Espaço", "Buscar e abrir apps"], ["Super + Enter", "Terminal"], ["Super + vírgula", "Configurações"],
                        ["Super + E", "Arquivos"], ["Super + L", "Bloquear a tela"], ["Super + Q", "Fechar a janela"]]
                Item {
                    required property var modelData
                    width: parent.width; height: 34
                    Txt { anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[1] }
                    Rectangle {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        width: kl.implicitWidth + 18; height: 28; radius: 7
                        color: Tok.surfaceHi
                        border { width: 1; color: Tok.border }
                        Txt { id: kl; anchors.centerIn: parent; text: parent.parent.modelData[0]; size: 13; font.family: Tok.mono }
                    }
                }
            }
            Txt { text: "Todos em Configurações → Atalhos."; muted: true; size: 13 }
        }

        // ---- rodapé: pontos + botões ------------------------------------------------------
        Row {
            anchors { left: parent.left; leftMargin: 32; bottom: parent.bottom; bottomMargin: 28 }
            spacing: 6
            Repeater {
                model: 4
                Rectangle {
                    required property int index
                    width: index === root.step ? 20 : 7; height: 7; radius: 3.5
                    color: index === root.step ? Tok.accent : Tok.faint
                    Behavior on width { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
                }
            }
        }
        Row {
            anchors { right: parent.right; rightMargin: 28; bottom: parent.bottom; bottomMargin: 20 }
            spacing: 8
            Chip { visible: root.step > 0; text: "Voltar"; onClicked: root.step-- }
            Chip { text: root.step < 3 ? "Próximo" : "Começar"; active: true; onClicked: root.step < 3 ? root.step++ : root.finish() }
        }
        Chip {
            visible: root.step < 3
            anchors { right: parent.right; rightMargin: 20; top: parent.top; topMargin: 20 }
            text: "Pular"
            onClicked: root.finish()
        }
    }
}
