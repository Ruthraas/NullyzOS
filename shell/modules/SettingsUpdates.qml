import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Atualizações: o que tem para atualizar, "Atualizar agora" com o andamento
// ao vivo, e os snapshots (pontos de volta, no menu do boot).
SettingsPage {
    id: page
    title: "Atualizações"
    subtitle: "O sistema e os apps em dia. Antes de cada atualização é tirado um snapshot."

    Component.onCompleted: Updates.check(true)

    // ---- estado ------------------------------------------------------------------------
    Rectangle {
        width: parent.width; height: 84
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Rectangle {
            x: 16; anchors.verticalCenter: parent.verticalCenter
            width: 44; height: 44; radius: 22
            color: Updates.count > 0 ? Tok.accent : Tok.surfaceHi
            Ico {
                anchors.centerIn: parent; size: 22
                d: Updates.updating || Updates.checking ? Icons.restart : Updates.count > 0 ? Icons.download : Icons.check
                color: Updates.count > 0 ? Tok.textOnAccent : Tok.muted
                RotationAnimation on rotation { running: Updates.updating || Updates.checking; from: 0; to: 360; duration: 1000; loops: Animation.Infinite }
            }
        }
        Column {
            x: 76; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 76 - actions.width - 32
            spacing: 3
            Txt {
                width: parent.width
                font.weight: Font.DemiBold; size: 16
                text: Updates.updating ? "Atualizando…"
                    : Updates.checking ? "Procurando atualizações…"
                    : Updates.result === 0 ? "Atualizado"
                    : Updates.count === 0 ? "Tudo em dia"
                    : Updates.count + (Updates.count === 1 ? " atualização" : " atualizações")
            }
            Txt {
                width: parent.width
                muted: true; size: 13
                text: Updates.needsReboot ? "Reinicie para usar o kernel novo."
                    : Updates.result > 0 ? "A atualização não terminou (erro " + Updates.result + "). Veja o registro abaixo."
                    : isNaN(Updates.lastCheck) ? "Ainda não conferido."
                    : "Conferido " + Clock.hm(Updates.lastCheck) + (Updates.packages.length ? " · " + Updates.packages.length + " do sistema" : "")
                      + (Updates.flatpaks.length ? " · " + Updates.flatpaks.length + " do Flathub" : "")
            }
        }
        Row {
            id: actions
            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
            spacing: 8
            Chip { text: "Procurar"; enabled: !Updates.checking && !Updates.updating; onClicked: Updates.check(true) }
            Chip {
                visible: Updates.count > 0 || Updates.updating
                text: Updates.updating ? "Atualizando…" : "Atualizar agora"
                active: true
                onClicked: Updates.update()
            }
        }
    }

    // ---- registro ao vivo ------------------------------------------------------------
    Rectangle {
        visible: Updates.log.length > 0
        width: parent.width; height: visible ? 180 : 0
        radius: Tok.rField
        color: Tok.palettes.escuro.bg
        border { width: 1; color: Tok.border }
        clip: true
        ListView {
            id: logView
            anchors { fill: parent; margins: 12 }
            model: Updates.log
            onCountChanged: positionViewAtEnd()
            delegate: Txt {
                required property string modelData
                width: logView.width
                text: modelData
                size: 12
                color: modelData.startsWith("::") ? Tok.accent : Tok.palettes.escuro.muted
                font.family: Tok.mono
            }
        }
    }

    // ---- lista -------------------------------------------------------------------------
    Txt { visible: Updates.packages.length > 0; text: "Do sistema"; font.weight: Font.DemiBold }
    Rectangle {
        visible: Updates.packages.length > 0
        width: parent.width
        height: pkgCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: pkgCol
            width: parent.width
            Repeater {
                model: Updates.packages.slice(0, 40)
                Item {
                    required property var modelData
                    required property int index
                    width: pkgCol.width; height: 36
                    Txt { x: 16; anchors.verticalCenter: parent.verticalCenter; width: parent.width * 0.45; text: parent.modelData.name; size: 13 }
                    Txt {
                        anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                        text: parent.modelData.from + "  →  " + parent.modelData.to
                        muted: true; size: 12; font.family: Tok.mono
                    }
                    Rectangle {
                        visible: parent.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                }
            }
        }
    }
    Txt {
        visible: Updates.packages.length > 40
        text: "E mais " + (Updates.packages.length - 40) + "."
        muted: true; size: 13
    }

    Txt { visible: Updates.flatpaks.length > 0; text: "Do Flathub"; font.weight: Font.DemiBold }
    Flow {
        visible: Updates.flatpaks.length > 0
        width: parent.width
        spacing: 8
        Repeater {
            model: Updates.flatpaks
            Chip { required property var modelData; text: modelData.name }
        }
    }

    Item { width: 1; height: 6 }

    // ---- snapshots ---------------------------------------------------------------------
    Txt { text: "Pontos de volta (snapshots)"; font.weight: Font.DemiBold }
    Txt {
        width: parent.width
        text: Updates.snapshots.length
            ? "Se uma atualização quebrar algo: reinicie e, no menu do boot, escolha \"NullyzOS snapshots\" e o ponto de antes."
            : "Nenhum snapshot ainda. Eles aparecem aqui depois da primeira atualização (precisa do disco em btrfs, o padrão do instalador)."
        muted: true; size: 13
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
    Rectangle {
        visible: Updates.snapshots.length > 0
        width: parent.width
        height: snapCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: snapCol
            width: parent.width
            Repeater {
                model: Updates.snapshots
                Item {
                    required property var modelData
                    required property int index
                    width: snapCol.width; height: 36
                    Txt { x: 16; anchors.verticalCenter: parent.verticalCenter; width: 44; text: "#" + parent.modelData.n; muted: true; size: 12; font.family: Tok.mono }
                    Txt { x: 64; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 64 - 200; text: parent.modelData.desc || "snapshot"; size: 13 }
                    Txt { anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter } text: parent.modelData.date; muted: true; size: 12 }
                    Rectangle {
                        visible: parent.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                }
            }
        }
    }
}
