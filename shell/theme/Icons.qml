pragma Singleton

import QtQuick
import Quickshell

// Desenhos dos ícones (caminhos SVG 24×24, traço), usados com components/Ico.
Singleton {
    readonly property var wifiLevels: [
        "M12 19.5h.01",
        "M8.5 16a5 5 0 0 1 7 0 M12 19.5h.01",
        "M5.5 12.5a9.5 9.5 0 0 1 13 0 M8.5 16a5 5 0 0 1 7 0 M12 19.5h.01",
        "M2.5 9a14 14 0 0 1 19 0 M5.5 12.5a9.5 9.5 0 0 1 13 0 M8.5 16a5 5 0 0 1 7 0 M12 19.5h.01"
    ]
    readonly property string wifi: wifiLevels[3]
    readonly property string wifiOff: "M3 3l18 18 M8.5 16a5 5 0 0 1 7 0 M12 19.5h.01 M5.5 12.5a9.5 9.5 0 0 1 4.2-2.4 M2.5 9a14 14 0 0 1 5.2-3.1 M14.5 10.2a9.5 9.5 0 0 1 4 2.3 M12 5a14 14 0 0 1 9.5 4"
    readonly property string ethernet: "M7 4h10v5h3v8H4V9h3z M9 13v1.5 M12 13v1.5 M15 13v1.5"
    readonly property string speaker: "M4 9.5h3.5L12 5.5v13l-4.5-4H4z"
    readonly property string volumeLow: speaker + " M15.5 9.5a3.5 3.5 0 0 1 0 5"
    readonly property string volumeHigh: speaker + " M15.5 9.5a3.5 3.5 0 0 1 0 5 M18.5 6.5a8 8 0 0 1 0 11"
    readonly property string volumeOff: speaker + " M16 9.5l5 5 M21 9.5l-5 5"
    readonly property string sun: "M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8z M12 2.5v2 M12 19.5v2 M2.5 12h2 M19.5 12h2 M5.3 5.3l1.4 1.4 M17.3 17.3l1.4 1.4 M5.3 18.7l1.4-1.4 M17.3 6.7l1.4-1.4"
    readonly property string battery: "M4 7.5h14a1.5 1.5 0 0 1 1.5 1.5v6a1.5 1.5 0 0 1-1.5 1.5H4A1.5 1.5 0 0 1 2.5 15V9A1.5 1.5 0 0 1 4 7.5z M22 10.5v3"
    readonly property string bolt: "M12.5 3L5 13.5h6L10.5 21 18 10.5h-6z"
    readonly property string gear: "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M19.4 13a7.5 7.5 0 0 0 0-2l2-1.6-2-3.4-2.4 1a7.5 7.5 0 0 0-1.7-1L15 3.5h-4l-.4 2.5a7.5 7.5 0 0 0-1.7 1l-2.4-1-2 3.4 2 1.6a7.5 7.5 0 0 0 0 2l-2 1.6 2 3.4 2.4-1a7.5 7.5 0 0 0 1.7 1l.4 2.5h4l.4-2.5a7.5 7.5 0 0 0 1.7-1l2.4 1 2-3.4z"
    readonly property string lock: "M7 11h10a1.5 1.5 0 0 1 1.5 1.5v6A1.5 1.5 0 0 1 17 20H7a1.5 1.5 0 0 1-1.5-1.5v-6A1.5 1.5 0 0 1 7 11z M8.5 11V8a3.5 3.5 0 0 1 7 0v3"
    readonly property string moon: "M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z"
    readonly property string restart: "M20 12a8 8 0 1 1-2.3-5.7 M20 4v4h-4"
    readonly property string power: "M12 3v8 M7 6.5a7.5 7.5 0 1 0 10 0"
    readonly property string keyboard: "M3.5 6.5h17a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1h-17a1 1 0 0 1-1-1v-9a1 1 0 0 1 1-1z M7 10h.01 M10 10h.01 M13 10h.01 M16 10h.01 M8 14h8"
    readonly property string monitor: "M3.5 4.5h17a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1h-17a1 1 0 0 1-1-1v-10a1 1 0 0 1 1-1z M9 20h6 M12 16.5V20"
    readonly property string palette: "M12 3a9 9 0 1 0 0 18c1.2 0 1.6-1 1.2-1.8-.5-1.1.3-2.2 1.5-2.2H17a4 4 0 0 0 4-4c0-5.5-4-10-9-10z M7.5 12h.01 M9.5 7.5h.01 M14.5 7.5h.01"
    readonly property string bar: "M3.5 4.5h17a1 1 0 0 1 1 1v13a1 1 0 0 1-1 1h-17a1 1 0 0 1-1-1v-13a1 1 0 0 1 1-1z M2.5 8h19 M8 16.5h8"
    readonly property string windows: "M4 4.5h7v7H4z M13 4.5h7v15h-7z M4 13.5h7v6H4z"
    readonly property string command: "M9 6a3 3 0 1 0-3 3h12a3 3 0 1 0-3-3v12a3 3 0 1 0 3-3H6a3 3 0 1 0 3 3z"
    readonly property string info: "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z M12 11v5 M12 7.8h.01"
    readonly property string gauge: "M4.5 17a8.5 8.5 0 1 1 15 0 M12 13.5l3.5-4.5 M12 13.5h.01"
    readonly property string logout: "M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3 M10 8l-4 4 4 4 M6 12h10"
}
