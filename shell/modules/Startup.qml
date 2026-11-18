import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Apps ao iniciar (Configurações → Apps ao iniciar): abre cada um uma vez por sessão. Uma
// marca em $XDG_RUNTIME_DIR evita abrir de novo quando o shell reinicia na mesma sessão.
Scope {
    Process {
        running: true
        command: ["sh", "-c", "f=\"${XDG_RUNTIME_DIR:-/tmp}/nullyzos-iniciou\"; [ -e \"$f\" ] || { : > \"$f\"; echo abrir; }"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "abrir") return;
                for (const id of Prefs.startupApps) {
                    const e = Apps.byId(id);
                    if (e) e.execute();
                }
            }
        }
    }
}
