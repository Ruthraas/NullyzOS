import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services

// Fundo da área de trabalho: a imagem escolhida em Configurações → Aparência (padrão: as
// manchas de cor do Nullyz). Trocou, a nova aparece por cima da antiga num fade.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Tok.bg
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "nullyzos-wallpaper"

    readonly property string want: Prefs.wallpaperUrl
    onWantChanged: {
        back.source = front.source;
        fade.enabled = false;
        front.opacity = 0;
        fade.enabled = true;
        front.source = want;
    }

    Image {
        id: back
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.height)
        smooth: true
        asynchronous: true
    }
    Image {
        id: front
        anchors.fill: parent
        source: root.want
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.height)
        smooth: true
        asynchronous: true
        opacity: 0
        onStatusChanged: if (status === Image.Ready) opacity = 1
        Behavior on opacity { id: fade; NumberAnimation { duration: Tok.slow; easing.type: Easing.InOutCubic } }
    }
}
