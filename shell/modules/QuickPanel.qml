import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Painel rápido (clique nos ícones de status da barra): rede, som, brilho, bateria e os
// botões de sessão. Reiniciar e desligar pedem um segundo clique para confirmar.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-quick"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property string confirm: ""          // "reboot" | "poweroff" aguardando o segundo clique

    function session(action) {
        if ((action === "reboot" || action === "poweroff") && confirm !== action) {
            confirm = action;
            confirmTimer.restart();
            return;
        }
        Panels.closeAll();
        if (action === "lock") Panels.lockRequested();
        else if (action === "suspend") { Panels.lockRequested(); Quickshell.execDetached(["systemctl", "suspend"]); }
        else if (action === "logout") Hypr.dispatch("hl.dsp.exit()");
        else Quickshell.execDetached(["systemctl", action]);
    }
    Timer { id: confirmTimer; interval: 4000; onTriggered: root.confirm = "" }

    MouseArea { anchors.fill: parent; onClicked: Panels.closeAll() }

    Glass {
        id: card
        width: 340
        height: col.implicitHeight + 32
        x: parent.width - width - 10
        y: 36 + 8
        radius: Tok.rPanel - 4
        focus: true
        Keys.onEscapePressed: Panels.closeAll()
        MouseArea { anchors.fill: parent }          // clique dentro não fecha

        // Entrada: desce de leve a partir da barra e cresce do canto (arco + overshoot).
        transformOrigin: Item.TopRight
        opacity: 0
        scale: 0.94
        transform: Translate { id: drop; y: -8 }
        Component.onCompleted: { opacity = 1; scale = 1; drop.y = 0; forceActiveFocus(); }
        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
        Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }

        Column {
            id: col
            x: 16; y: 16
            width: parent.width - 32
            spacing: 14

            // ---- rede ----------------------------------------------------------------
            Rectangle {
                id: netTile
                readonly property bool on: Network.connected || (Network.hasWifi && Network.wifiEnabled)
                width: parent.width; height: 60
                radius: Tok.rField
                color: netArea.containsMouse ? Tok.hover : Tok.surface
                border { width: 1; color: Tok.border }
                Behavior on color { ColorAnimation { duration: Tok.fast } }
                Rectangle {
                    x: 12; anchors.verticalCenter: parent.verticalCenter
                    width: 36; height: 36; radius: 18
                    color: netTile.on ? Tok.accent : Tok.surfaceHi
                    Behavior on color { ColorAnimation { duration: Tok.panel } }
                    Ico { anchors.centerIn: parent; size: 18; d: Network.hasWifi ? (Network.wifiEnabled ? Icons.wifi : Icons.wifiOff) : Network.icon
                          color: netTile.on ? Tok.textOnAccent : Tok.muted }
                }
                Column {
                    x: 60; anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 72
                    spacing: 2
                    Txt { width: parent.width; text: Network.hasWifi ? "Wi-Fi" : "Rede"; font.weight: Font.DemiBold }
                    Txt { width: parent.width; text: Network.hasWifi && !Network.wifiEnabled ? "Desligado" : Network.label; muted: true; font.pixelSize: 13 }
                }
                MouseArea {
                    id: netArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: Network.hasWifi
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Network.setWifi(!Network.wifiEnabled)
                    Accessible.name: Network.wifiEnabled ? "Desligar o Wi-Fi" : "Ligar o Wi-Fi"
                }
            }

            // ---- som -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: 8
                Item {
                    width: parent.width; height: 18
                    Txt { text: "Som"; font.weight: Font.DemiBold }
                    Txt { anchors.right: parent.right; text: Audio.label; muted: true; font.pixelSize: 13; font.features: { "tnum": 1 } }
                }
                Row {
                    width: parent.width
                    spacing: 12
                    IconButton { icon: Audio.icon; label: Audio.muted ? "Ligar o som" : "Silenciar"; onClicked: Audio.toggleMute() }
                    Slider {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 44
                        enabled: Audio.available
                        value: Audio.volume
                        onMoved: v => Audio.setVolume(v)
                    }
                }
            }

            // ---- brilho (só com luz de fundo controlável) ----------------------------
            Column {
                visible: Brightness.available
                width: parent.width
                spacing: 8
                Item {
                    width: parent.width; height: 18
                    Txt { text: "Brilho"; font.weight: Font.DemiBold }
                    Txt { anchors.right: parent.right; text: Math.round(Brightness.value * 100) + "%"; muted: true; font.pixelSize: 13 }
                }
                Row {
                    width: parent.width
                    spacing: 12
                    Item { width: 32; height: 32; Ico { anchors.centerIn: parent; d: Icons.sun; color: Tok.muted } }
                    Slider {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 44
                        value: Brightness.value
                        onMoved: v => Brightness.set(v)
                    }
                }
            }

            // ---- bateria -------------------------------------------------------------
            Item {
                visible: Battery.present
                width: parent.width; height: visible ? 22 : 0
                BatteryIcon { anchors.verticalCenter: parent.verticalCenter }
                Txt { x: 34; anchors.verticalCenter: parent.verticalCenter; text: "Bateria " + Battery.label; color: Battery.low ? Tok.error : Tok.text }
            }

            Rectangle { width: parent.width; height: 1; color: Tok.border }

            // ---- sessão --------------------------------------------------------------
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                IconButton { icon: Icons.gear; label: "Configurações"; onClicked: Panels.openSettings("") }
                IconButton { icon: Icons.lock; label: "Bloquear"; onClicked: root.session("lock") }
                IconButton { icon: Icons.logout; label: "Sair da sessão"; onClicked: root.session("logout") }
                IconButton { icon: Icons.moon; label: "Suspender"; onClicked: root.session("suspend") }
                IconButton { icon: Icons.restart; label: "Reiniciar"; danger: root.confirm === "reboot"; onClicked: root.session("reboot") }
                IconButton { icon: Icons.power; label: "Desligar"; danger: root.confirm === "poweroff"; onClicked: root.session("poweroff") }
            }
            Txt {
                width: parent.width
                height: root.confirm !== "" ? 18 : 0
                opacity: root.confirm !== "" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Tok.fast } }
                horizontalAlignment: Text.AlignHCenter
                text: root.confirm === "reboot" ? "Clique de novo para reiniciar" : "Clique de novo para desligar"
                color: Tok.error
                font.pixelSize: 13
            }
        }
    }
}
