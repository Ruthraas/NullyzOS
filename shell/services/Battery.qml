pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Bateria (UPower). Sem bateria (desktop, VM), `present` é falso e a barra esconde o ícone.
Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: !!(device && device.ready && device.isLaptopBattery)
    // UPower entrega 0..1 ou 0..100 conforme a versão: normaliza para 0..100.
    readonly property real percent: present ? (device.percentage <= 1 ? device.percentage * 100 : device.percentage) : 0
    readonly property bool charging: present && !UPower.onBattery
    readonly property bool low: present && !charging && percent <= 15
    readonly property string label: present ? Math.round(percent) + "%" + (charging ? " · carregando" : "") : ""
}
