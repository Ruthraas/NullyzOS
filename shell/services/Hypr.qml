pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Ponte com o Hyprland: workspaces, janela ativa e ações. Os módulos não chamam o Hyprland direto.
Singleton {
    id: root

    readonly property var workspaces: Hyprland.workspaces.values.filter(w => w.id > 0)
    readonly property int activeWs: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property var activeToplevel: ToplevelManager.activeToplevel
    readonly property var toplevels: ToplevelManager.toplevels.values
    // Monitor com foco: a busca e as notificações abrem nele.
    readonly property var focusedScreen: {
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        return Quickshell.screens.find(s => s.name === name) || Quickshell.screens[0];
    }

    function dispatch(lua) { Hyprland.dispatch(lua); }
    function focusWorkspace(id) { dispatch(`hl.dsp.focus({ workspace = "${id}" })`); }

    // Abre ou foca um app pelo appId (o mesmo id do .desktop, na maioria dos apps).
    function activate(appId, entry) {
        const tl = root.toplevels.find(t => (t.appId || "").toLowerCase() === appId.toLowerCase());
        if (tl) tl.activate();
        else if (entry) entry.execute();
    }
    // Fecha todas as janelas do app (menu do dock).
    function closeApp(appId) {
        for (const t of root.toplevels)
            if ((t.appId || "").toLowerCase() === appId.toLowerCase()) t.close();
    }
    function windowsOf(appId) {
        return root.toplevels.filter(t => (t.appId || "").toLowerCase() === appId.toLowerCase()).length;
    }
}
