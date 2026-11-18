pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

// Terminal (kitty) do NullyzOS. Guarda as escolhas em ~/.config/nullyzos/terminal.json e gera:
//   ~/.config/nullyzos/kitty.conf   (incluído no fim de /etc/xdg/kitty/kitty.conf): cores do
//                                   tema e do destaque, fonte, transparência, cursor, margem
//   ~/.config/nullyzos/terminal.sh  (lido pelo bash do terminal): prompt, saudação, destaque
//   ~/.config/nullyzos/fastfetch.jsonc  (saudação completa e o comando `fastfetch`): logo do N
//                                   (buraco negro ou o N em binário, pixel, blocos), na cor de destaque
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
    readonly property string greetStyle: conf.greetStyle  // fastfetch | simples
    readonly property string logo: conf.logo              // buraco | binario | pixel | blocos
    readonly property var infoKeys: conf.info.split(",").filter(x => x)
    function toggleInfo(key) {
        const l = root.infoKeys.includes(key) ? root.infoKeys.filter(k => k !== key) : root.infoKeys.concat([key]);
        set("info", l.join(","));
    }

    function set(key, value) {
        if (conf[key] === value) return;
        conf[key] = value;
        save();
    }

    function hex(c) { return String(c).replace("#", ""); }
    function kitty() {
        const L = Tok.light;
        const e = Tok.accentEntry;
        const acc = L ? e.light : e.color;
        const p = Tok.pal;
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
    // "9d8cff" → "38;2;157;140;255" (cor do fastfetch)
    function ansi(hex6) {
        const h = hex(hex6);
        return `38;2;${parseInt(h.slice(0, 2), 16)};${parseInt(h.slice(2, 4), 16)};${parseInt(h.slice(4, 6), 16)}`;
    }
    // Linhas que dá para ligar/desligar na saudação completa: [chave, rótulo, módulo]
    readonly property var infoOptions: [
        ["sistema", "Sistema", { type: "os", key: "sistema" }],
        ["kernel", "Kernel", { type: "kernel", key: "kernel" }],
        ["ligado", "Tempo ligado", { type: "uptime", key: "ligado" }],
        ["pacotes", "Pacotes", { type: "packages", key: "pacotes" }],
        ["janelas", "Janelas", { type: "wm", key: "janelas" }],
        ["terminal", "Terminal", { type: "terminal", key: "terminal" }],
        ["shell", "Shell", { type: "shell", key: "shell" }],
        ["processador", "Processador", { type: "cpu", key: "processador" }],
        ["video", "Vídeo", { type: "gpu", key: "vídeo" }],
        ["memoria", "Memória", { type: "memory", key: "memória" }],
        ["disco", "Disco", { type: "disk", key: "disco", folders: "/" }],
        ["tela", "Tela", { type: "display", key: "tela" }],
        ["cores", "Paleta de cores", null]
    ]
    function fastfetch() {
        const e = Tok.accentEntry;
        const acc = ansi(Tok.light ? e.light : e.color);
        const dim = ansi(Tok.light ? Tok.pal.border : Tok.ansiDark[8]);
        const keys = root.infoKeys;
        const mods = [{ type: "title", format: "{user-name}@{host-name}" }, { type: "separator", string: "─" }];
        for (const o of root.infoOptions) if (o[2] && keys.includes(o[0])) mods.push(o[2]);
        if (keys.includes("cores")) { mods.push("break"); mods.push({ type: "colors", symbol: "circle" }); }
        return "// Gerado pelas Configurações do NullyzOS (Terminal): não edite, mude por lá.\n" + JSON.stringify({
            logo: {
                type: "file",
                source: `/usr/share/nullyzos/terminal/logo-${conf.logo}.txt`,
                color: { "1": acc, "2": dim },
                padding: { top: 0, left: 2, right: 4 }
            },
            display: { separator: "  ", color: { keys: acc, title: acc }, key: { width: 13 } },
            modules: mods
        }, null, 2) + "\n";
    }
    function shell() {
        const e = Tok.accentEntry;
        return "# Gerado pelas Configurações do NullyzOS (Terminal): não edite, mude por lá.\n"
            + `NULLYZ_PROMPT=${conf.prompt ? 1 : 0}\n`
            + `NULLYZ_GREETING=${conf.greeting}\n`
            + `NULLYZ_GREET_STYLE=${conf.greetStyle}\n`
            + `NULLYZ_LOGO=${conf.logo}\n`
            + `NULLYZ_DIM=${hex(Tok.light ? Tok.pal.border : Tok.ansiDark[8])}\n`
            + `NULLYZ_ACCENT=${hex(Tok.light ? e.light : e.color)}\n`;
    }

    function write() {
        kittyFile.setText(kitty());
        shFile.setText(shell());
        ffFile.setText(fastfetch());
    }
    function save() {
        file.writeAdapter();
        write();
        reloadTimer.restart();
    }
    Timer { id: reloadTimer; interval: 150; onTriggered: Quickshell.execDetached(["pkill", "-USR1", "-x", "kitty"]) }

    FileView {
        id: file
        path: Prefs.dir + "/terminal.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => { if (err === FileViewError.FileNotFound) root.save(); }
        // Ao subir: regera os arquivos (versão nova do shell pode ter coisa nova, como o
        // fastfetch; o tema pode ter mudado com o shell desligado). Sem recarregar o kitty.
        onLoaded: Qt.callLater(root.write)
        adapter: JsonAdapter {
            id: conf
            property real fontSize: 11.5
            property string fontFamily: "Geist Mono"
            property real opacity: 0.94
            property string cursor: "beam"
            property int padding: 12
            property bool prompt: true
            property string greeting: "sempre"
            property string greetStyle: "fastfetch"
            property string logo: "binario"
            property string info: "sistema,kernel,ligado,pacotes,janelas,terminal,processador,video,memoria,disco,cores"
        }
    }
    FileView { id: kittyFile; path: Prefs.dir + "/kitty.conf" }
    FileView { id: shFile; path: Prefs.dir + "/terminal.sh" }
    FileView { id: ffFile; path: Prefs.dir + "/fastfetch.jsonc" }
}
