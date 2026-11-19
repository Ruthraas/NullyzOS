import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

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

    // Ajuste (Configurações → Aparência): preencher corta as sobras, ajustar mostra a imagem
    // inteira, centralizar usa o tamanho original.
    readonly property int fit: Prefs.wallpaperFit === "ajustar" ? Image.PreserveAspectFit
        : Prefs.wallpaperFit === "centralizar" ? Image.Pad : Image.PreserveAspectCrop
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
        fillMode: root.fit
        sourceSize: root.fit === Image.Pad ? Qt.size(0, 0) : Qt.size(root.width, root.height)
        smooth: true
        asynchronous: true
    }
    Image {
        id: front
        anchors.fill: parent
        source: root.want
        fillMode: root.fit
        sourceSize: root.fit === Image.Pad ? Qt.size(0, 0) : Qt.size(root.width, root.height)
        smooth: true
        asynchronous: true
        opacity: 0
        onStatusChanged: if (status === Image.Ready) opacity = 1
        Behavior on opacity { id: fade; NumberAnimation { duration: Tok.slow; easing.type: Easing.InOutCubic } }
    }

    // Cores do wallpaper (destaque automático, tom da barra e do dock, paleta "Do wallpaper"):
    // só a primeira tela amostra (a mesma imagem em todas).
    WallpaperSampler {
        source: (Prefs.accent === "auto" || Prefs.wallpaperTint || Prefs.palette === "wallpaper")
                && root.screen === Quickshell.screens[0] ? root.want : ""
    }

    // Escurecer o fundo (legibilidade em imagens claras)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 1)
        opacity: Prefs.wallpaperDim
        Behavior on opacity { NumberAnimation { duration: Tok.panel } }
    }
}
