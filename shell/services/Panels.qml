pragma Singleton

import QtQuick
import Quickshell

// Estado dos painéis abertos (um só por vez).
Singleton {
    id: root
    property bool launcher: false
    property bool quick: false
    property bool calendar: false
    property bool welcome: false
    property bool switcher: false
    property bool overview: false
    property string picker: ""          // "" | clip | emoji
    signal switcherNext()
    property bool settings: false
    property string settingsPage: "aparencia"
    // Escondidas enquanto uma janela do sistema (ex.: pedido de senha) precisa aparecer.
    property bool settingsAside: false

    // Quem tem o bloqueio (shell.qml) escuta e bloqueia.
    signal lockRequested()

    function toggleLauncher() { const v = !launcher; closeAll(); launcher = v; }
    function toggleQuick() { const v = !quick; closeAll(); quick = v; }
    function toggleCalendar() { const v = !calendar; closeAll(); calendar = v; }
    function openSettings(page) {
        closeAll();
        if (page) settingsPage = page;
        settings = true;
    }
    function toggleSettings() { if (settings) closeAll(); else openSettings(""); }
    function toggleSwitcher() {
        if (switcher) { switcherNext(); return; }
        closeAll(); switcher = true;
    }
    function toggleOverview() { const v = !overview; closeAll(); overview = v; }
    function togglePicker(mode) { const v = picker === mode ? "" : mode; closeAll(); picker = v; }
    function closeAll() {
        launcher = false; quick = false; calendar = false; settings = false; settingsAside = false;
        switcher = false; overview = false; picker = "";
    }
}
