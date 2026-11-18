import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Energia (Configurações → Energia): parado por X minutos, bloqueia; por Y, suspende
// (bloqueando antes). 0 = nunca. Respeita quem pede para a tela não apagar (vídeo, chamada).
Scope {
    id: root
    signal lockNow()

    IdleMonitor {
        enabled: Prefs.idleLock > 0
        timeout: Math.max(1, Prefs.idleLock) * 60
        respectInhibitors: true
        onIsIdleChanged: if (isIdle) root.lockNow()
    }
    IdleMonitor {
        enabled: Prefs.idleSuspend > 0
        timeout: Math.max(1, Prefs.idleSuspend) * 60
        respectInhibitors: true
        onIsIdleChanged: if (isIdle) {
            root.lockNow();
            Quickshell.execDetached(["systemctl", "suspend"]);
        }
    }
}
