import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Painel rápido (clique nos ícones de status da barra): botões rápidos (Wi-Fi, luz noturna,
// não perturbe), a música tocando, som, brilho, bateria, notificações e os botões de
// sessão. Reiniciar e desligar pedem um segundo clique. Rola se não couber na tela.
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

    // "há 5 min", "14:02"
    function ago(t) {
        const s = Math.floor((Clock.now - t) / 1000);
        if (s < 60) return "agora";
        if (s < 3600) return "há " + Math.floor(s / 60) + " min";
        return Clock.hm(t);
    }

    MouseArea { anchors.fill: parent; onClicked: Panels.closeAll() }

    // Botão rápido: ícone em círculo (aceso na cor de destaque) + título e estado
    component Tile: Rectangle {
        id: tile
        property string icon
        property string title
        property string status
        property bool lit: false
        property bool clickable: true
        signal clicked()
        height: 60
        radius: Tok.rField
        color: tArea.containsMouse && clickable ? Tok.hover : Tok.surface
        border { width: 1; color: Tok.border }
        scale: tArea.pressed ? 0.97 : 1
        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: Tok.fast } }
        Rectangle {
            x: 12; anchors.verticalCenter: parent.verticalCenter
            width: 36; height: 36; radius: 18
            color: tile.lit ? Tok.accent : Tok.surfaceHi
            Behavior on color { ColorAnimation { duration: Tok.panel } }
            Ico { anchors.centerIn: parent; size: 18; d: tile.icon; color: tile.lit ? Tok.textOnAccent : Tok.muted }
        }
        Column {
            x: 58; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 66
            spacing: 1
            Txt { width: parent.width; text: tile.title; font.weight: Font.DemiBold; size: 13 }
            Txt { width: parent.width; text: tile.status; muted: true; size: 12 }
        }
        MouseArea {
            id: tArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: tile.clickable
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.clicked()
            Accessible.name: tile.title + ": " + tile.status
        }
    }

    Glass {
        id: card
        width: Math.min(360, parent.width - 20)
        height: Math.min(col.implicitHeight + 32, parent.height - y - 10)
        x: parent.width - width - 10
        y: Prefs.barSpace + 8
        radius: Tok.rPanel - 4
        clip: true
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

        Flickable {
            anchors.fill: parent
            contentHeight: col.implicitHeight + 32
            boundsBehavior: Flickable.StopAtBounds
            clip: true

        Column {
            id: col
            x: 16; y: 16
            width: card.width - 32
            spacing: 14

            // ---- botões rápidos ------------------------------------------------------
            Tile {
                width: parent.width
                icon: Network.hasWifi ? (Network.wifiEnabled ? Icons.wifi : Icons.wifiOff) : Network.icon
                title: Network.hasWifi ? "Wi-Fi" : "Rede"
                status: Network.hasWifi && !Network.wifiEnabled ? "Desligado" : Network.label
                lit: Network.connected || (Network.hasWifi && Network.wifiEnabled)
                clickable: Network.hasWifi
                onClicked: Network.setWifi(!Network.wifiEnabled)
            }
            Row {
                width: parent.width
                spacing: 10
                Tile {
                    width: (parent.width - 10) / 2
                    icon: Icons.moon
                    title: "Luz noturna"
                    status: NightLight.active ? (NightLight.scheduled ? "Até as 7h" : "Ligada") : "Desligada"
                    lit: NightLight.active
                    onClicked: NightLight.toggle()
                }
                Tile {
                    width: (parent.width - 10) / 2
                    icon: Prefs.dnd ? Icons.bellOff : Icons.bell
                    title: "Não perturbe"
                    status: Prefs.dnd ? "Ligado" : "Desligado"
                    lit: Prefs.dnd
                    onClicked: Prefs.set("dnd", !Prefs.dnd)
                }
            }

            // ---- tocando agora -------------------------------------------------------
            Rectangle {
                visible: Media.active
                width: parent.width; height: visible ? 76 : 0
                radius: Tok.rField
                color: Tok.surface
                border { width: 1; color: Tok.border }
                Rectangle {
                    id: artBox
                    x: 12; anchors.verticalCenter: parent.verticalCenter
                    width: 52; height: 52; radius: Tok.rButton + 2
                    color: Tok.surfaceHi
                    clip: true
                    Image {
                        anchors.fill: parent
                        source: Media.art
                        sourceSize: Qt.size(104, 104)
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                    }
                    Ico { anchors.centerIn: parent; visible: Media.art === ""; size: 22; d: Icons.play; color: Tok.muted }
                }
                Column {
                    anchors { left: artBox.right; leftMargin: 12; right: controls.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                    spacing: 2
                    Txt { width: parent.width; text: Media.title; font.weight: Font.DemiBold; size: 13 }
                    Txt { width: parent.width; text: Media.artist || Media.app; muted: true; size: 12 }
                }
                Row {
                    id: controls
                    anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    spacing: 4
                    IconButton { icon: Icons.prev; label: "Anterior"; onClicked: Media.previous() }
                    IconButton { icon: Media.playing ? Icons.pause : Icons.play; label: Media.playing ? "Pausar" : "Tocar"; onClicked: Media.toggle() }
                    IconButton { icon: Icons.next; label: "Próxima"; onClicked: Media.next() }
                }
            }

            // ---- som -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: 8
                Item {
                    width: parent.width; height: 18
                    Txt { text: "Som"; font.weight: Font.DemiBold }
                    Txt { anchors.right: parent.right; text: Audio.label; muted: true; size: 13; font.features: { "tnum": 1 } }
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
                    Txt { anchors.right: parent.right; text: Math.round(Brightness.value * 100) + "%"; muted: true; size: 13}
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

            // ---- notificações --------------------------------------------------------
            Column {
                width: parent.width
                spacing: 6
                Item {
                    width: parent.width; height: 22
                    Txt { anchors.verticalCenter: parent.verticalCenter; text: "Notificações"; font.weight: Font.DemiBold }
                    Chip {
                        visible: Notifs.history.length > 0
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        height: 24
                        text: "Limpar"
                        onClicked: Notifs.clear()
                    }
                }
                Txt {
                    visible: Notifs.history.length === 0
                    text: Prefs.dnd ? "Nada novo. Não perturbe está ligado." : "Nada novo."
                    muted: true; size: 13
                }
                Repeater {
                    model: Notifs.history.slice(0, 5)
                    Rectangle {
                        id: nItem
                        required property var modelData
                        width: col.width; height: nCol.implicitHeight + 20
                        radius: Tok.rField
                        color: Tok.surface
                        border { width: 1; color: Tok.border }
                        Image {
                            id: nIcon
                            x: 12; y: 12
                            width: 28; height: 28
                            sourceSize: Qt.size(56, 56)
                            source: nItem.modelData.icon
                            visible: source != ""
                        }
                        Column {
                            id: nCol
                            x: nIcon.visible ? 50 : 12; y: 10
                            width: parent.width - x - 40
                            spacing: 2
                            Txt { width: parent.width; text: (nItem.modelData.app || "Notificação") + " · " + root.ago(nItem.modelData.time); muted: true; size: 11 }
                            Txt { width: parent.width; text: nItem.modelData.summary; font.weight: Font.DemiBold; size: 13 }
                            Txt {
                                width: parent.width
                                visible: text !== ""
                                text: nItem.modelData.body
                                muted: true; size: 12
                                wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight
                            }
                        }
                        IconButton {
                            anchors { right: parent.right; rightMargin: 6; top: parent.top; topMargin: 6 }
                            width: 26; height: 26
                            icon: Icons.close
                            label: "Dispensar"
                            onClicked: Notifs.dismiss(nItem.modelData.id)
                        }
                    }
                }
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
                size: 13
            }
        }
        }
    }
}
