/* Lateral do instalador do NullyzOS: o N pixelado, o nome e os passos numa linha do tempo
   (feito = visto, atual = aceso na cor de destaque, próximos = contorno). Cores de
   branding/tokens.json (escuro). Baseado no exemplo do Calamares (GPL-3.0-or-later). */
import io.calamares.ui 1.0
import io.calamares.core 1.0

import QtQuick

Rectangle {
    id: side
    anchors.fill: parent
    color: "#0e0e13"

    readonly property color accent: "#9d8cff"
    readonly property color text: "#ededf2"
    readonly property color muted: "#a3a3b3"
    readonly property color line: "#2b2b37"

    // Borda direita
    Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 1; color: side.line }

    // ---- marca ------------------------------------------------------------------------
    Column {
        id: brand
        x: 32; y: 40
        spacing: 14
        Grid {
            columns: 7
            spacing: 2
            Repeater {
                model: "##...#####..######.####.######..#####...####...##".split("")
                Rectangle { width: 7; height: 7; radius: 1.5; color: modelData === "#" ? side.accent : "transparent" }
            }
        }
        Column {
            spacing: 2
            Text { text: "NullyzOS"; color: side.text; font { family: "Geist"; pixelSize: 22; weight: Font.DemiBold } }
            Text { text: "Instalação"; color: side.muted; font { family: "Geist"; pixelSize: 14 } }
        }
    }

    // ---- passos -----------------------------------------------------------------------
    Column {
        id: steps
        anchors { top: brand.bottom; topMargin: 44; left: parent.left; leftMargin: 32; right: parent.right; rightMargin: 20 }
        spacing: 0
        Repeater {
            model: ViewManager
            Item {
                id: step
                readonly property int cur: ViewManager.currentStepIndex
                readonly property bool done: index < cur
                readonly property bool now: index === cur
                width: steps.width
                height: 48
                // Linha do tempo entre os círculos
                Rectangle {
                    visible: index > 0
                    x: 11; y: -24 + 12
                    width: 2; height: 24
                    color: step.done || step.now ? side.accent : side.line
                }
                Rectangle {
                    id: dot
                    x: 0; anchors.verticalCenter: parent.verticalCenter
                    width: 24; height: 24; radius: 12
                    color: step.done || step.now ? side.accent : "transparent"
                    border { width: 2; color: step.done || step.now ? side.accent : side.line }
                    scale: step.now ? 1.12 : 1
                    Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Text {
                        anchors.centerIn: parent
                        text: step.done ? "✓" : (index + 1)
                        color: step.done || step.now ? "#0e0e13" : side.muted
                        font { family: "Geist"; pixelSize: 12; weight: Font.DemiBold }
                    }
                }
                Text {
                    x: 40; anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 40
                    elide: Text.ElideRight
                    text: display
                    color: step.now ? side.text : side.muted
                    font { family: "Geist"; pixelSize: 15; weight: step.now ? Font.DemiBold : Font.Normal }
                }
            }
        }
    }

    // ---- rodapé -----------------------------------------------------------------------
    Text {
        anchors { left: parent.left; leftMargin: 32; bottom: parent.bottom; bottomMargin: 28 }
        text: "v" + Branding.string(Branding.Version)
        color: side.line
        font { family: "Geist Mono"; pixelSize: 12 }
    }
    Text {
        visible: debug.enabled
        anchors { right: parent.right; rightMargin: 20; bottom: parent.bottom; bottomMargin: 28 }
        text: "Depurar"
        color: side.muted
        font { family: "Geist"; pixelSize: 12 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: debug.toggle() }
    }
}
