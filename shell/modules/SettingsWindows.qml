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
        Row {
            spacing: 8
            Repeater {
                model: [["compacto", "Pouco"], ["", "Normal"], ["amplo", "Muito"]]
                Chip {
                    required property var modelData
                    text: modelData[1]
                    active: (HyprConf.gaps === "normal" ? "" : HyprConf.gaps) === modelData[0]
                    onClicked: HyprConf.set("gaps", modelData[0])
                }
            }
        }
    }
    SettingsRow {
        title: "Cantos"
        description: "O arredondamento das janelas."
        Row {
            spacing: 8
            Repeater {
                model: [[0, "Retos"], [8, "Leves"], [-1, "Normais"], [20, "Redondos"]]
                Chip {
                    required property var modelData
                    text: modelData[1]
                    active: HyprConf.rounding === modelData[0] || (modelData[0] === -1 && HyprConf.rounding === 14)
                    onClicked: HyprConf.set("rounding", modelData[0])
                }
            }
        }
    }
    SettingsRow {
        title: "Animações"
        description: "Janelas abrindo, fechando e trocando de workspace com movimento."
        Toggle { checked: HyprConf.animations; onToggled: v => HyprConf.set("animations", v) }
    }
    SettingsRow {
        title: "Desfoque atrás do vidro"
        description: Tok.vm ? "Desligado em máquina virtual (fica lento sem placa de vídeo)." : "A barra e os painéis desfocam o que está atrás deles."
        Toggle { enabled: !Tok.vm; opacity: enabled ? 1 : 0.4; checked: HyprConf.blur && !Tok.vm; onToggled: v => HyprConf.set("blur", v) }
    }
}
