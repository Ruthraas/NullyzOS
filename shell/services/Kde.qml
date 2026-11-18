pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

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
