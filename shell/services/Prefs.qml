pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Preferências do usuário em ~/.config/nullyzos/shell.json. As Configurações (#12) vão escrever
// aqui; sem o arquivo valem os padrões. Mudou o arquivo, o shell aplica na hora.
//   { "dock": true }   -> liga o dock (padrão no Hyprland: desligado)
Singleton {
    id: root

    readonly property bool dock: prefs.dock

    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/nullyzos/shell.json"
        watchChanges: true
        onFileChanged: reload()
        adapter: JsonAdapter {
            id: prefs
            property bool dock: false
        }
    }
}
