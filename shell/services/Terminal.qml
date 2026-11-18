pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

// Terminal (kitty) do NullyzOS. Guarda as escolhas em ~/.config/nullyzos/terminal.json e gera:
//   ~/.config/nullyzos/kitty.conf   (incluído no fim de /etc/xdg/kitty/kitty.conf): cores do
//                                   tema e do destaque, fonte, transparência, cursor, margem
//   ~/.config/nullyzos/terminal.sh  (lido pelo bash do terminal): prompt, saudação, destaque
// Aplicar = gerar os dois e mandar USR1 ao kitty (recarrega a config sem fechar nada).
Singleton {
    id: root

    readonly property real fontSize: conf.fontSize
    readonly property string fontFamily: conf.fontFamily
    readonly property real opacity: conf.opacity
    readonly property string cursor: conf.cursor          // beam | block | underline
    readonly property int padding: conf.padding
    readonly property bool prompt: conf.prompt
    readonly property string greeting: conf.greeting      // sempre | sessao | nunca

    function set(key, value) {
        if (conf[key] === value) return;
        conf[key] = value;
        save();
    }

    function hex(c) { return String(c).replace("#", ""); }
    function kitty() {
        const L = Tok.light;
        const e = Tok.accents[Tok.accentName] || Tok.accents.violeta;
        const acc = L ? e.light : e.color;
        const p = L ? Tok.palettes.claro : Tok.palettes.escuro;
        const ansi = L ? Tok.ansiLight : Tok.ansiDark;
        const out = [
            "# Gerado pelas Configurações do NullyzOS (Terminal): não edite, mude por lá.",
            `font_family ${conf.fontFamily}`,
            `font_size ${conf.fontSize}`,
            `background_opacity ${conf.opacity}`,
            `cursor_shape ${conf.cursor}`,
            `window_padding_width ${conf.padding} ${conf.padding + 4}`,
            `foreground ${p.text}`, `background ${p.bg}`,
            `selection_foreground ${L ? p.surface : p.bg}`, `selection_background ${acc}`,
            `cursor ${acc}`, `cursor_text_color ${p.bg}`, `url_color ${acc}`,
            `active_border_color ${acc}`, `inactive_border_color ${p.border}`,
            `active_tab_foreground ${L ? p.surface : p.bg}`, `active_tab_background ${acc}`,
            `inactive_tab_foreground ${p.muted}`, `inactive_tab_background ${p.surface}`, `tab_bar_background ${p.bg}`
        ];
        ansi.forEach((c, i) => out.push(`color${i} ${c}`));
        return out.join("\n") + "\n";
    }
    function shell() {
        const e = Tok.accents[Tok.accentName] || Tok.accents.violeta;
        return "# Gerado pelas Configurações do NullyzOS (Terminal): não edite, mude por lá.\n"
            + `NULLYZ_PROMPT=${conf.prompt ? 1 : 0}\n`
            + `NULLYZ_GREETING=${conf.greeting}\n`
            + `NULLYZ_ACCENT=${hex(Tok.light ? e.light : e.color)}\n`;
    }

    function save() {
        file.writeAdapter();
        kittyFile.setText(kitty());
        shFile.setText(shell());
        reloadTimer.restart();
    }
    Timer { id: reloadTimer; interval: 150; onTriggered: Quickshell.execDetached(["pkill", "-USR1", "-x", "kitty"]) }

    FileView {
        id: file
        path: Prefs.dir + "/terminal.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => { if (err === FileViewError.FileNotFound) root.save(); }
        adapter: JsonAdapter {
            id: conf
            property real fontSize: 11.5
            property string fontFamily: "Geist Mono"
            property real opacity: 0.94
            property string cursor: "beam"
            property int padding: 12
            property bool prompt: true
            property string greeting: "sempre"
        }
    }
    FileView { id: kittyFile; path: Prefs.dir + "/kitty.conf" }
    FileView { id: shFile; path: Prefs.dir + "/terminal.sh" }
}
