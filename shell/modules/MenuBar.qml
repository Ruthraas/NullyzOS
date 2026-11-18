import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Barra de menus (topo): símbolo (abre a busca), nome do app ativo, workspaces; à direita
// os ícones de status (rede, som, bateria; clique abre o painel rápido) e a data e a hora. Altura fixa: o desenho por software não redesenha janela que muda de tamanho.
PanelWindow {
    id: bar
    required property var modelData
    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: 36
    exclusiveZone: 36
    color: "transparent"
    WlrLayershell.namespace: "nullyzos-menubar"

    readonly property var activeEntry: Hypr.activeToplevel ? Apps.byId(Hypr.activeToplevel.appId || "") : null
    readonly property string activeName: activeEntry ? activeEntry.name
        : (Hypr.activeToplevel ? (Hypr.activeToplevel.appId || "") : "NullyzOS")

    Glass {
        anchors.fill: parent
        radius: 0
        topLight: false
        border.width: 0
        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Tok.edge }
    }

    // ---- esquerda ---------------------------------------------------------------------
    Row {
        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
        spacing: 10

        // Símbolo: abre a busca (como o menu do sistema)
        Rectangle {
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

        // Workspaces: pílula no ativo, pontos nos outros (1–5 sempre, mais os ocupados)
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Repeater {
                model: {
                    const ids = [1, 2, 3, 4, 5];
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
            visible: Prefs.showAppName
            anchors.verticalCenter: parent.verticalCenter
            text: bar.activeName
            font.weight: Font.DemiBold
            width: Math.min(implicitWidth, 360)
        }
    }

    // ---- direita ----------------------------------------------------------------------
    Row {
        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        spacing: 12

        // Status: um alvo só (como no macOS); rolar a roda em cima muda o volume.
        Rectangle {
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

        Txt { visible: Prefs.showDate; anchors.verticalCenter: parent.verticalCenter; text: Clock.dayShort; font.weight: Font.Medium }
        Txt { anchors.verticalCenter: parent.verticalCenter; text: Prefs.clockSeconds ? Clock.timeSec : Clock.time; font.weight: Font.Medium; font.features: { "tnum": 1 } }
    }
}
