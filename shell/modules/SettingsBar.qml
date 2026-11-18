import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Barra e dock: o que a barra de menus mostra e o dock.
SettingsPage {
    id: page
    title: "Barra e dock"
    subtitle: "O que aparece na barra de menus e na parte de baixo da tela."

    Txt { text: "Barra de menus"; font.weight: Font.DemiBold }
    SettingsRow {
        title: "Nome do app ativo"
        description: "Ao lado dos workspaces, o nome do app em que você está."
        Toggle { checked: Prefs.showAppName; onToggled: v => Prefs.set("showAppName", v) }
    }
    SettingsRow {
        title: "Data"
        description: "Dia da semana e do mês antes da hora."
        Toggle { checked: Prefs.showDate; onToggled: v => Prefs.set("showDate", v) }
    }
    SettingsRow {
        title: "Segundos no relógio"
        description: "Mostra 14:05:32 em vez de 14:05."
        Toggle { checked: Prefs.clockSeconds; onToggled: v => Prefs.set("clockSeconds", v) }
    }

    Item { width: 1; height: 6 }

    Txt { text: "Dock"; font.weight: Font.DemiBold }
    SettingsRow {
        title: "Mostrar dock"
        description: "Apps fixados e abertos numa barra na parte de baixo da tela. Desligado, as janelas usam a tela até embaixo."
        Toggle { checked: Prefs.dock; onToggled: v => Prefs.set("dock", v) }
    }
}
