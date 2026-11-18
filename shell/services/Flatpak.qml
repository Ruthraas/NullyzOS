pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Loja de apps (Flathub) para Configurações → Apps. Tudo no usuário (--user): instalar e
// remover não pedem senha. Liga o Flathub do usuário na primeira vez.
Singleton {
    id: root

    property var installed: []          // [{ id, name }]
    property var results: []            // [{ id, name, desc }]
    property bool searching: false
    property string busy: ""            // id em instalação/remoção
    property string progress: ""        // última linha do flatpak
    property string error: ""
    readonly property bool available: true

    function has(id) { return root.installed.some(a => a.id === id); }
    function refresh() { if (!listProc.running) listProc.running = true; }
    function search(q) {
        q = String(q || "").trim();
        if (q.length < 2) { root.results = []; return; }
        root.searching = true;
        searchProc.command = ["flatpak", "search", "--columns=application,name,description", q];
        searchProc.running = true;
    }
    function install(id) {
        if (busy) return;
        busy = id; progress = ""; error = "";
        job.command = ["sh", "-c", "flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && flatpak install --user -y --noninteractive flathub \"$1\"", "sh", id];
        job.running = true;
    }
    function remove(id) {
        if (busy) return;
        busy = id; progress = ""; error = "";
        job.command = ["flatpak", "uninstall", "--user", "-y", "--noninteractive", id];
        job.running = true;
    }

    Process {
        id: listProc
        running: true
        command: ["flatpak", "list", "--app", "--columns=application,name"]
        stdout: StdioCollector {
            onStreamFinished: root.installed = text.split("\n").filter(l => l).map(l => {
                const f = l.split("\t");
                return { id: f[0], name: f[1] || f[0] };
            })
        }
    }
    Process {
        id: searchProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.results = text.split("\n").filter(l => l && l.indexOf("\t") > 0).slice(0, 20).map(l => {
                    const f = l.split("\t");
                    return { id: f[0], name: f[1] || f[0], desc: f[2] || "" };
                });
                root.searching = false;
            }
        }
        onExited: root.searching = false
    }
    Process {
        id: job
        stdout: SplitParser { onRead: line => root.progress = line.trim() }
        stderr: SplitParser { onRead: line => { if (line.trim()) root.error = line.trim(); } }
        onExited: code => {
            if (code === 0) root.error = "";
            root.busy = "";
            root.progress = "";
            root.refresh();
        }
    }
}
