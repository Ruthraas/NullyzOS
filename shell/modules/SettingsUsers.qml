import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Usuário: foto de perfil (opcional: de uma imagem da pasta Imagens ou de
// qualquer arquivo; vale no shell, no bloqueio e na tela de login, via scripts/avatar.sh),
// nome e senha (estes dois abrem o terminal, que pede a senha atual com segurança).
SettingsPage {
    id: page
    title: "Usuário"
    subtitle: "Sua foto, seu nome e sua senha."

    readonly property string user: Quickshell.env("USER") || ""
    readonly property string face: Quickshell.env("HOME") + "/.face"
    property string fullName: ""
    property var pictures: []
    property int faceStamp: 0          // muda para recarregar a foto

    Process {
        running: true
        command: ["sh", "-c", "getent passwd \"$USER\" | cut -d: -f5 | cut -d, -f1; d=$(xdg-user-dir PICTURES 2>/dev/null); [ -d \"$d\" ] && find \"$d\" -maxdepth 2 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) | head -n 24"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n");
                page.fullName = l[0] || "";
                page.pictures = l.slice(1).filter(x => x);
            }
        }
    }
    readonly property string avatarScript: Qt.resolvedUrl("../scripts/avatar.sh").toString().replace("file://", "")
    function avatar(args) { copy.command = ["sh", page.avatarScript].concat(args); copy.running = true; }
    Process { id: copy; onExited: page.faceStamp++ }

    Rectangle {
        width: parent.width; height: 120
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Rectangle {
            id: avatar
            x: 20; anchors.verticalCenter: parent.verticalCenter
            width: 80; height: 80; radius: 40
            color: Tok.accent
            clip: true
            Txt { anchors.centerIn: parent; visible: faceImg.status !== Image.Ready; text: (page.fullName || page.user).charAt(0).toUpperCase(); size: 34; color: Tok.textOnAccent; font.weight: Font.DemiBold }
            Image {
                id: faceImg
                anchors.fill: parent
                source: "file://" + page.face + "?" + page.faceStamp
                sourceSize: Qt.size(160, 160)
                fillMode: Image.PreserveAspectCrop
                cache: false
                visible: status === Image.Ready
            }
        }
        Column {
            x: 120; anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            Txt { text: page.fullName || page.user; size: 20; font.weight: Font.DemiBold }
            Txt { text: page.user + " · administrador"; muted: true; size: 13 }
        }
    }

    Item {
        width: parent.width; height: 30
        Txt { anchors.verticalCenter: parent.verticalCenter; text: "Foto de perfil (opcional)"; font.weight: Font.DemiBold }
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: 8
            Chip { text: "Escolher arquivo…"; active: true; onClicked: page.avatar(["escolher"]) }
            Chip { visible: faceImg.status === Image.Ready; text: "Tirar a foto"; onClicked: page.avatar(["tirar"]) }
        }
    }
    Txt {
        width: parent.width
        text: page.pictures.length ? "Ou uma da pasta Imagens:" : "Sem foto, aparece a inicial do seu nome."
        muted: true; size: 13
    }
    Flow {
        width: parent.width
        spacing: 10
        Repeater {
            model: page.pictures
            Rectangle {
                required property string modelData
                width: 64; height: 64; radius: 32
                color: Tok.surfaceHi
                clip: true
                border { width: pArea.containsMouse ? 2 : 0; color: Tok.accent }
                scale: pArea.pressed ? 0.92 : (pArea.containsMouse ? 1.06 : 1)
                Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                Image { anchors.fill: parent; anchors.margins: 2; source: Prefs.url(parent.modelData); sourceSize: Qt.size(128, 128); fillMode: Image.PreserveAspectCrop; asynchronous: true }
                MouseArea {
                    id: pArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.avatar(["usar", parent.modelData])
                }
            }
        }
    }

    Item { width: 1; height: 6 }

    SettingsRow {
        title: "Nome"
        description: "O nome que aparece na tela de login. Abre o terminal, que pede a sua senha."
        Chip { text: "Mudar o nome"; onClicked: Quickshell.execDetached(["kitty", "--hold", "-e", "chfn"]) }
    }
    SettingsRow {
        title: "Senha"
        description: "Abre o terminal: digite a senha atual e depois a nova duas vezes."
        Chip { text: "Mudar a senha"; onClicked: Quickshell.execDetached(["kitty", "--hold", "-e", "passwd"]) }
    }
}
