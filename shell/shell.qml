//@ pragma UseQApplication
//@ pragma IconTheme Adwaita
// NullyzOS — desktop para Hyprland (Quickshell 0.3). Instalado em /etc/xdg/quickshell/nullyzos,
// aberto pelo Hyprland com `qs -c nullyzos -d`. Testar no repositório: `qs -p shell/`.
//
// Sempre carregados: fundo, barra de menus, notificações e o bloqueio (que só cria
// superfícies quando bloqueia). Sob demanda (LazyLoader): a busca e o dock (só se ligado
// nas preferências, services/Prefs.qml; no Hyprland vem desligado) e as Configurações.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules

ShellRoot {
    Variants {
        model: Quickshell.screens
        Scope {
            id: perScreen
            required property var modelData
            Wallpaper { modelData: perScreen.modelData }
            MenuBar { modelData: perScreen.modelData }
            LazyLoader {
                active: Prefs.dock
                Dock { modelData: perScreen.modelData }
            }
        }
    }

    Popups {}
    Lock { id: screenLock }
    LazyLoader { active: Panels.launcher; Launcher {} }
    LazyLoader { active: Panels.settings; Settings {} }

    // Atalhos do Hyprland chamam: qs -c nullyzos ipc call nullyzos <função>
    IpcHandler {
        target: "nullyzos"
        function toggleLauncher(): void { Panels.toggleLauncher(); }
        function settings(): void { Panels.toggleSettings(); }
        function settingsPage(page: string): void { Panels.openSettings(page); }
        function lock(): void { Panels.closeAll(); screenLock.lock(); }
        function isLocked(): bool { return screenLock.locked; }
    }
}
