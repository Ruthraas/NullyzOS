import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.theme

// Bloqueio de tela (Super + L). Protocolo ext-session-lock: quem garante o bloqueio é o
// Hyprland; se o shell travar, a tela continua coberta. Senha conferida pelo PAM ("login").
Scope {
    id: root

    property bool locked: false
    property string status: ""
    property bool busy: false
    property string pending: ""

    function lock() { root.locked = true; }

    function submit(password) {
        if (busy || password.length === 0) return;
        root.pending = password;
        root.status = "";
        root.busy = true;
        if (!pam.start()) {
            root.busy = false;
            root.status = "Não foi possível conferir a senha";
        }
    }

    PamContext {
        id: pam
        config: "login"
        onPamMessage: {
            if (pam.responseRequired) {
                pam.respond(root.pending);
                root.pending = "";
            }
        }
        onCompleted: (result) => {
            root.busy = false;
            root.pending = "";
            if (result === PamResult.Success) {
                root.status = "";
                root.locked = false;
            } else if (result === PamResult.MaxTries) {
                root.status = "Muitas tentativas. Aguarde um pouco.";
            } else {
                root.status = "Senha incorreta";
            }
        }
    }

    WlSessionLock {
        locked: root.locked
        WlSessionLockSurface {
            color: Tok.bg   // nada vaza enquanto o conteúdo carrega
            LockSurface { anchors.fill: parent; lock: root }
        }
    }
}
