pragma Singleton

import QtQuick
import Quickshell

// Estado dos painéis abertos (um só por vez).
Singleton {
    property bool launcher: false
    function toggleLauncher() { launcher = !launcher; }
    function closeAll() { launcher = false; }
}
