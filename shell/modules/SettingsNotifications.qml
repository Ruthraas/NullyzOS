import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Notificações: não perturbe, quanto tempo os avisos ficam e o histórico.
SettingsPage {
    id: page
    title: "Notificações"
    subtitle: "Avisos dos apps no canto da tela."

    SettingsRow {
        title: "Não perturbe"
        description: "Os avisos não aparecem na tela (os críticos sim). Tudo continua no histórico do painel rápido."
        Toggle { checked: Prefs.dnd; onToggled: v => Prefs.set("dnd", v) }
    }
    SettingsRow {
        title: "Tempo na tela"
        description: "Quanto tempo cada aviso fica antes de sumir (quando o app não pede outro)."
        Segmented {
            options: [[4, "Curto"], [6, "Normal"], [10, "Longo"]]
            current: Prefs.notifSeconds
            onPicked: v => Prefs.set("notifSeconds", v)
        }
    }
    SettingsRow {
        title: "Histórico"
        description: Notifs.history.length ? Notifs.history.length + (Notifs.history.length === 1 ? " aviso guardado" : " avisos guardados") + " (as 50 últimas)." : "Vazio."
        Chip { text: "Limpar"; enabled: Notifs.history.length > 0; onClicked: Notifs.clear() }
    }
}
