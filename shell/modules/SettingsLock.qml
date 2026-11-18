import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Tela de bloqueio (#14): fundo e escurecimento.
Flickable {
    id: page
    contentHeight: col.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: col
        width: page.width
        spacing: 14

        SettingsHeader { title: "Tela de bloqueio"; subtitle: "O que aparece quando a tela está bloqueada (Super + L)." }

        Txt { text: "Fundo"; font.weight: Font.DemiBold }
        Row {
            spacing: 12
            SettingsThumb {
                path: Prefs.defaultWallpaper
                label: "Fundo Nullyz"
                selected: Prefs.lockWallpaper !== "desktop"
                onPicked: Prefs.set("lockWallpaper", "padrao")
            }
            SettingsThumb {
                path: Prefs.wallpaper || Prefs.defaultWallpaper
                label: "Igual à área de trabalho"
                selected: Prefs.lockWallpaper === "desktop"
                onPicked: Prefs.set("lockWallpaper", "desktop")
            }
        }

        Item { width: 1; height: 6 }

        SettingsRow {
            title: "Escurecer o fundo"
            description: "Deixa o relógio e o campo de senha fáceis de ler em imagens claras."
            Toggle { checked: Prefs.lockDim; onToggled: v => Prefs.set("lockDim", v) }
        }

        Txt {
            width: parent.width
            text: "A tela de login ainda usa o fundo Nullyz; a escolha para ela vem numa próxima versão."
            muted: true
            font.pixelSize: 13
            wrapMode: Text.Wrap
            elide: Text.ElideNone
        }
    }
}
