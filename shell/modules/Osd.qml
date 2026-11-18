import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Aviso na tela ao mudar volume ou brilho (teclas do teclado). Cápsula embaixo, no meio;
// entra subindo com overshoot, some sozinha. Não aparece com o painel rápido ou as
// Configurações abertos (lá os controles já mostram o valor). Não recebe clique.
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { bottom: true }
    margins.bottom: Prefs.dock && Prefs.dockPosition === "baixo" && !Prefs.dockAutohide ? Prefs.dockIcon + 48 : 40
    implicitWidth: 320
    implicitHeight: 64
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-osd"

    property string kind: "volume"          // volume | brilho
    property bool shown: false
    property bool ready: false               // não mostra os valores do começo da sessão
    Timer { interval: 2000; running: true; onTriggered: root.ready = true }
    Timer { id: hideTimer; interval: 1400; onTriggered: root.shown = false }

    function show(k) {
        if (!ready || Panels.quick || Panels.settings) return;
        kind = k;
        shown = true;
        hideTimer.restart();
    }
    Connections {
        target: Audio
        function onVolumeChanged() { root.show("volume"); }
        function onMutedChanged() { root.show("volume"); }
    }
    Connections {
        target: Brightness
        function onChanged() { root.show("brilho"); }
    }

    readonly property real value: kind === "brilho" ? Brightness.value : (Audio.muted ? 0 : Audio.volume)

    Glass {
        id: pill
        width: parent.width; height: parent.height
        radius: height / 2
        opacity: root.shown ? 1 : 0
        transform: Translate { y: root.shown ? 0 : 16; Behavior on y { NumberAnimation { duration: Tok.panel; easing.type: root.shown ? Easing.OutBack : Easing.InCubic } } }
        Behavior on opacity { NumberAnimation { duration: Tok.fast } }

        Ico {
            x: 22; anchors.verticalCenter: parent.verticalCenter
            size: 22
            d: root.kind === "brilho" ? Icons.sun : Audio.icon
            color: Tok.text
        }
        Rectangle {
            x: 60; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 60 - 64; height: 6; radius: 3
            color: Tok.surfaceHi
            Rectangle {
                width: Math.max(parent.height, root.value * parent.width)
                height: parent.height; radius: parent.radius
                color: Tok.accent
                Behavior on width { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutCubic } }
            }
        }
        Txt {
            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
            text: root.kind === "volume" && Audio.muted ? "Mudo" : Math.round(root.value * 100) + "%"
            size: 14; font.weight: Font.DemiBold; font.features: { "tnum": 1 }
        }
    }
}
