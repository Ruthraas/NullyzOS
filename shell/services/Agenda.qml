pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Agenda do NullyzOS: compromissos simples (dia, hora opcional, título) em
// ~/.config/nullyzos/agenda.json. Na hora marcada chega uma notificação (notify-send).
Singleton {
    id: root

    // [{ id, date: "2026-11-17", time: "14:30" | "", title }]
    readonly property var events: { try { return JSON.parse(store.events || "[]"); } catch (e) { return []; } }
    property var notified: ({})

    function on(day) {
        return root.events.filter(e => e.date === day)
            .sort((a, b) => (a.time || "99").localeCompare(b.time || "99"));
    }
    function has(day) { return root.events.some(e => e.date === day); }
    function add(day, time, title) {
        title = String(title || "").trim();
        if (!title) return false;
        const t = /^([01]?\d|2[0-3])[:h]?([0-5]\d)?$/.exec(String(time || "").trim());
        const hhmm = t ? String(t[1]).padStart(2, "0") + ":" + (t[2] || "00") : "";
        const list = root.events.slice();
        list.push({ id: Date.now() + "-" + Math.floor(Math.random() * 1000), date: day, time: hhmm, title: title });
        store.events = JSON.stringify(list);
        file.writeAdapter();
        return true;
    }
    function remove(id) {
        store.events = JSON.stringify(root.events.filter(e => e.id !== id));
        file.writeAdapter();
    }

    // Lembrete: confere a cada minuto (o Clock acorda 1x/min).
    Connections {
        target: Clock
        function onNowChanged() {
            const day = Clock.today, hm = Qt.formatTime(Clock.now, "HH:mm");
            for (const e of root.events) {
                if (e.date !== day || e.time !== hm || root.notified[e.id]) continue;
                root.notified[e.id] = true;
                Quickshell.execDetached(["notify-send", "-a", "Agenda", "-i", "x-office-calendar", e.time + " · " + e.title, "Compromisso de agora"]);
            }
        }
    }

    FileView {
        id: file
        path: Prefs.dir + "/agenda.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => { if (err === FileViewError.FileNotFound) writeAdapter(); }
        adapter: JsonAdapter {
            id: store
            property string events: "[]"
        }
    }
}
