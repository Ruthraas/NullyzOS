pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Atualizações: confere sozinho (2 min depois do login e a cada 2 h) com scripts/atualizacoes.sh
// (checkupdates, sem senha). Atualizar = /usr/lib/nullyzos/atualizar via pkexec, com a saída
// ao vivo em `log`. Snapshots do snapper para a página Atualizações.
Singleton {
    id: root

    property var packages: []          // [{ name, from, to }]
    property var flatpaks: []          // [{ id, name }]
    property var snapshots: []         // [{ n, date, desc }]
    readonly property int count: packages.length + flatpaks.length
    property bool checking: false
    property date lastCheck
    property bool updating: false
    property var log: []
    property int result: -1            // -1 nada ainda, 0 deu certo, outro: erro
    property bool needsReboot: false

    readonly property string script: Qt.resolvedUrl("../scripts/atualizacoes.sh").toString().replace("file://", "")

    function check(withSnapshots) {
        if (checking || updating) return;
        checking = true;
        query.command = ["sh", root.script].concat(withSnapshots ? ["--snapshots"] : []);
        query.running = true;
    }
    function update() {
        if (checking || updating) return;
        updating = true;
        result = -1;
        needsReboot = false;
        log = [];
        Panels.settingsAside = true;            // o pedido de senha aparece por cima
        job.running = true;
    }

    Process {
        id: query
        stdout: StdioCollector {
            onStreamFinished: {
                const pk = [], fl = [], sn = [];
                for (const line of text.split("\n")) {
                    const f = line.split(" ");
                    if (f[0] === "pac") pk.push({ name: f[1], from: f[2], to: f[3] });
                    else if (f[0] === "flat") fl.push({ id: f[1], name: f.slice(2).join(" ") || f[1] });
                    else if (f[0] === "snap") {
                        const rest = f.slice(2).join(" ").split("|");
                        sn.push({ n: f[1], date: rest[0] || "", desc: rest[1] || "" });
                    }
                }
                root.packages = pk;
                root.flatpaks = fl;
                if (sn.length) root.snapshots = sn.reverse();
                root.lastCheck = new Date();
                root.checking = false;
            }
        }
    }

    Process {
        id: job
        command: ["pkexec", "/usr/lib/nullyzos/atualizar"]
        stdout: SplitParser {
            onRead: line => {
                if (Panels.settingsAside) Panels.settingsAside = false;   // senha aceita: volta
                if (line === ":: Reinicie para usar o kernel novo") root.needsReboot = true;
                root.log = root.log.concat([line]).slice(-200);
            }
        }
        stderr: SplitParser { onRead: line => root.log = root.log.concat([line]).slice(-200) }
        onExited: code => {
            Panels.settingsAside = false;
            root.updating = false;
            root.result = code;
            root.check(true);
        }
    }

    Timer { interval: 120000; running: true; onTriggered: root.check(false) }
    Timer { interval: 7200000; running: true; repeat: true; onTriggered: root.check(false) }
}
