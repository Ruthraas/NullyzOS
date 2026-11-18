import QtQuick
import qs.theme
import qs.services

// Bateria desenhada: contorno + nível preenchido (vermelho quando baixa) + raio carregando.
Item {
    id: root
    property real size: 22
    width: size; height: size

    Ico { anchors.fill: parent; size: root.size; d: Icons.battery; color: Battery.low ? Tok.error : Tok.text }
    Rectangle {
        x: root.size * 4.5 / 24; y: root.size * 9.5 / 24
        height: root.size * 5 / 24; radius: 1
        width: root.size * 13 / 24 * Math.max(0.08, Battery.percent / 100)
        color: Battery.low ? Tok.error : Tok.text
        visible: !Battery.charging
    }
    Ico { anchors.centerIn: parent; size: root.size * 0.62; stroke: 1.6; d: Icons.bolt; color: Tok.accent; visible: Battery.charging }
}
