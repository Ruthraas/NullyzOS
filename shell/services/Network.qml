pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

// Rede via `nmcli` (NetworkManager): tipo e nome da conexão, sinal do Wi-Fi e o rádio.
// Relê na hora quando o NetworkManager avisa mudança (`nmcli monitor`) e a cada 15 s.
// Wi-Fi: lista de redes (scan), redes já salvas, conectar (com senha) e desconectar.
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

    property bool scanning: false
    property var networks: []          // [{ ssid, signal, secure, active, known }]
    property var known: []             // nomes das conexões Wi-Fi salvas
    property string connecting: ""     // SSID em andamento
    property string lastError: ""

    function refresh() { if (!statusProc.running) statusProc.running = true; }
    function setWifi(on) {
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        root.wifiEnabled = on;
        if (on) scanDelay.restart(); else root.networks = [];
    }
    function scan() {
        if (scanning || !hasWifi) return;
        scanning = true;
        scanProc.running = true;
    }
    // callback(ok, mensagem)
    function connect(ssid, password, callback) {
        root.connecting = ssid;
        root.lastError = "";
        const cmd = root.known.includes(ssid) && !password
            ? ["nmcli", "--wait", "20", "connection", "up", "id", ssid]
            : ["nmcli", "--wait", "20", "device", "wifi", "connect", ssid].concat(password ? ["password", password] : []);
        const p = connectComp.createObject(root, { command: cmd, callback: callback || null });
        p.running = true;
    }
    function disconnect(ssid) {
        Quickshell.execDetached(["nmcli", "connection", "down", "id", ssid]);
    }
    function forget(ssid) {
        Quickshell.execDetached(["nmcli", "connection", "delete", "id", ssid]);
        root.known = root.known.filter(k => k !== ssid);
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
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device; echo '--'; nmcli -t -f ACTIVE,SIGNAL dev wifi 2>/dev/null | grep '^yes' | head -1; echo '--'; nmcli radio wifi; echo '--'; nmcli -t -f NAME,TYPE connection show"]
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
                root.known = (parts[3] || "").split("\n").map(l => root.splitTerse(l))
                    .filter(f => f[1] === "802-11-wireless").map(f => f[0]);
            }
        }
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "auto"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {};
                const list = [];
                for (const line of text.split("\n")) {
                    if (!line) continue;
                    const f = root.splitTerse(line);
                    const ssid = f[1];
                    if (!ssid || seen[ssid]) continue;
                    seen[ssid] = true;
                    list.push({ ssid: ssid, active: f[0] === "*", signal: parseInt(f[2]) || 0,
                                secure: !!f[3] && f[3] !== "--", known: root.known.includes(ssid) });
                }
                list.sort((a, b) => (b.active - a.active) || (b.known - a.known) || (b.signal - a.signal));
                root.networks = list.slice(0, 20);
                root.scanning = false;
            }
        }
        onExited: root.scanning = false
    }

    Component {
        id: connectComp
        Process {
            id: cp
            property var callback
            stderr: StdioCollector { id: err }
            onExited: code => {
                root.connecting = "";
                if (code !== 0) {
                    const msg = err.text.trim();
                    root.lastError = /secret|password|senha|802-1X/i.test(msg) ? "Senha incorreta." : (msg || "Não foi possível conectar.");
                }
                if (cp.callback) cp.callback(code === 0, root.lastError);
                root.refresh();
                scanDelay.restart();
                cp.destroy();
            }
        }
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser { onRead: debounce.restart() }
    }
    Timer { id: debounce; interval: 400; onTriggered: root.refresh() }
    Timer { id: scanDelay; interval: 2500; onTriggered: root.scan() }
    Timer { interval: 15000; running: true; repeat: true; onTriggered: root.refresh() }
    Component.onCompleted: refresh()
}
