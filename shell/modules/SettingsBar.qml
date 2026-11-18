import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Barra: o que a barra de menus mostra e o relógio. (O dock tem página própria.)
SettingsPage {
    id: page
    title: "Barra"
    subtitle: "O que aparece na barra de menus e o relógio."

    // Linha com pílulas de escolha: [valor, rótulo]
    component Choice: Row {
        id: ch
        property var options: []
        property var current
        signal picked(var value)
        spacing: 8
        Repeater {
            model: ch.options
            Chip {
                required property var modelData
                text: modelData[1]
                active: ch.current === modelData[0]
                onClicked: ch.picked(modelData[0])
            }
        }
    }

    // ---- barra -------------------------------------------------------------------------
    Txt { text: "Barra de menus"; font.weight: Font.DemiBold }
    SettingsRow {
        title: "Altura"
        description: "Compacta sobra mais espaço para as janelas."
        Choice {
            options: [["compacta", "Compacta"], ["normal", "Normal"], ["alta", "Alta"]]
            current: Prefs.barHeight === 30 ? "compacta" : Prefs.barHeight === 42 ? "alta" : "normal"
            onPicked: v => Prefs.set("barSize", v)
        }
    }
    SettingsRow {
        title: "Símbolo do NullyzOS"
        description: "O N no canto: clique abre a busca."
        Toggle { checked: Prefs.showLogo; onToggled: v => Prefs.set("showLogo", v) }
    }
    SettingsRow {
        title: "Workspaces"
        description: Prefs.showWorkspaces ? "Pontos das áreas de trabalho; a ativa vira uma pílula. Quantos sempre aparecem:" : "Pontos das áreas de trabalho."
        Row {
            spacing: 12
            Choice {
                visible: Prefs.showWorkspaces
                options: [[3, "3"], [5, "5"], [8, "8"], [10, "10"]]
                current: Prefs.workspaceCount
                onPicked: v => Prefs.set("workspaceCount", v)
            }
            Toggle { anchors.verticalCenter: parent.verticalCenter; checked: Prefs.showWorkspaces; onToggled: v => Prefs.set("showWorkspaces", v) }
        }
    }
    SettingsRow {
        title: "Nome do app ativo"
        description: "Ao lado dos workspaces, o nome do app em que você está."
        Toggle { checked: Prefs.showAppName; onToggled: v => Prefs.set("showAppName", v) }
    }
    SettingsRow {
        title: "Ícones de status"
        description: "Rede, som e bateria; clique abre o painel rápido."
        Toggle { checked: Prefs.showStatus; onToggled: v => Prefs.set("showStatus", v) }
    }

    Item { width: 1; height: 6 }

    // ---- relógio -----------------------------------------------------------------------
    Item {
        width: parent.width; height: 20
        Txt { text: "Relógio e data"; font.weight: Font.DemiBold }
        Txt { anchors.right: parent.right; text: "Agora: " + Clock.dayShort + "  " + (Prefs.clockSeconds ? Clock.timeSec : Clock.time); muted: true; size: 13}
    }
    SettingsRow {
        title: "Formato da hora"
        description: "24 horas (14:30) ou 12 horas (2:30 PM)."
        Choice {
            options: [[true, "24 horas"], [false, "12 horas"]]
            current: Prefs.clock24
            onPicked: v => Prefs.set("clock24", v)
        }
    }
    SettingsRow {
        title: "Segundos"
        description: "Mostra os segundos no relógio da barra."
        Toggle { checked: Prefs.clockSeconds; onToggled: v => Prefs.set("clockSeconds", v) }
    }
    SettingsRow {
        title: "Data"
        description: "Antes da hora, na barra."
        Row {
            spacing: 12
            Choice {
                visible: Prefs.showDate
                options: [["curta", "ter 17 nov"], ["longa", "terça, 17 de nov."], ["numerica", "17/11"]]
                current: Prefs.dateStyle
                onPicked: v => Prefs.set("dateStyle", v)
            }
            Toggle { anchors.verticalCenter: parent.verticalCenter; checked: Prefs.showDate; onToggled: v => Prefs.set("showDate", v) }
        }
    }
    SettingsRow {
        title: "A semana começa no"
        description: "No calendário da barra."
        Choice {
            options: [["domingo", "Domingo"], ["segunda", "Segunda"]]
            current: Prefs.weekStartsMonday ? "segunda" : "domingo"
            onPicked: v => Prefs.set("weekStart", v)
        }
    }

}
