import QtQuick
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Tela de bloqueio (#14): fundo e escurecimento do bloqueio e fundo da tela
// de login. O login roda como outro usuário (sddm): a imagem é copiada por um ajudante root
// (pkexec pede a senha uma vez).
SettingsPage {
    id: page
    title: "Tela de bloqueio"
    subtitle: "O que aparece quando a tela está bloqueada (Super + L)."

    property string pending: ""
    property string loginError: ""

    function applyLogin(path) {
        if (login.running) return;
        page.pending = path;
        page.loginError = "";
        login.command = ["pkexec", "/usr/lib/nullyzos/fundo-login", path === "" ? "padrao" : path];
        login.running = true;
        Panels.settingsAside = true;      // o pedido de senha é uma janela comum, fica por baixo
    }

    Process {
        id: login
        onExited: code => {
            Panels.settingsAside = false;
            if (code === 0) Prefs.set("loginWallpaper", page.pending);
            else if (code !== 126) page.loginError = "Não deu para trocar o fundo da tela de login (erro " + code + ").";
        }
    }

    Txt { text: "Fundo"; font.weight: Font.DemiBold }
    Row {
        spacing: 12
        SettingsThumb {
            path: Prefs.defaultWallpaper
            label: "Fundo Nullyz"
            selected: Prefs.lockWallpaper !== "desktop"
            onPicked: Prefs.set("lockWallpaper", "padrao")
        }
        SettingsThumb {
            path: Prefs.wallpaper || Prefs.defaultWallpaper
            label: "Igual à área de trabalho"
            selected: Prefs.lockWallpaper === "desktop"
            onPicked: Prefs.set("lockWallpaper", "desktop")
        }
    }

    Item { width: 1; height: 6 }

    SettingsRow {
        title: "Escurecer o fundo"
        description: "Deixa o relógio e o campo de senha fáceis de ler em imagens claras."
        Toggle { checked: Prefs.lockDim; onToggled: v => Prefs.set("lockDim", v) }
    }

    Item { width: 1; height: 10 }

    Txt { text: "Tela de login"; font.weight: Font.DemiBold }
    Row {
        spacing: 12
        SettingsThumb {
            path: Prefs.defaultWallpaper
            label: "Fundo Nullyz"
            selected: Prefs.loginWallpaper === ""
            onPicked: page.applyLogin("")
        }
        SettingsThumb {
            path: Prefs.currentWallpaper
            label: "Igual à área de trabalho"
            selected: Prefs.loginWallpaper !== "" && Prefs.loginWallpaper === Prefs.currentWallpaper
            onPicked: page.applyLogin(Prefs.currentWallpaper)
        }
    }
    Txt {
        width: parent.width
        text: login.running ? "Aguardando a senha…"
            : page.loginError !== "" ? page.loginError
            : (Prefs.loginWallpaper !== "" && Prefs.loginWallpaper !== Prefs.currentWallpaper)
              ? "A tela de login usa um fundo anterior. Escolha de novo para atualizar."
              : "Pede a sua senha: a tela de login é do sistema, não só sua."
        color: page.loginError !== "" ? Tok.error : Tok.muted
        font.pixelSize: 13
        wrapMode: Text.Wrap
        elide: Text.ElideNone
    }
}
