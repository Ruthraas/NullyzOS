pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Preferências do usuário em ~/.config/nullyzos/shell.json. As Configurações (#12) vão escrever
// aqui. Sem o arquivo, o shell cria um com os padrões (assim dá para vigiar desde o começo);
// mudou o arquivo, aplica na hora.
//   { "dock": true }   -> liga o dock (padrão no Hyprland: desligado)
Singleton {
    id: root

    readonly property bool dock: prefs.dock
    readonly property string dir: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/nullyzos"

    FileView {
        id: file
        path: root.dir + "/shell.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => { if (err === FileViewError.FileNotFound) mkdir.running = true; }
        adapter: JsonAdapter {
            id: prefs
            property bool dock: false
        }
    }

    Process {
        id: mkdir
        command: ["mkdir", "-p", root.dir]
        onExited: file.writeAdapter()
    }
}
