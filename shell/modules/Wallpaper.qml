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

    // Cor de destaque "Do wallpaper": só a primeira tela amostra (mesma imagem em todas).
    // Lê a imagem em 48x27, separa os pixels coloridos por matiz (12 faixas, pesando
    // saturação e brilho), pega a faixa mais forte e acerta brilho/saturação para servir
    // de destaque legível no tema escuro.
    Canvas {
        id: sampler
        visible: false
        width: 48; height: 27
        enabled: Prefs.accent === "auto" && root.screen === Quickshell.screens[0]
        readonly property string src: enabled ? root.want : ""
        onSrcChanged: if (src) { if (isImageLoaded(src)) requestPaint(); else loadImage(src); }
        onImageLoaded: requestPaint()
        onPaint: {
            if (!src || !isImageLoaded(src)) return;
            const ctx = getContext("2d");
            ctx.drawImage(src, 0, 0, width, height);
            const d = ctx.getImageData(0, 0, width, height).data;
            const bins = [];
            for (let b = 0; b < 12; b++) bins.push({ w: 0, r: 0, g: 0, b: 0 });
            for (let i = 0; i < d.length; i += 4) {
                const c = Qt.rgba(d[i] / 255, d[i + 1] / 255, d[i + 2] / 255, 1);
                const s = c.hsvSaturation, v = c.hsvValue;
                if (s < 0.25 || v < 0.2 || c.hsvHue < 0) continue;
                const w = s * s * v;
                const bin = bins[Math.floor(c.hsvHue * 12) % 12];
                bin.w += w; bin.r += d[i] * w; bin.g += d[i + 1] * w; bin.b += d[i + 2] * w;
            }
            let best = bins[0];
            for (const b of bins) if (b.w > best.w) best = b;
            if (best.w < 0.5) { Tok.autoAccent = Tok.accents.violeta.color; return; }
            const m = Qt.rgba(best.r / best.w / 255, best.g / best.w / 255, best.b / best.w / 255, 1);
            Tok.autoAccent = Qt.hsla(m.hslHue, Math.max(0.55, Math.min(0.9, m.hslSaturation)), 0.68, 1);
        }
    }

    // Escurecer o fundo (legibilidade em imagens claras)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 1)
        opacity: Prefs.wallpaperDim
        Behavior on opacity { NumberAnimation { duration: Tok.panel } }
    }
}
