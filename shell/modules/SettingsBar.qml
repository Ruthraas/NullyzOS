import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Barra: o que a barra de menus mostra e o relógio. (O dock tem página própria.)
SettingsPage {
    id: page
    title: "Barra"
    subtitle: "O que aparece na barra de menus e o relógio."


    // ---- barra -------------------------------------------------------------------------
    Txt { text: "Barra de menus"; font.weight: Font.DemiBold }
    // Estilo: miniatura de cada um (faixa do wallpaper com a barra desenhada em cima)
    Flow {
        width: parent.width
        spacing: 12
        Repeater {
            model: [["classica", "Clássica"], ["flutuante", "Flutuante"], ["ilhas", "Ilhas"], ["semfundo", "Sem fundo"]]
            Item {
                id: st
                required property var modelData
                readonly property string key: modelData[0]
                readonly property bool chosen: Prefs.barStyle === key
                width: 150; height: 96
                Rectangle {
                    id: shot
                    width: parent.width; height: 70
                    radius: Tok.rButton + 2
                    color: Tok.surfaceHi
                    clip: true
                    border { width: st.chosen ? 2 : 1; color: st.chosen ? Tok.accent : Tok.edge }
                    scale: stArea.pressed ? 0.95 : (stArea.containsMouse ? 1.04 : 1)
                    Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                    // "wallpaper": mancha na cor de destaque
                    Rectangle { x: 70; y: 26; width: 110; height: 70; radius: 35; color: Tok.accent; opacity: 0.18 }
                    // clássica: faixa inteira
                    Rectangle { visible: st.key === "classica"; x: 2; y: 2; width: parent.width - 4; height: 12; color: Tok.surface }
                    // flutuante: faixa solta e redonda
                    Rectangle { visible: st.key === "flutuante"; x: 6; y: 6; width: parent.width - 12; height: 12; radius: 6; color: Tok.surface; border { width: 1; color: Tok.border } }
                    // ilhas: três pílulas
                    Rectangle { visible: st.key === "ilhas"; x: 6; y: 6; width: 34; height: 12; radius: 6; color: Tok.surface; border { width: 1; color: Tok.border } }
                    Rectangle { visible: st.key === "ilhas"; x: (parent.width - 36) / 2; y: 6; width: 36; height: 12; radius: 6; color: Tok.surface; border { width: 1; color: Tok.border } }
                    Rectangle { visible: st.key === "ilhas"; x: parent.width - 52; y: 6; width: 46; height: 12; radius: 6; color: Tok.surface; border { width: 1; color: Tok.border } }
                    // conteúdo da barra (o mesmo em todos)
                    Rectangle { x: st.key === "classica" || st.key === "semfundo" ? 8 : 12; y: st.key === "classica" || st.key === "semfundo" ? 6 : 10; width: 10; height: 4; radius: 2; color: Tok.accent }
                    Rectangle { x: st.key === "classica" || st.key === "semfundo" ? 22 : 26; y: st.key === "classica" || st.key === "semfundo" ? 6 : 10; width: 10; height: 4; radius: 2; color: Tok.muted }
                    Rectangle { x: parent.width - (st.key === "classica" || st.key === "semfundo" ? 30 : 34); y: st.key === "classica" || st.key === "semfundo" ? 6 : 10; width: 22; height: 4; radius: 2; color: Tok.text }
                    MouseArea {
                        id: stArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Prefs.set("barStyle", st.key)
                        Accessible.name: "Barra " + st.modelData[1]
                    }
                }
                Txt {
                    anchors { top: shot.bottom; topMargin: 6; horizontalCenter: parent.horizontalCenter }
                    text: st.modelData[1]
                    size: 13
                    font.weight: st.chosen ? Font.DemiBold : Font.Normal
                }
            }
        }
    }
    SettingsRow {
        title: "Altura"
        description: "Compacta sobra mais espaço para as janelas."
        Segmented {
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
            Segmented {
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
        Segmented {
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
            Segmented {
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
        Segmented {
            options: [["domingo", "Domingo"], ["segunda", "Segunda"]]
            current: Prefs.weekStartsMonday ? "segunda" : "domingo"
            onPicked: v => Prefs.set("weekStart", v)
        }
    }

}
