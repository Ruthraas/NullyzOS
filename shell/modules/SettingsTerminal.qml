import QtQuick
import Quickshell
import qs.theme
import qs.services
import qs.components

// Configurações → Terminal: prévia ao vivo + fonte, transparência, cursor, margem, prompt e
// saudação do kitty. As cores seguem o tema e o destaque escolhidos em Aparência.
SettingsPage {
    id: page
    title: "Terminal"
    subtitle: "O kitty com a cara do Nullyz. As cores seguem o tema e a cor de destaque."

    readonly property var pal: Tok.light ? Tok.palettes.claro : Tok.palettes.escuro
    readonly property color acc: Tok.light ? Tok.accentEntry.light : Tok.accentEntry.color
    readonly property real px: Terminal.fontSize * 1.33          // pontos → pixels (aprox.)

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

    // ---- prévia ------------------------------------------------------------------------
    Rectangle {
        width: parent.width
        height: preview.implicitHeight + Terminal.padding * 2 + 8
        radius: Tok.rField
        color: "transparent"
        border { width: 1; color: Tok.border }
        clip: true
        // Fundo do terminal com a transparência escolhida, sobre um xadrez leve que mostra o vidro
        Rectangle { anchors.fill: parent; radius: parent.radius; color: Tok.surfaceHi }
        Rectangle { anchors.fill: parent; radius: parent.radius; color: page.pal.bg; opacity: Terminal.opacity }

        Column {
            id: preview
            x: Terminal.padding + 8; y: Terminal.padding + 4
            width: parent.width - x * 2
            spacing: 4
            Row {
                visible: Terminal.greeting !== "nunca"
                spacing: 14
                bottomPadding: 6
                PixelN { cell: Math.max(3, page.px * 0.42); color: page.acc }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Txt { text: "NullyzOS · Hyprland"; color: page.acc; font { family: Tok.mono; pixelSize: page.px } }
                    Txt { text: (Quickshell.env("USER") || "voce") + "@nullyzos"; color: page.pal.text; font { family: Tok.mono; pixelSize: page.px } }
                    Txt { text: "ligado  2 h 14 min"; color: page.pal.muted; font { family: Tok.mono; pixelSize: page.px } }
                }
            }
            Row {
                spacing: 0
                Txt { text: "~/projetos/nullyz "; color: page.pal.text; font { family: Tok.mono; pixelSize: page.px; weight: Terminal.prompt ? Font.Bold : Font.Normal } }
                Txt { visible: Terminal.prompt; text: "main "; color: page.pal.muted; font { family: Tok.mono; pixelSize: page.px } }
                Txt { text: Terminal.prompt ? "› " : "$ "; color: Terminal.prompt ? page.acc : page.pal.text; font { family: Tok.mono; pixelSize: page.px } }
                Txt { text: "git status"; color: page.pal.text; font { family: Tok.mono; pixelSize: page.px } }
            }
            Txt { text: "Tudo em dia, nada para enviar."; color: page.pal.muted; font { family: Tok.mono; pixelSize: page.px } }
            Row {
                Txt { text: "~/projetos/nullyz "; color: page.pal.text; font { family: Tok.mono; pixelSize: page.px; weight: Terminal.prompt ? Font.Bold : Font.Normal } }
                Txt { text: Terminal.prompt ? "› " : "$ "; color: Terminal.prompt ? page.acc : page.pal.text; font { family: Tok.mono; pixelSize: page.px } }
                // Cursor no formato escolhido, piscando
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: Terminal.cursor === "beam" ? 2 : page.px * 0.6
                    height: Terminal.cursor === "underline" ? 2 : page.px * 1.2
                    color: page.acc
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0; duration: 80 }
                        PauseAnimation { duration: 520 }
                        NumberAnimation { to: 1; duration: 80 }
                        PauseAnimation { duration: 520 }
                    }
                }
            }
        }
    }

    Item { width: 1; height: 4 }

    SettingsRow {
        title: "Tamanho da fonte"
        description: Terminal.fontSize.toFixed(1).replace(".", ",") + " pt · Geist Mono"
        Slider {
            width: 220
            value: (Terminal.fontSize - 9) / 9
            onMoved: v => Terminal.set("fontSize", Math.round((9 + v * 9) * 2) / 2)
        }
    }
    SettingsRow {
        title: "Transparência"
        description: "Quanto do fundo aparece através do terminal."
        Choice {
            options: [[1, "Opaco"], [0.94, "Leve"], [0.85, "Vidro"], [0.75, "Bem transparente"]]
            current: Terminal.opacity
            onPicked: v => Terminal.set("opacity", v)
        }
    }
    SettingsRow {
        title: "Cursor"
        description: "O formato do cursor de texto."
        Choice {
            options: [["beam", "Barra"], ["block", "Bloco"], ["underline", "Sublinhado"]]
            current: Terminal.cursor
            onPicked: v => Terminal.set("cursor", v)
        }
    }
    SettingsRow {
        title: "Margem"
        description: "O espaço entre o texto e a borda da janela."
        Choice {
            options: [[4, "Pouca"], [12, "Normal"], [20, "Muita"]]
            current: Terminal.padding
            onPicked: v => Terminal.set("padding", v)
        }
    }

    Item { width: 1; height: 4 }

    Txt { text: "Prompt e saudação (bash)"; font.weight: Font.DemiBold }
    SettingsRow {
        title: "Prompt do Nullyz"
        description: "Pasta, branch do git e › na cor de destaque (vermelho quando o comando falha). Desligado, fica o prompt do seu ~/.bashrc."
        Toggle { checked: Terminal.prompt; onToggled: v => Terminal.set("prompt", v) }
    }
    SettingsRow {
        title: "Saudação"
        description: "O N pixelado e os dados do sistema ao abrir o terminal."
        Choice {
            options: [["sempre", "Sempre"], ["sessao", "1ª vez"], ["nunca", "Nunca"]]
            current: Terminal.greeting
            onPicked: v => Terminal.set("greeting", v)
        }
    }
    Txt {
        width: parent.width
        text: "Muda na hora nos terminais abertos; o prompt e a saudação valem para os próximos."
        muted: true
        font.pixelSize: 13
        wrapMode: Text.Wrap
        elide: Text.ElideNone
    }
}
