import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Rede: conexão atual, Wi-Fi liga/desliga e lista de redes. Rede com senha
// que ainda não foi salva abre o campo de senha na própria linha.
SettingsPage {
    id: page
    title: "Rede"
    subtitle: "Internet por cabo ou Wi-Fi."

    property string open: ""           // SSID com o campo de senha aberto

    Component.onCompleted: Network.scan()

    // ---- conexão atual ---------------------------------------------------------------
    Rectangle {
        width: parent.width; height: 64
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Rectangle {
            x: 14; anchors.verticalCenter: parent.verticalCenter
            width: 38; height: 38; radius: 19
            color: Network.connected ? Tok.accent : Tok.surfaceHi
            Ico { anchors.centerIn: parent; size: 19; d: Network.icon; color: Network.connected ? Tok.textOnAccent : Tok.muted }
        }
        Column {
            x: 64; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 80
            spacing: 2
            Txt { width: parent.width; text: Network.label; font.weight: Font.DemiBold }
            Txt {
                width: parent.width; muted: true; size: 13
                text: Network.type === "wifi" ? "Conectado pelo Wi-Fi · sinal " + Network.signal + "%"
                    : Network.type === "ethernet" ? "Conectado pelo cabo" : "Sem internet"
            }
        }
    }

    // ---- Wi-Fi -----------------------------------------------------------------------
    SettingsRow {
        visible: Network.hasWifi
        title: "Wi-Fi"
        description: Network.wifiEnabled ? "Ligado" : "Desligado: nenhuma rede sem fio é usada."
        Toggle { checked: Network.wifiEnabled; onToggled: v => Network.setWifi(v) }
    }
    Txt {
        visible: !Network.hasWifi
        width: parent.width
        text: "Este computador não tem Wi-Fi (ou o adaptador não foi reconhecido)."
        muted: true
        size: 13
        wrapMode: Text.Wrap
        elide: Text.ElideNone
    }

    Item {
        visible: Network.hasWifi && Network.wifiEnabled
        width: parent.width; height: 28
        Txt { anchors.verticalCenter: parent.verticalCenter; text: "Redes disponíveis"; font.weight: Font.DemiBold }
        Rectangle {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            width: rescan.implicitWidth + 36; height: 28; radius: Tok.rButton
            color: rescanArea.containsMouse ? Tok.hover : "transparent"
            Ico {
                id: spin
                x: 8; anchors.verticalCenter: parent.verticalCenter; size: 15; d: Icons.restart; color: Tok.muted
                RotationAnimation on rotation { running: Network.scanning; from: 0; to: 360; duration: 900; loops: Animation.Infinite }
            }
            Txt { id: rescan; x: 28; anchors.verticalCenter: parent.verticalCenter; text: Network.scanning ? "Procurando…" : "Procurar"; muted: true; size: 13}
            MouseArea { id: rescanArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Network.scan() }
        }
    }

    Rectangle {
        visible: Network.hasWifi && Network.wifiEnabled && Network.networks.length > 0
        width: parent.width
        height: list.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        clip: true
        Column {
            id: list
            width: parent.width
            Repeater {
                model: Network.networks
                Item {
                    id: net
                    required property var modelData
                    required property int index
                    readonly property bool asking: page.open === modelData.ssid
                    readonly property bool busy: Network.connecting === modelData.ssid
                    width: list.width
                    height: 48 + (asking ? 52 : 0)
                    Behavior on height { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutCubic } }
                    clip: true

                    Rectangle {
                        width: parent.width; height: 48
                        color: rowArea.containsMouse ? Tok.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Tok.fast } }
                        Ico { x: 16; anchors.verticalCenter: parent.verticalCenter; size: 18
                              d: Icons.wifiLevels[Math.min(3, Math.floor(net.modelData.signal / 25))]
                              color: net.modelData.active ? Tok.accent : Tok.text }
                        Txt {
                            x: 46; anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 46 - netState.width - 48
                            text: net.modelData.ssid
                            font.weight: net.modelData.active ? Font.DemiBold : Font.Normal
                        }
                        Row {
                            id: netState
                            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                            spacing: 8
                            Txt {
                                anchors.verticalCenter: parent.verticalCenter
                                text: net.busy ? "Conectando…" : net.modelData.active ? "Conectada" : net.modelData.known ? "Salva" : ""
                                muted: !net.modelData.active
                                color: net.modelData.active ? Tok.accent : Tok.muted
                                size: 13
                            }
                            Ico { visible: net.modelData.secure; anchors.verticalCenter: parent.verticalCenter; size: 14; d: Icons.lock; color: Tok.muted }
                        }
                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const n = net.modelData;
                                if (n.active || net.busy) return;
                                if (n.secure && !n.known) { page.open = net.asking ? "" : n.ssid; return; }
                                page.open = "";
                                Network.connect(n.ssid, "");
                            }
                            Accessible.name: "Rede " + net.modelData.ssid
                        }
                        Rectangle {
                            visible: net.index > 0
                            anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                            height: 1; color: Tok.border
                        }
                    }

                    // Senha (só para rede protegida ainda não salva)
                    Row {
                        x: 46; y: 52
                        spacing: 8
                        Rectangle {
                            width: net.width - 46 - 16 - 8 - joinBtn.width; height: 40
                            radius: Tok.rButton + 2
                            color: Tok.surfaceHi
                            border { width: 1; color: pass.activeFocus ? Tok.accent : Tok.border }
                            TextInput {
                                id: pass
                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: TextInput.Password
                                passwordCharacter: "●"
                                color: Tok.text
                                font { family: Tok.font; pixelSize: Math.round(14 * Tok.fontScale) }
                                onVisibleChanged: if (visible && net.asking) forceActiveFocus()
                                Keys.onReturnPressed: joinBtn.join()
                                Keys.onEnterPressed: joinBtn.join()
                                Keys.onEscapePressed: page.open = ""
                            }
                            Txt { x: 12; anchors.verticalCenter: parent.verticalCenter; visible: pass.text === ""; text: "Senha do Wi-Fi"; muted: true }
                        }
                        Rectangle {
                            id: joinBtn
                            function join() {
                                if (pass.text === "" || net.busy) return;
                                const ssid = net.modelData.ssid, pw = pass.text;
                                Network.connect(ssid, pw, ok => { if (ok) { page.open = ""; pass.text = ""; } });
                            }
                            width: 96; height: 40; radius: Tok.rButton + 2
                            color: joinArea.containsMouse ? Qt.lighter(Tok.accent, 1.08) : Tok.accent
                            scale: joinArea.pressed ? 0.95 : 1
                            Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                            Txt { anchors.centerIn: parent; text: net.busy ? "…" : "Conectar"; color: Tok.textOnAccent; font.weight: Font.DemiBold }
                            MouseArea { id: joinArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: joinBtn.join() }
                        }
                    }
                }
            }
        }
    }

    Txt {
        visible: Network.lastError !== ""
        width: parent.width
        text: Network.lastError
        color: Tok.error
        size: 13
        wrapMode: Text.Wrap
        elide: Text.ElideNone
    }

    // Conectada: desconectar e esquecer
    Row {
        visible: Network.type === "wifi"
        spacing: 10
        Repeater {
            model: [{ t: "Desconectar", a: "down" }, { t: "Esquecer esta rede", a: "forget" }]
            Rectangle {
                required property var modelData
                width: bl.implicitWidth + 28; height: 34; radius: Tok.rButton + 2
                color: ba.containsMouse ? Tok.hover : Tok.surfaceHi
                border { width: 1; color: Tok.border }
                Txt { id: bl; anchors.centerIn: parent; text: parent.modelData.t; size: 13}
                MouseArea {
                    id: ba
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: parent.modelData.a === "down" ? Network.disconnect(Network.name) : Network.forget(Network.name)
                }
            }
        }
    }
}
