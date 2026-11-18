pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

// Apps nas cores do Nullyz (#16). A partir do tema (claro/escuro), da cor de destaque e da
// fonte, gera e aplica:
//   - apps Qt/KDE: esquema Nullyz.colors (em ~/.local/share/color-schemes), copiado para o kdeglobals
//     (plasma-integration lê fora do Plasma), estilo Breeze, fonte;
//   - apps GTK 3/4 e libadwaita: adw-gtk3, preferência escuro/claro e cor de destaque (gtk.css);
// via scripts/tema-apps.sh. Roda ao subir o shell e quando tema, destaque ou fonte mudam.
Singleton {
    id: root

    // Só reaplica quando muda (a assinatura aplicada fica gravada): antes rodava ~60
    // kwriteconfig6 a cada login à toa.
    readonly property string signature: ["v1", Tok.light, Tok.accentName, Tok.font].join("|")
    onSignatureChanged: debounce.restart()
    Timer { id: debounce; interval: 800; onTriggered: if (applied.loaded && applied.text().trim() !== root.signature) root.apply() }
    FileView {
        id: applied
        property bool loaded: false
        path: Prefs.dir + "/apps-tema.sig"
        onLoaded: { loaded = true; debounce.restart(); }
        onLoadFailed: { loaded = true; debounce.restart(); }
    }

    function rgb(c) {
        const q = Qt.color(c);
        return [Math.round(q.r * 255), Math.round(q.g * 255), Math.round(q.b * 255)].join(",");
    }
    function mix(a, b, t) {
        const x = Qt.color(a), y = Qt.color(b);
        return Qt.rgba(x.r + (y.r - x.r) * t, x.g + (y.g - x.g) * t, x.b + (y.b - x.b) * t, 1);
    }

    function scheme() {
        const L = Tok.light;
        const p = L ? Tok.palettes.claro : Tok.palettes.escuro;
        const e = Tok.accents[Tok.accentName] || Tok.accents.violeta;
        const acc = L ? e.light : e.color;
        const onAcc = L ? p.surface : p.bg;
        const err = Tok.error, ok = Tok.success, warn = Tok.warning, hi = Tok.surfaceHi;
        const fg = (txt, muted) => ({
            ForegroundNormal: rgb(txt), ForegroundInactive: rgb(muted), ForegroundActive: rgb(acc),
            ForegroundLink: rgb(acc), ForegroundVisited: rgb(mix(acc, txt, 0.35)),
            ForegroundNegative: rgb(err), ForegroundNeutral: rgb(warn), ForegroundPositive: rgb(ok),
            DecorationFocus: rgb(acc), DecorationHover: rgb(acc)
        });
        const group = (bg, alt, txt, muted) => Object.assign({ BackgroundNormal: rgb(bg), BackgroundAlternate: rgb(alt) }, fg(txt, muted));
        const g = {
            "Colors:Window": group(p.bg, p.surface, p.text, p.muted),
            "Colors:View": group(p.surface, hi, p.text, p.muted),
            "Colors:Button": group(hi, p.surface, p.text, p.muted),
            "Colors:Header": group(p.bg, p.surface, p.text, p.muted),
            "Colors:Tooltip": group(p.surface, hi, p.text, p.muted),
            "Colors:Complementary": group(Tok.palettes.escuro.bg, Tok.palettes.escuro.surface, Tok.palettes.escuro.text, Tok.palettes.escuro.muted),
            "Colors:Selection": group(acc, mix(acc, p.bg, 0.3), onAcc, mix(onAcc, acc, 0.4)),
            "WM": { activeBackground: rgb(p.bg), activeForeground: rgb(p.text), inactiveBackground: rgb(p.bg),
                    inactiveForeground: rgb(p.muted), activeBlend: rgb(p.bg), inactiveBlend: rgb(p.bg) },
            "General": { ColorScheme: "Nullyz", Name: "Nullyz", AccentColor: rgb(acc) }
        };
        let out = "# Gerado pelas Configurações do NullyzOS (tema, destaque): não edite.\n";
        for (const k in g) {
            out += `\n[${k}]\n`;
            for (const key in g[k]) out += `${key}=${g[k][key]}\n`;
        }
        return out;
    }

    function apply() {
        const e = Tok.accents[Tok.accentName] || Tok.accents.violeta;
        const acc = String(Tok.light ? e.light : e.color);
        colorsFile.setText(scheme());
        job.command = ["sh", Qt.resolvedUrl("../scripts/tema-apps.sh").toString().replace("file://", ""),
                       colorsFile.path, Tok.light ? "claro" : "escuro", acc, Tok.font];
        applied.setText(root.signature);
        later.restart();
    }
    Timer { id: later; interval: 200; onTriggered: if (!job.running) job.running = true }

    FileView {
        id: colorsFile
        // O script copia para ~/.local/share/color-schemes/ (a pasta pode não existir ainda)
        path: Prefs.dir + "/Nullyz.colors"
    }
    Process { id: job }
}
