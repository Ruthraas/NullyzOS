pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Servidor de notificações (org.freedesktop.Notifications): o próprio shell é o daemon.
// Popups somem sozinhos (o tempo que o app pediu, ou 6 s); críticas ficam até fechar.
// "Não perturbe" (Prefs.dnd) segura os popups, menos os críticos. Tudo vai para o
// histórico (as 50 últimas), mostrado no painel rápido.
Singleton {
    id: root

    property list<QtObject> popups: []
    // [{ id, app, summary, body, icon, time }]
    property var history: []

    function hide(wrapper) {
        root.popups = root.popups.filter(p => p !== wrapper);
        wrapper.destroy();
    }
    function dismiss(id) { root.history = root.history.filter(h => h.id !== id); }
    function clear() { root.history = []; }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        imageSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        persistenceSupported: true
        onNotification: (n) => {
            n.tracked = true;
            root.history = [{
                id: Date.now() + "-" + n.id,
                app: n.appName || "",
                summary: n.summary || "",
                body: n.body || "",
                icon: n.image || (n.appIcon ? Quickshell.iconPath(n.appIcon, true) : ""),
                time: new Date()
            }].concat(root.history).slice(0, 50);
            if (Prefs.dnd && n.urgency !== NotificationUrgency.Critical) return;
            const w = wrapperComponent.createObject(root, { notification: n });
            root.popups = [w].concat(root.popups).slice(0, 4);
        }
    }

    Component {
        id: wrapperComponent
        QtObject {
            id: wrapper
            required property var notification
            readonly property int timeout: notification.urgency === NotificationUrgency.Critical ? 0
                : (notification.expireTimeout > 0 ? notification.expireTimeout * 1000 : Prefs.notifSeconds * 1000)
            property bool hovered: false
            property Timer timer: Timer {
                interval: wrapper.timeout
                running: wrapper.timeout > 0 && !wrapper.hovered
                onTriggered: root.hide(wrapper)
            }
            property Connections conn: Connections {
                target: wrapper.notification
                function onClosed() { root.hide(wrapper); }
            }
        }
    }
}
