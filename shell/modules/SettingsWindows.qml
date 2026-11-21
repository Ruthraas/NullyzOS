import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Janelas: espaço entre janelas, cantos, animações e desfoque (Hyprland).
// Grava em HyprConf, que gera a config e recarrega o Hyprland na hora.
SettingsPage {
    id: page
    title: "Janelas"
    subtitle: "Como as janelas se arrumam e se mexem na tela."

    SettingsRow {
        title: "Espaço entre janelas"
        description: "A folga entre as janelas lado a lado e as bordas da tela."
        Segmented {
            options: [["compacto", "Pouco"], ["", "Normal"], ["amplo", "Muito"]]
            current: HyprConf.gaps === "normal" ? "" : HyprConf.gaps
            onPicked: v => HyprConf.set("gaps", v)
        }
    }
    SettingsRow {
        title: "Cantos"
        description: "O arredondamento das janelas."
        Segmented {
            options: [[0, "Retos"], [8, "Leves"], [-1, "Normais"], [20, "Redondos"]]
            current: HyprConf.rounding === 14 ? -1 : HyprConf.rounding
            onPicked: v => HyprConf.set("rounding", v)
        }
    }
    SettingsRow {
        title: "Animações"
        description: "Janelas abrindo, fechando e trocando de workspace com movimento."
        Toggle { checked: HyprConf.animations; onToggled: v => HyprConf.set("animations", v) }
    }
}
