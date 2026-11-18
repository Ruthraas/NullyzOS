import QtQuick
import Quickshell.Services.Pipewire
import qs.theme
import qs.services
import qs.components

// Configurações → Som: volume, escolha da saída (alto-falante, fone, HDMI…) e da entrada
// (microfone) com o volume dela. Tudo pelo PipeWire.
SettingsPage {
    id: page
    title: "Som"
    subtitle: "Saída, entrada e volume."

    readonly property var devices: Pipewire.nodes.values.filter(n => n.audio && !n.isStream && n.name !== "auto_null")
    readonly property var outputs: devices.filter(n => n.isSink)
    readonly property var inputs: devices.filter(n => !n.isSink)
    readonly property var source: Pipewire.defaultAudioSource

    function nameOf(n) { return n.description || n.nickname || n.name || "Sem nome"; }

    PwObjectTracker { objects: page.devices }

    // ---- volume de saída -------------------------------------------------------------
    SettingsRow {
        title: "Volume"
        description: Audio.available ? Audio.label : "Nenhuma saída de som encontrada."
        Row {
            spacing: 12
            IconButton { icon: Audio.icon; label: Audio.muted ? "Ligar o som" : "Silenciar"; onClicked: Audio.toggleMute() }
            Slider { anchors.verticalCenter: parent.verticalCenter; width: 220; enabled: Audio.available; value: Audio.volume; onMoved: v => Audio.setVolume(v) }
        }
    }

    Txt { text: "Saída"; font.weight: Font.DemiBold; visible: page.outputs.length > 0 }
    DeviceList { model: page.outputs; current: Audio.sink; onPicked: n => Pipewire.preferredDefaultAudioSink = n }

    Txt { text: "Entrada"; font.weight: Font.DemiBold; visible: page.inputs.length > 0 }
    DeviceList { model: page.inputs; current: page.source; onPicked: n => Pipewire.preferredDefaultAudioSource = n }

    SettingsRow {
        visible: !!(page.source && page.source.audio)
        title: "Volume do microfone"
        description: page.source && page.source.audio ? (page.source.audio.muted ? "Mudo" : Math.round(page.source.audio.volume * 100) + "%") : ""
        Row {
            spacing: 12
            IconButton {
                icon: page.source && page.source.audio && page.source.audio.muted ? Icons.volumeOff : Icons.volumeHigh
                label: "Silenciar o microfone"
                onClicked: page.source.audio.muted = !page.source.audio.muted
            }
            Slider {
                anchors.verticalCenter: parent.verticalCenter; width: 220
                value: page.source && page.source.audio ? page.source.audio.volume : 0
                onMoved: v => { if (page.source && page.source.audio) page.source.audio.volume = v; }
            }
        }
    }

    Txt {
        visible: page.devices.length === 0
        width: parent.width
        text: "Nenhum dispositivo de som encontrado. Em máquina virtual, ligue o áudio nas configurações da VM."
        muted: true
        size: 13
        wrapMode: Text.Wrap
        elide: Text.ElideNone
    }

    // Lista de dispositivos com a escolha atual marcada.
    component DeviceList: Rectangle {
        id: dl
        property var model: []
        property var current: null
        signal picked(var node)
        visible: model.length > 0
        width: parent.width
        height: col.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: col
            width: parent.width
            Repeater {
                model: dl.model
                Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool chosen: dl.current === modelData
                    width: col.width; height: 46
                    color: area.containsMouse ? Tok.hover : "transparent"
                    radius: Tok.rField
                    Rectangle {
                        x: 16; anchors.verticalCenter: parent.verticalCenter
                        width: 18; height: 18; radius: 9
                        color: "transparent"
                        border { width: 2; color: parent.chosen ? Tok.accent : Tok.border }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 8; height: 8; radius: 4
                            color: Tok.accent
                            scale: parent.parent.chosen ? 1 : 0
                            Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
                        }
                    }
                    Txt { x: 48; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 64; text: page.nameOf(parent.modelData) }
                    Rectangle {
                        visible: parent.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                    MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dl.picked(parent.modelData) }
                }
            }
        }
    }
}
