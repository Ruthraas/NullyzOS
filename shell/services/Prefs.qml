pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

// Preferências do usuário em ~/.config/nullyzos/shell.json, escritas pelas Configurações.
// Sem o arquivo, o shell cria um com os padrões (assim dá para vigiar desde o começo);
// mudou o arquivo (pelas Configurações ou à mão), aplica na hora.
//   dock           mostra o dock (padrão no Hyprland: desligado)
//   wallpaper      caminho da imagem de fundo ("" = fundo padrão do Nullyz)
//   lockWallpaper  fundo da tela de bloqueio: "padrao" ou "desktop" (o mesmo da área de trabalho)
//   lockDim        escurece o fundo do bloqueio para o relógio e a senha ficarem legíveis
//   loginWallpaper imagem copiada para a tela de login ("" = fundo Nullyz); só registro, quem
//                  aplica é /usr/lib/nullyzos/fundo-login (root, via pkexec)
//   accent         cor de destaque (nome em Tok.accents)
//   clockSeconds, showDate, showAppName   o que a barra de menus mostra
//   idleLock, idleSuspend                 minutos parado até bloquear / suspender (0 = nunca)
Singleton {
    id: root

    readonly property string defaultWallpaper: "/usr/share/nullyzos/wallpapers/padrao.png"
    readonly property string dir: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/nullyzos"

    readonly property bool dock: prefs.dock
    readonly property string wallpaper: prefs.wallpaper
    readonly property string lockWallpaper: prefs.lockWallpaper
    readonly property bool lockDim: prefs.lockDim
    readonly property string loginWallpaper: prefs.loginWallpaper
    readonly property string currentWallpaper: prefs.wallpaper || defaultWallpaper
    readonly property string accent: prefs.accent
    readonly property bool clockSeconds: prefs.clockSeconds
    readonly property bool showDate: prefs.showDate
    readonly property bool showAppName: prefs.showAppName
    readonly property int idleLock: prefs.idleLock
    readonly property int idleSuspend: prefs.idleSuspend

    Binding { target: Tok; property: "accentName"; value: prefs.accent }

    readonly property string wallpaperUrl: url(prefs.wallpaper || defaultWallpaper)
    readonly property string lockUrl: prefs.lockWallpaper === "desktop" ? wallpaperUrl : url(defaultWallpaper)

    // Caminho → URL de arquivo (espaços, acentos e # no nome não quebram a imagem).
    function url(path) { return "file://" + path.split("/").map(encodeURIComponent).join("/"); }

    function set(key, value) {
        if (prefs[key] === value) return;
        prefs[key] = value;
        file.writeAdapter();
        if (key === "accent") HyprConf.save();    // borda das janelas na cor nova
    }

    FileView {
        id: file
        path: root.dir + "/shell.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => { if (err === FileViewError.FileNotFound) mkdir.running = true; }
        // Arquivo de versão antiga (sem as opções novas): regrava uma vez com todas, para quem
        // edita à mão enxergar tudo. Não entra em laço: na releitura já não falta nenhuma.
        onLoaded: {
            const t = text();
            const keys = ["dock", "wallpaper", "lockWallpaper", "lockDim", "loginWallpaper", "accent",
                          "clockSeconds", "showDate", "showAppName", "idleLock", "idleSuspend"];
            if (keys.some(k => !t.includes('"' + k + '"'))) writeAdapter();
        }
        adapter: JsonAdapter {
            id: prefs
            property bool dock: false
            property string wallpaper: ""
            property string lockWallpaper: "padrao"
            property bool lockDim: true
            property string loginWallpaper: ""
            property string accent: "violeta"
            property bool clockSeconds: false
            property bool showDate: true
            property bool showAppName: true
            property int idleLock: 10
            property int idleSuspend: 0
        }
    }

    Process {
        id: mkdir
        command: ["mkdir", "-p", root.dir]
        onExited: file.writeAdapter()
    }
}
