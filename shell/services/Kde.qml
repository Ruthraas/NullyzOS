pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.theme

// Ponte com o KDE Plasma (Configurações Nullyz no KDE): lê e muda a barra e o dock (scripts
// do Plasma pelo D-Bus do plasmashell), as cores (plasma-apply-colorscheme, com a cor de
// destaque), o vidro (tema do Plasma), as animações e os botões das janelas (KWin).
// A barra é o painel de cima; o dock é o outro painel (embaixo ou de lado).
Singleton {
    id: root

    readonly property bool active: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").indexOf("KDE") >= 0
    // Estado lido do Plasma: { top: {height, floating, hiding}, dock: {...location}, clock: {...} }
    property var state: ({})
    property bool loaded: false

    // Script do Plasma (mesma API do layout do tema global): roda no plasmashell
    function script(js, done) {
        const p = proc.createObject(root, { done: done || null });
        p.command = ["dbus-send", "--session", "--print-reply", "--dest=org.kde.plasmashell",
                     "/PlasmaShell", "org.kde.PlasmaShell.evaluateScript", "string:" + js];
        p.running = true;
    }
    function run(cmd) { Quickshell.execDetached(cmd); }
    function kwinReconfigure() {
        run(["dbus-send", "--session", "--type=method_call", "--dest=org.kde.KWin", "/KWin", "org.kde.KWin.reconfigure"]);
    }

    function refresh() {
        script("var r = {};"
             + "panels().forEach(function (p) {"
             + "  var k = p.location === 'top' ? 'top' : 'dock';"
             + "  r[k] = { height: p.height, floating: p.floating, hiding: p.hiding, location: p.location, lengthMode: p.lengthMode };"
             + "  if (k === 'top') { var c = p.widgets('org.kde.plasma.digitalclock')[0];"
             + "    if (c) { c.currentConfigGroup = ['Appearance']; r.clock = { showDate: c.readConfig('showDate', true), h24: c.readConfig('use24hFormat', 1) }; } }"
             + "});"
             + "print(JSON.stringify(r));",
             out => {
                 const m = out.match(/\{[\s\S]*\}/);
                 if (m) { try { root.state = JSON.parse(m[0]); } catch (e) {} }
                 root.loaded = true;
             });
    }

    // Muda propriedades do painel ("top" ou "dock") e relê
    function setPanel(which, props) {
        const cond = which === "top" ? "p.location === 'top'" : "p.location !== 'top'";
        let body = "";
        for (const k in props) body += "p." + k + " = " + JSON.stringify(props[k]) + ";";
        script("panels().forEach(function (p) { if (" + cond + ") { " + body + " } });", () => refresh());
    }
    function setClock(key, value) {
        script("panels().forEach(function (p) { if (p.location === 'top') {"
             + " var c = p.widgets('org.kde.plasma.digitalclock')[0];"
             + " if (c) { c.currentConfigGroup = ['Appearance']; c.writeConfig(" + JSON.stringify(key) + ", " + JSON.stringify(value) + "); } } });",
             () => refresh());
    }

    // Cores: esquema Nullyz (escuro/claro ou de uma paleta) com a cor de destaque
    function applyColors(scheme, accentHex) {
        const cmd = ["plasma-apply-colorscheme"];
        if (accentHex) cmd.push("--accent-color", accentHex);
        cmd.push(scheme);
        run(cmd);
        // Anota para o login seguinte (o Hyprland usa o mesmo kdeglobals e muda as cores)
        run(["sh", "-c", "mkdir -p \"$1\" && printf '%s %s\\n' \"$2\" \"$3\" > \"$1/kde-cores\"", "sh",
             Prefs.dir, scheme, accentHex || ""]);
    }
    // ---- Paleta "Do wallpaper" no KDE ----------------------------------------------------
    // Gera um esquema de cores do Plasma com as cores atuais do Tok (que a página Aparência
    // tirou do wallpaper do Plasma) e aplica. Alterna entre dois nomes: o Plasma não reaplica
    // um esquema com o mesmo nome do que já está ativo.
    property bool wallFlip: false
    function rgb(c) { const q = Qt.color(c); return [Math.round(q.r * 255), Math.round(q.g * 255), Math.round(q.b * 255)].join(","); }
    function mix(a, b, t) { const x = Qt.color(a), y = Qt.color(b); return Qt.rgba(x.r + (y.r - x.r) * t, x.g + (y.g - x.g) * t, x.b + (y.b - x.b) * t, 1); }
    function colorsText(name) {
        const acc = Tok.accentEntry.color, on = Tok.textOnAccent;
        const fg = (txt, muted) => ({
            ForegroundNormal: rgb(txt), ForegroundInactive: rgb(muted), ForegroundActive: rgb(acc),
            ForegroundLink: rgb(acc), ForegroundVisited: rgb(mix(acc, txt, 0.35)),
            ForegroundNegative: rgb(Tok.error), ForegroundNeutral: rgb(Tok.warning), ForegroundPositive: rgb(Tok.success),
            DecorationFocus: rgb(acc), DecorationHover: rgb(acc)
        });
        const group = (bg, alt, txt, muted) => Object.assign({ BackgroundNormal: rgb(bg), BackgroundAlternate: rgb(alt) }, fg(txt, muted));
        const g = {
            "General": { ColorScheme: name, Name: "Nullyz do wallpaper", AccentColor: rgb(acc) },
            "Colors:Window": group(Tok.bg, Tok.surface, Tok.text, Tok.muted),
            "Colors:View": group(Tok.surface, Tok.surfaceHi, Tok.text, Tok.muted),
            "Colors:Button": group(Tok.surfaceHi, Tok.surface, Tok.text, Tok.muted),
            "Colors:Header": group(Tok.bg, Tok.surface, Tok.text, Tok.muted),
            "Colors:Tooltip": group(Tok.surface, Tok.surfaceHi, Tok.text, Tok.muted),
            "Colors:Complementary": group(Tok.bg, Tok.surface, Tok.text, Tok.muted),
            "Colors:Selection": group(acc, mix(acc, Tok.bg, 0.3), on, mix(on, acc, 0.4)),
            "WM": { activeBackground: rgb(Tok.bg), activeForeground: rgb(Tok.text), inactiveBackground: rgb(Tok.bg),
                    inactiveForeground: rgb(Tok.muted), activeBlend: rgb(Tok.bg), inactiveBlend: rgb(Tok.bg) }
        };
        let out = "# Gerado pelas Configurações do NullyzOS (cores do wallpaper): não edite.\n";
        for (const k in g) { out += `\n[${k}]\n`; for (const key in g[k]) out += `${key}=${g[k][key]}\n`; }
        return out;
    }
    function applyWallpaperColors() {
        wallFlip = !wallFlip;
        const name = wallFlip ? "NullyzWallpaperA" : "NullyzWallpaperB";
        run(["sh", "-c", "d=\"${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes\"; mkdir -p \"$d\" && printf '%s' \"$2\" > \"$d/$1.colors\""
                       + " && plasma-apply-colorscheme \"$1\" >/dev/null 2>&1"
                       + " && mkdir -p \"$3\" && echo \"$1\" > \"$3/kde-cores\"",
             "sh", name, colorsText(name), Prefs.dir]);
    }
    // Wallpaper atual do Plasma (arquivo de imagem; pacote de wallpaper → a maior imagem dele)
    property string wallpaperUrl: ""
    function readWallpaper() { wallProc.running = true; }
    Process {
        id: wallProc
        command: ["sh", "-c", "w=$(grep -m1 '^Image=' \"${XDG_CONFIG_HOME:-$HOME/.config}/plasma-org.kde.plasma.desktop-appletsrc\" | cut -d= -f2-);"
                            + " w=${w#file://}; if [ -d \"$w\" ]; then w=$(ls -S \"$w\"/contents/images/* 2>/dev/null | head -n1); fi; echo \"$w\""]
        stdout: StdioCollector { onStreamFinished: { const p = text.trim(); if (p) root.wallpaperUrl = Prefs.url(p); } }
    }

    // Destaque do wallpaper (recurso do próprio Plasma: segue o fundo quando ele troca)
    function setAccentFromWallpaper(on) {
        run(["kwriteconfig6", "--file", "kdeglobals", "--group", "General", "--key", "accentColorFromWallpaper", on ? "true" : "false"]);
    }
    function setGlass(on, light) { run(["plasma-apply-desktoptheme", on ? "NullyzVidro" : (light ? "breeze-light" : "breeze-dark")]); }
    function setAnimations(factor) {
        run(["kwriteconfig6", "--file", "kdeglobals", "--group", "KDE", "--key", "AnimationDurationFactor", String(factor)]);
        kwinReconfigure();
    }
    function setButtonsLeft(left) {
        run(["sh", "-c", "kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft '" + (left ? "XIA" : "M") + "'"
                       + " && kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight '" + (left ? "" : "IAX") + "'"
                       + " && dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure"]);
    }

    Component {
        id: proc
        Process {
            property var done: null
            stdout: StdioCollector { id: col }
            onExited: { if (done) done(col.text); destroy(); }
        }
    }

    Component.onCompleted: if (active) refresh()
}
