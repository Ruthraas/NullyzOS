pragma Singleton

import QtQuick
import Quickshell

// Estado dos painéis abertos (um só por vez).
Singleton {
    property bool launcher: false
    property bool settings: false
    property string settingsPage: "aparencia"
    // Escondidas enquanto uma janela do sistema (ex.: pedido de senha) precisa aparecer.
    property bool settingsAside: false

    function toggleLauncher() { const v = !launcher; closeAll(); launcher = v; }
    function openSettings(page) {
        closeAll();
        if (page) settingsPage = page;
        settings = true;
    }
    function toggleSettings() { if (settings) closeAll(); else openSettings(""); }
    function closeAll() { launcher = false; settings = false; settingsAside = false; }
}
