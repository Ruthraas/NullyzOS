pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Luz noturna: tela mais quente (hyprsunset). Ligada à mão ou no horário (19h às 7h).
// O processo roda enquanto está ativa; desligar encerra e a cor volta ao normal.
Singleton {
    id: root

    readonly property bool scheduled: Prefs.nightAuto && (Clock.now.getHours() >= 19 || Clock.now.getHours() < 7)
    readonly property bool active: Prefs.nightLight || scheduled
    readonly property int temperature: Prefs.nightTemp

    function toggle() {
        // Com o horário ligado e dentro dele, o botão desliga o horário (senão não apagaria)
        if (scheduled) Prefs.set("nightAuto", false);
        else Prefs.set("nightLight", !Prefs.nightLight);
    }

    Process {
        running: root.active
        command: ["hyprsunset", "-t", String(root.temperature)]
    }
}
