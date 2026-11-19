pragma Singleton

import QtQuick
import Quickshell

// Apps instalados (.desktop). Usado pela busca e pelo dock.
Singleton {
    id: root

    readonly property var all: DesktopEntries.applications.values
        .filter(e => !e.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    // Fixados no dock (ids de .desktop), na ordem; muda pelo menu do dock (botão direito).
    readonly property var pinned: Prefs.dockPinned
    function isPinned(id) { return root.pinned.some(p => p.toLowerCase() === String(id).toLowerCase()); }
    function pin(id) { if (!isPinned(id)) Prefs.setPinned(root.pinned.concat([id])); }
    function unpin(id) { Prefs.setPinned(root.pinned.filter(p => p.toLowerCase() !== String(id).toLowerCase())); }
    function movePinned(id, step) {
        const l = root.pinned.slice();
        const i = l.findIndex(p => p.toLowerCase() === String(id).toLowerCase());
        const j = i + step;
        if (i < 0 || j < 0 || j >= l.length) return;
        [l[i], l[j]] = [l[j], l[i]];
        Prefs.setPinned(l);
    }

    // A janela das Configurações (app do próprio shell) chega como "org.quickshell": na barra e
    // no dock ela é o app Configurações, com o nome e o ícone dele.
    function byId(id) {
        if (String(id).toLowerCase() === "org.quickshell")
            return DesktopEntries.byId("nullyzos-configuracoes") || DesktopEntries.byId("nullyzos-configuracoes-kde");
        return DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(id);
    }
    // Caminho do ícone, ou "" se o tema não tem nenhum (aí o shell desenha a inicial do app).
    function icon(entry) {
        const name = entry && entry.icon ? entry.icon : "";
        return (name && Quickshell.iconPath(name, true)) || Quickshell.iconPath("application-x-executable", true) || "";
    }

    // Busca: começo do nome > palavra do nome > meio do nome > nome genérico, palavras-chave.
    // Cada termo digitado precisa aparecer ("arq dol" acha "Dolphin — Gerenciador de arquivos").
    function search(query) {
        const q = query.trim().toLowerCase();
        if (!q) return root.all;
        const terms = q.split(/\s+/);
        const scored = [];
        for (const e of root.all) {
            const name = e.name.toLowerCase();
            const extra = [e.genericName, e.comment, (e.keywords || []).join(" "), e.id].join(" ").toLowerCase();
            let score = 0, ok = true;
            for (const t of terms) {
                if (name.startsWith(t)) score += 100;
                else if (name.includes(" " + t)) score += 60;
                else if (name.includes(t)) score += 40;
                else if (extra.includes(t)) score += 15;
                else { ok = false; break; }
            }
            if (ok) scored.push({ e: e, s: score });
        }
        scored.sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name));
        return scored.map(x => x.e);
    }
}
