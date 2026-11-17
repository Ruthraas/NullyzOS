pragma Singleton

import QtQuick
import Quickshell

// Relógio único do shell, em português. SystemClock se acerta sozinho depois de suspender.
Singleton {
    readonly property date now: clock.date
    readonly property var ptBR: Qt.locale("pt_BR")
    readonly property string time: Qt.formatTime(now, "HH:mm")
    // "ter 17 nov" (barra de menus)
    readonly property string dayShort: ptBR.toString(now, "ddd d MMM").replace(/\./g, "")
    // "terça-feira, 17 de novembro" (bloqueio)
    readonly property string dateLong: ptBR.toString(now, "dddd, d 'de' MMMM")

    SystemClock { id: clock; precision: SystemClock.Minutes }
}
