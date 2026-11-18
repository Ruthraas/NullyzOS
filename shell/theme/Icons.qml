pragma Singleton

import QtQuick
import Quickshell

// Ícones do shell: Lucide 0.460.0 (https://lucide.dev, licença ISC; ver CREDITS.md),
// convertidos para um caminho SVG único por ícone (traço 24x24) por scripts/lucide-icons.py.
// Não edite à mão: rode o script de novo.
Singleton {
    readonly property var wifiLevels: [
        "M12 20h.01",
        "M12 20h.01 M8.5 16.429a5 5 0 0 1 7 0",
        "M12 20h.01 M5 12.859a10 10 0 0 1 14 0 M8.5 16.429a5 5 0 0 1 7 0",
        "M12 20h.01 M2 8.82a15 15 0 0 1 20 0 M5 12.859a10 10 0 0 1 14 0 M8.5 16.429a5 5 0 0 1 7 0"
    ]
    readonly property string palette: "M13.5 6.5h.01 M17.5 10.5h.01 M8.5 7.5h.01 M6.5 12.5h.01 M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z"
    readonly property string lock: "M5 11h14a2 2 0 0 1 2 2v7a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-7a2 2 0 0 1 2 -2Z M7 11V7a5 5 0 0 1 10 0v4"
    readonly property string bar: "M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2Z M3 9h18"
    readonly property string dock: "M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2Z M3 15h18"
    readonly property string windows: "M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1 -2 2h-16a2 2 0 0 1 -2 -2v-12a2 2 0 0 1 2 -2Z M10 4v4 M2 8h20 M6 4v4"
    readonly property string apps: "M4 3h5a1 1 0 0 1 1 1v5a1 1 0 0 1 -1 1h-5a1 1 0 0 1 -1 -1v-5a1 1 0 0 1 1 -1Z M15 3h5a1 1 0 0 1 1 1v5a1 1 0 0 1 -1 1h-5a1 1 0 0 1 -1 -1v-5a1 1 0 0 1 1 -1Z M15 14h5a1 1 0 0 1 1 1v5a1 1 0 0 1 -1 1h-5a1 1 0 0 1 -1 -1v-5a1 1 0 0 1 1 -1Z M4 14h5a1 1 0 0 1 1 1v5a1 1 0 0 1 -1 1h-5a1 1 0 0 1 -1 -1v-5a1 1 0 0 1 1 -1Z"
    readonly property string type: "M4 7L4 4L20 4L20 7 M9 20L15 20 M12 4L12 20"
    readonly property string terminal: "M7 11 l2-2-2-2 M11 13h4 M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2Z"
    readonly property string wifi: "M12 20h.01 M2 8.82a15 15 0 0 1 20 0 M5 12.859a10 10 0 0 1 14 0 M8.5 16.429a5 5 0 0 1 7 0"
    readonly property string wifiOff: "M12 20h.01 M8.5 16.429a5 5 0 0 1 7 0 M5 12.859a10 10 0 0 1 5.17-2.69 M19 12.859a10 10 0 0 0-2.007-1.523 M2 8.82a15 15 0 0 1 4.177-2.643 M22 8.82a15 15 0 0 0-11.288-3.764 M2 2 l20 20"
    readonly property string ethernet: "M15 20 l3-3h2a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h2l3 3z M6 8v1 M10 8v1 M14 8v1 M18 8v1"
    readonly property string bluetooth: "M7 7 l10 10-5 5V2l5 5L7 17"
    readonly property string printer: "M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2 M6 9V3a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v6 M7 14h10a1 1 0 0 1 1 1v6a1 1 0 0 1 -1 1h-10a1 1 0 0 1 -1 -1v-6a1 1 0 0 1 1 -1Z"
    readonly property string volumeOff: "M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z M22 9L16 15 M16 9L22 15"
    readonly property string speaker: "M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z"
    readonly property string volumeLow: "M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z M16 9a5 5 0 0 1 0 6"
    readonly property string volumeHigh: "M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z M16 9a5 5 0 0 1 0 6 M19.364 18.364a9 9 0 0 0 0-12.728"
    readonly property string keyboard: "M10 8h.01 M12 12h.01 M14 8h.01 M16 12h.01 M18 8h.01 M6 8h.01 M7 16h10 M8 12h.01 M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1 -2 2h-16a2 2 0 0 1 -2 -2v-12a2 2 0 0 1 2 -2Z"
    readonly property string monitor: "M4 3h16a2 2 0 0 1 2 2v10a2 2 0 0 1 -2 2h-16a2 2 0 0 1 -2 -2v-10a2 2 0 0 1 2 -2Z M8 21L16 21 M12 17L12 21"
    readonly property string bolt: "M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"
    readonly property string gauge: "M12 14 l4-4 M3.34 19a10 10 0 1 1 17.32 0"
    readonly property string clock: "M2 12a10 10 0 1 0 20 0a10 10 0 1 0 -20 0 M12 6L12 12L16 14"
    readonly property string globe: "M2 12a10 10 0 1 0 20 0a10 10 0 1 0 -20 0 M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20 M2 12h20"
    readonly property string bell: "M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9 M10.3 21a1.94 1.94 0 0 0 3.4 0"
    readonly property string bellOff: "M8.7 3A6 6 0 0 1 18 8a21.3 21.3 0 0 0 .6 5 M17 17H3s3-2 3-9a4.67 4.67 0 0 1 .3-1.7 M10.3 21a1.94 1.94 0 0 0 3.4 0 M2 2 l20 20"
    readonly property string disk: "M22 12L2 12 M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z M6 16L6.01 16 M10 16L10.01 16"
    readonly property string user: "M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2 M8 7a4 4 0 1 0 8 0a4 4 0 1 0 -8 0"
    readonly property string rocket: "M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z M12 15 l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0 M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"
    readonly property string download: "M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4 M7 10L12 15L17 10 M12 15L12 3"
    readonly property string command: "M15 6v12a3 3 0 1 0 3-3H6a3 3 0 1 0 3 3V6a3 3 0 1 0-3 3h12a3 3 0 1 0-3-3"
    readonly property string info: "M2 12a10 10 0 1 0 20 0a10 10 0 1 0 -20 0 M12 16v-4 M12 8h.01"
    readonly property string search: "M3 11a8 8 0 1 0 16 0a8 8 0 1 0 -16 0 M21 21 l-4.3-4.3"
    readonly property string sun: "M8 12a4 4 0 1 0 8 0a4 4 0 1 0 -8 0 M12 2v2 M12 20v2 M4.93 4.93 l1.41 1.41 M17.66 17.66 l1.41 1.41 M2 12h2 M20 12h2 M6.34 17.66 l-1.41 1.41 M19.07 4.93 l-1.41 1.41"
    readonly property string moon: "M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"
    readonly property string power: "M12 2v10 M18.4 6.6a9 9 0 1 1-12.77.04"
    readonly property string restart: "M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8 M21 3v5h-5"
    readonly property string refresh: "M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8 M21 3v5h-5 M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16 M8 16H3v5"
    readonly property string logout: "M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4 M16 17L21 12L16 7 M21 12L9 12"
    readonly property string gear: "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z M9 12a3 3 0 1 0 6 0a3 3 0 1 0 -6 0"
    readonly property string check: "M20 6 9 17l-5-5"
    readonly property string close: "M18 6 6 18 M6 6 l12 12"
    readonly property string plus: "M5 12h14 M12 5v14"
    readonly property string play: "M6 3L20 12L6 21L6 3Z"
    readonly property string pause: "M15 4h2a1 1 0 0 1 1 1v14a1 1 0 0 1 -1 1h-2a1 1 0 0 1 -1 -1v-14a1 1 0 0 1 1 -1Z M7 4h2a1 1 0 0 1 1 1v14a1 1 0 0 1 -1 1h-2a1 1 0 0 1 -1 -1v-14a1 1 0 0 1 1 -1Z"
    readonly property string next: "M5 4L15 12L5 20L5 4Z M19 5L19 19"
    readonly property string prev: "M19 20L9 12L19 4L19 20Z M5 19L5 5"
    readonly property string battery: "M4 7h12a2 2 0 0 1 2 2v6a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2v-6a2 2 0 0 1 2 -2Z M22 11L22 13"
    readonly property string chevronLeft: "M15 18 l-6-6 6-6"
    readonly property string chevronRight: "M9 18 l6-6-6-6"
    readonly property string sparkles: "M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z M20 3v4 M22 5h-4 M4 17v2 M5 18H3"
    readonly property string image: "M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2Z M7 9a2 2 0 1 0 4 0a2 2 0 1 0 -4 0 M21 15 l-3.086-3.086a2 2 0 0 0-2.828 0L6 21"
}
