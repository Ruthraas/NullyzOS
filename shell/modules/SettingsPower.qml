import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Energia: quanto tempo parado até bloquear e até suspender.
SettingsPage {
    id: page
    title: "Energia"
    subtitle: "O que acontece quando o computador fica parado."

    readonly property var lockOptions: [[0, "Nunca"], [2, "2 min"], [5, "5 min"], [10, "10 min"], [30, "30 min"]]
    readonly property var suspendOptions: [[0, "Nunca"], [15, "15 min"], [30, "30 min"], [60, "1 hora"]]

    SettingsRow {
        title: "Bloquear a tela"
        description: "Depois de quanto tempo sem usar o teclado e o mouse."
        Flow {
            width: 330
            spacing: 8
            layoutDirection: Qt.RightToLeft
            Repeater {
                model: page.lockOptions.slice().reverse()
                Chip {
                    required property var modelData
                    text: modelData[1]
                    active: Prefs.idleLock === modelData[0]
                    onClicked: Prefs.set("idleLock", modelData[0])
                }
            }
        }
    }
    SettingsRow {
        title: "Suspender"
        description: "Desliga quase tudo para economizar energia; bloqueia antes."
        Flow {
            width: 330
            spacing: 8
            layoutDirection: Qt.RightToLeft
            Repeater {
                model: page.suspendOptions.slice().reverse()
                Chip {
                    required property var modelData
                    text: modelData[1]
                    active: Prefs.idleSuspend === modelData[0]
                    onClicked: Prefs.set("idleSuspend", modelData[0])
                }
            }
        }
    }
    Txt {
        width: parent.width
        text: "Vídeos em tela cheia e chamadas podem pedir para a tela não bloquear; esse pedido é respeitado."
        muted: true
        size: 13
        wrapMode: Text.Wrap
        elide: Text.ElideNone
    }
}
