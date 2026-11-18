import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações Nullyz no KDE → Dock: o painel de baixo (ou do lado) do Plasma. Tamanho,
// lado da tela, quando esconder e se fica solto das bordas. Muda na hora.
SettingsPage {
    id: page
    title: "Dock"
    subtitle: "Os apps fixados e abertos, embaixo ou de lado."

    readonly property var dock: Kde.state.dock || ({})
    Component.onCompleted: Kde.refresh()

    Txt { visible: !Kde.state.dock && Kde.loaded; text: "Não achei o dock no Plasma."; muted: true }

    SettingsRow {
        title: "Tamanho"
        Segmented {
            options: [[44, "Pequeno"], [54, "Normal"], [66, "Grande"], [80, "Enorme"]]
            current: page.dock.height <= 48 ? 44 : page.dock.height <= 60 ? 54 : page.dock.height <= 72 ? 66 : 80
            onPicked: v => Kde.setPanel("dock", { height: v })
        }
    }
    SettingsRow {
        title: "Posição"
        Segmented {
            options: [["left", "Esquerda"], ["bottom", "Embaixo"], ["right", "Direita"]]
            current: page.dock.location || "bottom"
            onPicked: v => Kde.setPanel("dock", { location: v })
        }
    }
    SettingsRow {
        title: "Esconder"
        description: "Desviar: some só quando uma janela encosta nele."
        Segmented {
            options: [["none", "Nunca"], ["dodgewindows", "Desviar"], ["autohide", "Sempre"]]
            current: page.dock.hiding || "none"
            onPicked: v => Kde.setPanel("dock", { hiding: v })
        }
    }
    SettingsRow {
        title: "Flutuante"
        description: "Solto das bordas, com cantos redondos."
        Toggle { checked: page.dock.floating !== false; onToggled: v => Kde.setPanel("dock", { floating: v }) }
    }
    SettingsRow {
        title: "Do tamanho dos ícones"
        description: "Desligado, o dock ocupa a borda inteira."
        Toggle { checked: page.dock.lengthMode === "fit" || page.dock.lengthMode === undefined; onToggled: v => Kde.setPanel("dock", { lengthMode: v ? "fit" : "fill" }) }
    }
}
