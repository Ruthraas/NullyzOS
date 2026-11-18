pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

// Rede via `nmcli` (NetworkManager): tipo e nome da conexão, sinal do Wi-Fi e o rádio.
// Relê na hora quando o NetworkManager avisa mudança (`nmcli monitor`) e a cada 15 s.
Singleton {
    id: root

    property string type: "none"       // wifi | ethernet | none
    property string name: ""
    property int signal: 0             // 0..100 (wifi)
    property bool wifiEnabled: true
    property bool hasWifi: false
    readonly property bool connected: type !== "none"
    readonly property string icon: type === "ethernet" ? Icons.ethernet
        : type === "wifi" ? Icons.wifiLevels[Math.min(3, Math.floor(signal / 25))] : Icons.wifiOff
    readonly property string label: type === "none" ? "Sem conexão" : type === "ethernet" ? "Cabo de rede" : name

    function refresh() { if (!statusProc.running) statusProc.running = true; }
    function setWifi(on) {
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        root.wifiEnabled = on;
    }

    // nmcli -t separa campos com ":" e escapa ":" dentro do valor como "\:".
    function splitTerse(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) { cur += line[++i]; continue; }
            if (c === ":") { out.push(cur); cur = ""; continue; }
            cur += c;
        }
        out.push(cur);
        return out;
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device; echo '--'; nmcli -t -f ACTIVE,SIGNAL dev wifi 2>/dev/null | grep '^yes' | head -1; echo '--'; nmcli radio wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("--\n");
                let t = "none", n = "", anyWifi = false;
                for (const line of (parts[0] || "").split("\n")) {
                    const f = root.splitTerse(line);
                    if (f[0] === "wifi") anyWifi = true;
                    if (f[1] !== "connected") continue;
                    if (f[0] === "ethernet") { t = "ethernet"; n = f[2]; break; }
                    if (f[0] === "wifi" && t === "none") { t = "wifi"; n = f[2]; }
                }
                root.type = t;
                root.name = n;
                root.hasWifi = anyWifi;
                const sig = parseInt(root.splitTerse((parts[1] || "").trim())[1] || "0");
                root.signal = isNaN(sig) ? 0 : sig;
                root.wifiEnabled = (parts[2] || "").trim() === "enabled";
            }
        }
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser { onRead: debounce.restart() }
    }
    Timer { id: debounce; interval: 400; onTriggered: root.refresh() }
    Timer { interval: 15000; running: true; repeat: true; onTriggered: root.refresh() }
    Component.onCompleted: refresh()
}
