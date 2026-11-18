import QtQuick
import qs.theme

// Botão-pílula de escolha (resolução, tamanho, minutos…). `active` = escolhido.
// Hover clareia, clique amassa um pouco (antecipação) e volta com overshoot.
Rectangle {
    id: chip
    property string text
    property bool active: false
    signal clicked()

    width: label.implicitWidth + 26; height: 32
    radius: 16
    color: active ? Tok.accent : (chipArea.containsMouse ? Tok.hover : Tok.surfaceHi)
    border { width: 1; color: chip.active ? Tok.accent : Tok.border }
    Behavior on color { ColorAnimation { duration: Tok.fast } }
    scale: chipArea.pressed ? 0.95 : 1
    Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }

    Txt {
        id: label
        anchors.centerIn: parent
        text: chip.text
        color: chip.active ? Tok.textOnAccent : Tok.text
        size: 13; font { weight: chip.active ? Font.DemiBold : Font.Normal }
    }
    MouseArea {
        id: chipArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.clicked()
        Accessible.name: chip.text
    }
}
