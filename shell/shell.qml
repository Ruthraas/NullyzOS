//@ pragma UseQApplication
//@ pragma IconTheme Adwaita
// NullyzOS — desktop para Hyprland (Quickshell 0.3). Instalado em /etc/xdg/quickshell/nullyzos,
// aberto pelo Hyprland com `qs -c nullyzos -d`. Testar no repositório: `qs -p shell/`.
//
// Dois jeitos de abrir:
//  - normal: o desktop (modules/Desktop.qml: fundo, barra, dock, notificações, bloqueio,
//    painéis sob demanda e o IPC);
//  - NULLYZ_APP=configuracoes (nullyzos-configuracoes, no KDE): só as Configurações numa
//    janela comum (modules/SettingsApp.qml).
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules

ShellRoot {
    id: root
    readonly property bool app: Quickshell.env("NULLYZ_APP") === "configuracoes"
    LazyLoader { active: !root.app; Desktop {} }
    LazyLoader { active: root.app; SettingsApp {} }
}
