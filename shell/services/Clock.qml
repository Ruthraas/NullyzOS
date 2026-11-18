pragma Singleton

import QtQuick
import Quickshell

// Relógio único do shell, em português. SystemClock se acerta sozinho depois de suspender.
// Formatos vêm de Configurações → Barra e dock (24 h ou 12 h, segundos, estilo da data).
Singleton {
    id: root
    readonly property date now: clock.date
    readonly property var ptBR: Qt.locale("pt_BR")

    function hm(d) { return Prefs.clock24 ? Qt.formatTime(d, "HH:mm") : Qt.formatTime(d, "h:mm AP"); }
    readonly property string time: hm(now)
    readonly property string timeSec: Prefs.clock24 ? Qt.formatTime(now, "HH:mm:ss") : Qt.formatTime(now, "h:mm:ss AP")
    // Barra de menus: "ter 17 nov", "terça, 17 de novembro" ou "17/11"
    readonly property string dayShort: Prefs.dateStyle === "longa" ? ptBR.toString(now, "dddd, d 'de' MMMM").replace("-feira", "")
        : Prefs.dateStyle === "numerica" ? ptBR.toString(now, "dd/MM")
        : ptBR.toString(now, "ddd d MMM").replace(/\./g, "")
    // "terça-feira, 17 de novembro" (bloqueio, agenda)
    readonly property string dateLong: ptBR.toString(now, "dddd, d 'de' MMMM")

    // "2026-11-17": a chave dos dias na agenda
    function key(d) { return Qt.formatDate(d, "yyyy-MM-dd"); }
    readonly property string today: key(now)

    // Segundos só quando a barra mostra: senão acorda 1x/min.
    SystemClock { id: clock; precision: Prefs.clockSeconds ? SystemClock.Seconds : SystemClock.Minutes }
}
