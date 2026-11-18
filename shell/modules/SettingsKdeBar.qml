import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações Nullyz no KDE → Barra: o painel de cima do Plasma (altura, solto das bordas,
// data e relógio). Lê o estado do próprio Plasma e muda na hora.
SettingsPage {
    id: page
    title: "Barra"
    subtitle: "A barra de cima: menu, menu do app, bandeja e relógio."

    readonly property var bar: Kde.state.top || ({})
    readonly property var clock: Kde.state.clock || ({})
    Component.onCompleted: Kde.refresh()

    Txt { visible: !Kde.state.top && Kde.loaded; text: "Não achei a barra de cima no Plasma."; muted: true }

    SettingsRow {
        title: "Altura"
        description: "Compacta sobra mais espaço para as janelas."
        Segmented {
            options: [[26, "Compacta"], [32, "Normal"], [40, "Alta"]]
            current: page.bar.height <= 28 ? 26 : page.bar.height >= 38 ? 40 : 32
            onPicked: v => Kde.setPanel("top", { height: v })
        }
    }
    SettingsRow {
        title: "Flutuante"
        description: "Solta das bordas, com cantos redondos."
        Toggle { checked: !!page.bar.floating; onToggled: v => Kde.setPanel("top", { floating: v }) }
    }
    SettingsRow {
        title: "Mostrar a data"
        description: "Ao lado da hora."
        Toggle { checked: page.clock.showDate !== false && page.clock.showDate !== "false"; onToggled: v => Kde.setClock("showDate", v) }
    }
    SettingsRow {
        title: "Relógio"
        Segmented {
            options: [[2, "24 horas"], [0, "12 horas"]]
            current: Number(page.clock.h24) === 0 ? 0 : 2
            onPicked: v => Kde.setClock("use24hFormat", v)
        }
    }
}
