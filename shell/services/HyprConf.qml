pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Ajustes do Hyprland feitos pelas Configurações (teclado, mouse, monitores).
// Guarda a escolha em ~/.config/nullyzos/hyprland.json e gera ~/.config/nullyzos/hyprland.lua,
// que a config do sistema carrega antes de ~/.config/hypr/nullyzos.lua (os ajustes à mão do
// usuário continuam valendo por cima). Aplicar = gerar o .lua e `hyprctl reload`.
Singleton {
    id: root

    readonly property string dir: Prefs.dir
    // Campos vazios/zero = deixa o padrão do sistema (o teclado escolhido no instalador etc.).
    readonly property string kbLayout: conf.kbLayout
    readonly property string kbVariant: conf.kbVariant
    readonly property int repeatRate: conf.repeatRate
    readonly property real pointerSpeed: conf.pointerSpeed
    readonly property bool naturalScroll: conf.naturalScroll
    readonly property var monitors: { try { return JSON.parse(conf.monitors || "{}"); } catch (e) { return {}; } }

    function set(key, value) {
        if (conf[key] === value) return;
        conf[key] = value;
        save();
    }
    // Uma regra por monitor: { mode: "1920x1080@60", scale: 1 }
    function setMonitor(name, rule) {
        const m = Object.assign({}, root.monitors);
        m[name] = Object.assign({}, m[name] || {}, rule);
        conf.monitors = JSON.stringify(m);
        save();
    }
    function setMonitors(json) { conf.monitors = json; save(); }

    function lua() {
        const q = s => JSON.stringify(String(s));
        const input = [];
        if (conf.kbLayout) input.push(`kb_layout = ${q(conf.kbLayout)}`, `kb_variant = ${q(conf.kbVariant)}`);
        if (conf.repeatRate > 0) input.push(`repeat_rate = ${Math.round(conf.repeatRate)}`);
        if (conf.pointerSpeed !== 0) input.push(`sensitivity = ${conf.pointerSpeed.toFixed(2)}`);
        input.push(`touchpad = { natural_scroll = ${conf.naturalScroll ? "true" : "false"} }`);
        const out = [
            "-- Gerado pelas Configurações do NullyzOS: não edite (mude pelas Configurações).",
            "-- Ajustes à mão vão em ~/.config/hypr/nullyzos.lua, que é carregado depois deste.",
            `hl.config({ input = { ${input.join(", ")} } })`
        ];
        const mons = root.monitors;
        for (const name in mons) {
            const r = mons[name];
            if (!r.mode && !r.scale) continue;
            out.push(`hl.monitor({ output = ${q(name)}, mode = ${q(r.mode || "preferred")}, position = "auto", scale = ${r.scale || "\"auto\""} })`);
        }
        return out.join("\n") + "\n";
    }

    function save() {
        file.writeAdapter();
        luaFile.setText(lua());
        reloadTimer.restart();
    }
    // Deixa o arquivo chegar ao disco antes de pedir o reload.
    Timer { id: reloadTimer; interval: 150; onTriggered: Quickshell.execDetached(["hyprctl", "reload"]) }

    FileView {
        id: file
        path: root.dir + "/hyprland.json"
        watchChanges: true
        onFileChanged: reload()
        adapter: JsonAdapter {
            id: conf
            property string kbLayout: ""
            property string kbVariant: ""
            property int repeatRate: 0
            property real pointerSpeed: 0
            property bool naturalScroll: true
            property string monitors: "{}"
        }
    }
    FileView { id: luaFile; path: root.dir + "/hyprland.lua" }
}
