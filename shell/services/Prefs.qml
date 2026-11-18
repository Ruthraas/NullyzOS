pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Preferências do usuário em ~/.config/nullyzos/shell.json, escritas pelas Configurações.
// Sem o arquivo, o shell cria um com os padrões (assim dá para vigiar desde o começo);
// mudou o arquivo (pelas Configurações ou à mão), aplica na hora.
//   dock           mostra o dock (padrão no Hyprland: desligado)
//   wallpaper      caminho da imagem de fundo ("" = fundo padrão do Nullyz)
//   lockWallpaper  fundo da tela de bloqueio: "padrao" ou "desktop" (o mesmo da área de trabalho)
//   lockDim        escurece o fundo do bloqueio para o relógio e a senha ficarem legíveis
Singleton {
    id: root

    readonly property string defaultWallpaper: "/usr/share/nullyzos/wallpapers/padrao.png"
    readonly property string dir: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/nullyzos"

    readonly property bool dock: prefs.dock
    readonly property string wallpaper: prefs.wallpaper
    readonly property string lockWallpaper: prefs.lockWallpaper
    readonly property bool lockDim: prefs.lockDim

    readonly property string wallpaperUrl: url(prefs.wallpaper || defaultWallpaper)
    readonly property string lockUrl: prefs.lockWallpaper === "desktop" ? wallpaperUrl : url(defaultWallpaper)

    // Caminho → URL de arquivo (espaços, acentos e # no nome não quebram a imagem).
    function url(path) { return "file://" + path.split("/").map(encodeURIComponent).join("/"); }

    function set(key, value) {
        if (prefs[key] === value) return;
        prefs[key] = value;
        file.writeAdapter();
    }

    FileView {
        id: file
        path: root.dir + "/shell.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => { if (err === FileViewError.FileNotFound) mkdir.running = true; }
        adapter: JsonAdapter {
            id: prefs
            property bool dock: false
            property string wallpaper: ""
            property string lockWallpaper: "padrao"
            property bool lockDim: true
        }
    }

    Process {
        id: mkdir
        command: ["mkdir", "-p", root.dir]
        onExited: file.writeAdapter()
    }
}
