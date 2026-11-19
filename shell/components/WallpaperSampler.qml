import QtQuick
import qs.theme

// Lê as cores de uma imagem (o wallpaper) e entrega ao Tok: o destaque (a matiz mais forte,
// acertada para ser legível), o tom médio (para tingir o vidro) e a matiz de base (para a
// paleta "Do wallpaper", que tira todas as cores do fundo). Lê a imagem em 48x27.
// Usado pelo fundo do Hyprland (modules/Wallpaper.qml) e pelas Configurações no KDE.
Canvas {
    id: sampler
    property string source: ""          // URL file:// da imagem; vazio = parado
    visible: false
    width: 48; height: 27
    onSourceChanged: if (source) { if (isImageLoaded(source)) requestPaint(); else loadImage(source); }
    onImageLoaded: requestPaint()
    onPaint: {
        if (!source || !isImageLoaded(source)) return;
        const ctx = getContext("2d");
        ctx.drawImage(source, 0, 0, width, height);
        const d = ctx.getImageData(0, 0, width, height).data;
        // Tom médio: média de todos os pixels, com a saturação contida
        let ar = 0, ag = 0, ab = 0;
        for (let i = 0; i < d.length; i += 4) { ar += d[i]; ag += d[i + 1]; ab += d[i + 2]; }
        const n = d.length / 4;
        const avg = Qt.rgba(ar / n / 255, ag / n / 255, ab / n / 255, 1);
        Tok.autoTint = Qt.hsla(Math.max(0, avg.hslHue), Math.min(0.75, avg.hslSaturation * 1.8), Tok.light ? 0.84 : 0.24, 1);
        // Destaque: pixels coloridos por matiz (12 faixas, pesando saturação e brilho)
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
        if (best.w < 0.5) {
            Tok.autoAccent = Tok.accents.violeta.color;
            Tok.autoHue = avg.hslSaturation > 0.08 ? Math.max(0, avg.hslHue) : 0.7;
            return;
        }
        const m = Qt.rgba(best.r / best.w / 255, best.g / best.w / 255, best.b / best.w / 255, 1);
        Tok.autoAccent = Qt.hsla(m.hslHue, Math.max(0.55, Math.min(0.9, m.hslSaturation)), 0.68, 1);
        // Base da paleta: a matiz do tom médio se ele tiver cor; senão a do destaque
        Tok.autoHue = avg.hslSaturation > 0.12 ? Math.max(0, avg.hslHue) : m.hslHue;
    }
}
