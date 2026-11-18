pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Brilho da tela via `brightnessctl`. Sem luz de fundo controlável (desktop, VM),
// `available` é falso e o painel rápido esconde o controle.
Singleton {
    id: root

    property bool available: false
    property real value: 0          // 0..1

    function set(v) {
        const pct = Math.round(Math.max(0.01, Math.min(1, v)) * 100);
        root.value = pct / 100;
        Quickshell.execDetached(["brightnessctl", "-q", "set", pct + "%"]);
    }
    function refresh() { if (!proc.running) proc.running = true; }

    Process {
        id: proc
        // Saída: dispositivo,classe,atual,porcentagem%,máximo
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                const pct = parseInt((f[3] || "").replace("%", ""));
                root.available = f.length >= 4 && !isNaN(pct);
                root.value = root.available ? pct / 100 : 0;
            }
        }
    }

    Component.onCompleted: refresh()
}
