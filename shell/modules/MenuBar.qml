import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Barra de menus (topo): símbolo (abre a busca), nome do app ativo, workspaces; à direita
// os ícones de status (rede, som, bateria; clique abre o painel rápido) e a data e a hora
// (clique abre o calendário). Cada parte liga/desliga em Configurações → Barra e dock.
// Estilos (Prefs.barStyle): clássica (vidro de ponta a ponta), flutuante (vidro solto das
// bordas, cantos redondos), ilhas (cada grupo numa pílula: símbolo e workspaces, nome do app
// no meio, status e relógio) e sem fundo (só o conteúdo sobre o wallpaper).
// Altura fixa por janela: o desenho por software não redesenha janela que muda de tamanho;
// trocar a altura (ou o respiro dos estilos soltos) recria a barra (shell.qml).
PanelWindow {
    id: bar
    required property var modelData
    screen: modelData
    anchors { top: true; left: true; right: true }
    readonly property int size: Prefs.barHeight
    readonly property int gap: Prefs.barGap
    readonly property string style: Prefs.barStyle
    readonly property bool islands: style === "ilhas"
    // Cantos das partes soltas: pílula de verdade, acompanhando o arredondamento escolhido
    readonly property real pill: Math.min(size / 2, Math.max(4, 14 * Tok.roundness))
    implicitHeight: size + gap
    exclusiveZone: size + gap
    color: "transparent"
    WlrLayershell.namespace: "nullyzos-menubar"

    readonly property var activeEntry: Hypr.activeToplevel ? Apps.byId(Hypr.activeToplevel.appId || "") : null
    // Tela estreita: some o nome do app e a data fica curta (17/11).
    readonly property bool narrow: width < Tok.narrow
    readonly property string activeName: activeEntry ? activeEntry.name
        : (Hypr.activeToplevel ? (Hypr.activeToplevel.appId || "") : "NullyzOS")

    // Fundo: clássica e flutuante (as ilhas desenham o próprio, atrás de cada grupo)
    Glass {
        visible: bar.style === "classica"
        anchors.fill: parent
        radius: 0
        topLight: false
        border.width: 0
        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Tok.edge }
    }
    Glass {
        visible: bar.style === "flutuante"
        x: 8; y: bar.gap
        width: parent.width - 16; height: bar.size
        radius: bar.pill
    }
    // Ilhas: uma pílula atrás de cada grupo, do tamanho do que tem dentro
    Glass {
        visible: bar.islands && leftRow.width > 0
        x: content.x + leftRow.x - 8; y: bar.gap
        width: leftRow.width + 16; height: bar.size
        radius: bar.pill
    }
    Glass {
        visible: bar.islands && centerName.visible
        x: content.x + centerName.x - 14; y: bar.gap
        width: centerName.width + 28; height: bar.size
        radius: bar.pill
    }
    Glass {
        visible: bar.islands
        x: content.x + rightRow.x - 6; y: bar.gap
        width: rightRow.width + 12; height: bar.size
        radius: bar.pill
    }

    // Área do conteúdo: abaixo do respiro, com recuo lateral nos estilos soltos
    Item {
        id: content
        x: bar.style === "classica" || bar.style === "semfundo" ? 0 : 8
        y: bar.gap
        width: parent.width - 2 * x
        height: bar.size

    // Ilhas: o nome do app vai para uma ilha própria, no meio
    Txt {
        id: centerName
        visible: bar.islands && Prefs.showAppName && !bar.narrow
        anchors.centerIn: parent
        text: bar.activeName
        font.weight: Font.DemiBold
        width: Math.min(implicitWidth, 320)
    }

    // ---- esquerda ---------------------------------------------------------------------
    Row {
        id: leftRow
        anchors { left: parent.left; leftMargin: bar.islands ? 10 : 12; verticalCenter: parent.verticalCenter }
        spacing: 10

        // Símbolo: abre a busca (como o menu do sistema)
        Rectangle {
            visible: Prefs.showLogo
            width: 30; height: 26; radius: Tok.rButton
            anchors.verticalCenter: parent.verticalCenter
            color: logoArea.containsMouse ? Tok.hover : "transparent"
            Behavior on color { ColorAnimation { duration: Tok.fast } }
            PixelN { anchors.centerIn: parent; cell: 2 }
            MouseArea {
                id: logoArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Panels.toggleLauncher()
                Accessible.name: "Buscar apps"
            }
        }

        // Workspaces: pílula no ativo, pontos nos outros (1..N sempre, mais os ocupados)
        Row {
            visible: Prefs.showWorkspaces
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Repeater {
                model: {
                    const ids = [];
                    for (let i = 1; i <= Prefs.workspaceCount; i++) ids.push(i);
                    for (const w of Hypr.workspaces) if (!ids.includes(w.id)) ids.push(w.id);
                    return ids.sort((a, b) => a - b);
                }
                Rectangle {
                    required property int modelData
                    readonly property bool active: modelData === Hypr.activeWs
                    readonly property bool used: Hypr.workspaces.some(w => w.id === modelData)
                    anchors.verticalCenter: parent.verticalCenter
                    width: active ? 22 : 7; height: 7; radius: 3.5
                    color: active ? Tok.accent : (used ? Tok.text : Tok.faint)
                    Behavior on width { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: Tok.fast } }
                    MouseArea {
                        anchors { fill: parent; margins: -5 }
                        onClicked: Hypr.focusWorkspace(parent.modelData)
                        Accessible.name: "Workspace " + parent.modelData
                    }
                }
            }
        }

        Txt {
            visible: Prefs.showAppName && !bar.narrow && !bar.islands
            anchors.verticalCenter: parent.verticalCenter
            text: bar.activeName
            font.weight: Font.DemiBold
            width: Math.min(implicitWidth, 360)
        }
    }

    // ---- direita ----------------------------------------------------------------------
    Row {
        id: rightRow
        anchors { right: parent.right; rightMargin: bar.islands ? 6 : 8; verticalCenter: parent.verticalCenter }
        spacing: 4

        // Atualizações disponíveis: seta com o número; clique abre a página
        Rectangle {
            visible: Updates.count > 0 || Updates.updating
            anchors.verticalCenter: parent.verticalCenter
            width: updRow.implicitWidth + 14; height: 26; radius: Tok.rButton
            color: updArea.containsMouse ? Tok.hover : "transparent"
            Behavior on color { ColorAnimation { duration: Tok.fast } }
            Row {
                id: updRow
                anchors.centerIn: parent
                spacing: 4
                Ico { anchors.verticalCenter: parent.verticalCenter; size: 16; d: Icons.download; color: Tok.accent }
                Txt { anchors.verticalCenter: parent.verticalCenter; text: Updates.count; size: 13; color: Tok.accent; font.weight: Font.DemiBold }
            }
            MouseArea {
                id: updArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Panels.openSettings("atualizacoes")
                Accessible.name: Updates.count + " atualizações disponíveis"
            }
        }

        // Status: um alvo só (como no macOS); rolar a roda em cima muda o volume.
        Rectangle {
            visible: Prefs.showStatus
            anchors.verticalCenter: parent.verticalCenter
            width: status.implicitWidth + 16; height: 26; radius: Tok.rButton
            color: Panels.quick ? Tok.selection : (statusArea.containsMouse ? Tok.hover : "transparent")
            Behavior on color { ColorAnimation { duration: Tok.fast } }
            Row {
                id: status
                anchors.centerIn: parent
                spacing: 10
                Ico { anchors.verticalCenter: parent.verticalCenter; size: 17; d: Network.icon; color: Network.connected ? Tok.text : Tok.muted }
                Ico { anchors.verticalCenter: parent.verticalCenter; size: 17; d: Audio.icon; color: Audio.available ? Tok.text : Tok.muted }
                BatteryIcon { visible: Battery.present; anchors.verticalCenter: parent.verticalCenter; size: 20 }
            }
            MouseArea {
                id: statusArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Panels.toggleQuick()
                Accessible.name: "Painel rápido: " + Network.label + ", som " + Audio.label
            }
            WheelHandler { onWheel: event => Audio.setVolume(Audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)) }
        }

        // Data e hora: um alvo só, abre o calendário e a agenda.
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: clockRow.implicitWidth + 16; height: 26; radius: Tok.rButton
            color: Panels.calendar ? Tok.selection : (clockArea.containsMouse ? Tok.hover : "transparent")
            Behavior on color { ColorAnimation { duration: Tok.fast } }
            Row {
                id: clockRow
                anchors.centerIn: parent
                spacing: 10
                Txt { visible: Prefs.showDate; anchors.verticalCenter: parent.verticalCenter; text: bar.narrow ? Qt.formatDate(Clock.now, "dd/MM") : Clock.dayShort; font.weight: Font.Medium }
                Txt { anchors.verticalCenter: parent.verticalCenter; text: Prefs.clockSeconds ? Clock.timeSec : Clock.time; font.weight: Font.Medium; font.features: { "tnum": 1 } }
            }
            MouseArea {
                id: clockArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Panels.toggleCalendar()
                Accessible.name: "Calendário: " + Clock.dateLong
            }
        }
    }
    }
}
