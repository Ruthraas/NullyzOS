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
            // Barra recriada quando a altura muda (janela de tamanho fixo, ver MenuBar.qml).
            LazyLoader {
                id: barLoader
                active: true
                MenuBar { modelData: perScreen.modelData }
            }
            Connections {
                target: Prefs
                function onBarHeightChanged() { barLoader.active = false; Qt.callLater(() => barLoader.active = true); }
            }
            // Dock: recriado quando muda de lado (a janela de camada muda de borda).
            LazyLoader {
                id: dockLoader
                property bool reloading: false
                active: Prefs.dock && !reloading
                Dock { modelData: perScreen.modelData }
            }
            Connections {
                target: Prefs
                function onDockPositionChanged() { dockLoader.reloading = true; Qt.callLater(() => dockLoader.reloading = false); }
            }
        }
    }

    Popups {}
    Lock { id: screenLock }
    LazyLoader { active: Panels.launcher; Launcher {} }
    LazyLoader { active: Panels.settings; Settings {} }
    LazyLoader { active: Panels.quick; QuickPanel {} }
    LazyLoader { active: Panels.calendar; CalendarPanel {} }
    // A agenda precisa existir desde o começo para os lembretes chegarem na hora.
    readonly property int agendaEvents: Agenda.events.length
    // E o terminal: na primeira vez gera ~/.config/nullyzos/kitty.conf com o tema atual.
    readonly property real terminalFont: Terminal.fontSize
    Connections { target: Panels; function onLockRequested() { screenLock.lock(); } }
    Idle { onLockNow: { Panels.closeAll(); screenLock.lock(); } }
    Osd {}
    Startup {}
    // Boas-vindas: no primeiro login (depois que as preferências carregaram) e pelo IPC welcome
    LazyLoader { active: Panels.welcome; Welcome {} }
    Timer { interval: 2500; running: true; onTriggered: if (!Prefs.welcomed) Panels.welcome = true }
    // Luz noturna roda enquanto ativa (hyprsunset); referência para o serviço existir já no login.
    readonly property bool nightLight: NightLight.active
    // Apps Qt/KDE e GTK nas cores do Nullyz (#16): aplica ao subir e quando o tema muda.
    readonly property string appTheme: AppTheme.signature

    // Atalhos do Hyprland chamam: qs -c nullyzos ipc call nullyzos <função>
    IpcHandler {
        target: "nullyzos"
        function toggleLauncher(): void { Panels.toggleLauncher(); }
        function settings(): void { Panels.toggleSettings(); }
        function quick(): void { Panels.toggleQuick(); }
        function welcome(): void { Panels.closeAll(); Panels.welcome = true; }
        function calendar(): void { Panels.toggleCalendar(); }
        // Teclas de brilho: relê o valor e mostra o aviso na tela
        function osdBrightness(): void { Brightness.refresh(); }
        // Para scripts: qs -c nullyzos ipc call nullyzos agendaAdd 2026-11-20 14:00 "Dentista"
        function agendaAdd(day: string, time: string, title: string): bool { return Agenda.add(day, time, title); }
        function settingsPage(page: string): void { Panels.openSettings(page); }
        function lock(): void { Panels.closeAll(); screenLock.lock(); }
        function isLocked(): bool { return screenLock.locked; }
    }
}
