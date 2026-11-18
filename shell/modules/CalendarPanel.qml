import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Calendário e agenda (clique na data/hora da barra). Mês com hoje destacado, setas para
// trocar de mês, pontinho nos dias com compromisso; embaixo, os compromissos do dia escolhido
// e o campo para adicionar (hora opcional + título, Enter salva).
PanelWindow {
    id: root
    screen: Hypr.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nullyzos-calendar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property int year: Clock.now.getFullYear()
    property int month: Clock.now.getMonth()          // 0..11
    property string selected: Clock.today
    property int direction: 0                         // -1/+1: de que lado o mês novo entra

    readonly property var weekNames: Prefs.weekStartsMonday ? ["S", "T", "Q", "Q", "S", "S", "D"] : ["D", "S", "T", "Q", "Q", "S", "S"]
    readonly property var days: {
        const first = new Date(root.year, root.month, 1);
        let lead = first.getDay();                    // 0 = domingo
        if (Prefs.weekStartsMonday) lead = (lead + 6) % 7;
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(root.year, root.month, 1 - lead + i);
            out.push({ date: d, key: Clock.key(d), inMonth: d.getMonth() === root.month });
        }
        return out;
    }
    readonly property var selectedDate: {
        const p = root.selected.split("-");
        return new Date(+p[0], +p[1] - 1, +p[2]);
    }

    function shift(n) {
        root.direction = n;
        const d = new Date(root.year, root.month + n, 1);
        root.year = d.getFullYear();
        root.month = d.getMonth();
        monthAnim.restart();
    }
    function goToday() {
        root.year = Clock.now.getFullYear();
        root.month = Clock.now.getMonth();
        root.selected = Clock.today;
    }

    MouseArea { anchors.fill: parent; onClicked: Panels.closeAll() }

    Glass {
        id: card
        width: Math.min(340, parent.width - 20)
        height: Math.min(col.implicitHeight + 32, parent.height - y - 10)
        clip: true
        x: parent.width - width - 10
        y: Prefs.barHeight + 8
        radius: Tok.rPanel - 4
        focus: true
        Keys.onEscapePressed: Panels.closeAll()
        Keys.onLeftPressed: root.shift(-1)
        Keys.onRightPressed: root.shift(1)
        MouseArea { anchors.fill: parent }

        transformOrigin: Item.TopRight
        opacity: 0
        scale: 0.94
        transform: Translate { id: drop; y: -8 }
        Component.onCompleted: { opacity = 1; scale = 1; drop.y = 0; forceActiveFocus(); }
        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
        Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
        Behavior on height { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutCubic } }

        Column {
            id: col
            x: 16; y: 16
            width: parent.width - 32
            spacing: 12

            // ---- cabeçalho: mês e setas -------------------------------------------------
            Item {
                width: parent.width; height: 32
                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        const s = Clock.ptBR.toString(new Date(root.year, root.month, 1), "MMMM 'de' yyyy");
                        return s.charAt(0).toUpperCase() + s.slice(1);
                    }
                    size: 16; font { weight: Font.DemiBold }
                }
                Row {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: 4
                    Chip {
                        visible: root.year !== Clock.now.getFullYear() || root.month !== Clock.now.getMonth() || root.selected !== Clock.today
                        text: "Hoje"
                        height: 28
                        onClicked: root.goToday()
                    }
                    IconButton { icon: Icons.chevronLeft; label: "Mês anterior"; onClicked: root.shift(-1) }
                    IconButton { icon: Icons.chevronRight; label: "Próximo mês"; onClicked: root.shift(1) }
                }
            }

            // ---- dias da semana + grade -------------------------------------------------
            Column {
                id: monthView
                width: parent.width
                spacing: 4
                // Troca de mês: a grade entra deslizando do lado da seta (arco curto + fade).
                ParallelAnimation {
                    id: monthAnim
                    NumberAnimation { target: grid; property: "x"; from: root.direction * 24; to: 0; duration: Tok.panel; easing.type: Easing.OutCubic }
                    NumberAnimation { target: grid; property: "opacity"; from: 0; to: 1; duration: Tok.panel; easing.type: Easing.OutCubic }
                }
                Row {
                    Repeater {
                        model: root.weekNames
                        Txt {
                            required property string modelData
                            width: monthView.width / 7
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            muted: true
                            size: 12; font { weight: Font.DemiBold }
                        }
                    }
                }
                Grid {
                    id: grid
                    columns: 7
                    Repeater {
                        model: root.days
                        Item {
                            id: cell
                            required property var modelData
                            readonly property bool isToday: modelData.key === Clock.today
                            readonly property bool isSel: modelData.key === root.selected
                            width: monthView.width / 7; height: 38
                            Rectangle {
                                anchors.centerIn: parent
                                width: 32; height: 32; radius: 16
                                color: cell.isToday ? Tok.accent : (dayArea.containsMouse ? Tok.hover : "transparent")
                                border { width: cell.isSel && !cell.isToday ? 2 : 0; color: Tok.accent }
                                scale: dayArea.pressed ? 0.9 : 1
                                Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                                Behavior on color { ColorAnimation { duration: Tok.fast } }
                                Txt {
                                    anchors.centerIn: parent
                                    text: cell.modelData.date.getDate()
                                    color: cell.isToday ? Tok.textOnAccent : (cell.modelData.inMonth ? Tok.text : Tok.muted)
                                    opacity: cell.modelData.inMonth || cell.isToday ? 1 : 0.5
                                    size: 13; font { weight: cell.isToday || cell.isSel ? Font.DemiBold : Font.Normal; features: { "tnum": 1 } }
                                }
                            }
                            Rectangle {
                                visible: Agenda.has(cell.modelData.key)
                                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 1 }
                                width: 4; height: 4; radius: 2
                                color: Tok.accent
                            }
                            MouseArea {
                                id: dayArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selected = cell.modelData.key;
                                    if (!cell.modelData.inMonth) root.shift(cell.modelData.date < new Date(root.year, root.month, 1) ? -1 : 1);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Tok.border }

            // ---- compromissos do dia ----------------------------------------------------
            Txt {
                width: parent.width
                text: {
                    const s = Clock.ptBR.toString(root.selectedDate, "dddd, d 'de' MMMM");
                    return (root.selected === Clock.today ? "Hoje, " : "") + (root.selected === Clock.today ? s : s.charAt(0).toUpperCase() + s.slice(1));
                }
                font.weight: Font.DemiBold
            }
            Column {
                width: parent.width
                spacing: 4
                Repeater {
                    model: Agenda.on(root.selected)
                    Rectangle {
                        id: ev
                        required property var modelData
                        width: parent.width; height: 38
                        radius: Tok.rButton + 2
                        color: evArea.containsMouse ? Tok.hover : Tok.surface
                        Rectangle { x: 10; anchors.verticalCenter: parent.verticalCenter; width: 3; height: 20; radius: 1.5; color: Tok.accent }
                        Txt {
                            x: 22; anchors.verticalCenter: parent.verticalCenter
                            width: 48
                            text: ev.modelData.time || "Dia todo"
                            muted: true
                            size: 12; font { features: { "tnum": 1 } }
                        }
                        Txt { x: 74; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 74 - 36; text: ev.modelData.title }
                        MouseArea { id: evArea; anchors.fill: parent; hoverEnabled: true }
                        IconButton {
                            anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                            width: 28; height: 28
                            opacity: 0.7
                            icon: Icons.close
                            label: "Apagar " + ev.modelData.title
                            onClicked: Agenda.remove(ev.modelData.id)
                        }
                    }
                }
                Txt {
                    visible: Agenda.on(root.selected).length === 0
                    text: "Nada marcado."
                    muted: true
                    size: 13
                }
            }

            // ---- adicionar --------------------------------------------------------------
            Row {
                width: parent.width
                spacing: 6
                Field { id: timeField; width: 64; placeholder: "14:00"; onAccepted: titleField.focusInput() }
                Field { id: titleField; width: parent.width - 64 - 6 - 40 - 6; placeholder: "Novo compromisso"; onAccepted: addBtn.add() }
                Rectangle {
                    id: addBtn
                    function add() {
                        if (Agenda.add(root.selected, timeField.text, titleField.text)) { timeField.text = ""; titleField.text = ""; }
                    }
                    width: 40; height: 36; radius: Tok.rButton + 2
                    color: addArea.containsMouse ? Qt.lighter(Tok.accent, 1.08) : Tok.accent
                    scale: addArea.pressed ? 0.92 : 1
                    Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                    Ico { anchors.centerIn: parent; size: 18; stroke: 2.2; d: Icons.plus; color: Tok.textOnAccent }
                    MouseArea { id: addArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: addBtn.add() }
                }
            }
        }
    }

    // Campo de texto pequeno (hora, título).
    component Field: Rectangle {
        id: f
        property alias text: input.text
        property string placeholder
        signal accepted()
        function focusInput() { input.forceActiveFocus(); }
        height: 36
        radius: Tok.rButton + 2
        color: Tok.surfaceHi
        border { width: 1; color: input.activeFocus ? Tok.accent : Tok.border }
        TextInput {
            id: input
            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Tok.text
            font { family: Tok.font; pixelSize: Math.round(13 * Tok.fontScale) }
            Keys.onReturnPressed: f.accepted()
            Keys.onEnterPressed: f.accepted()
            Keys.onEscapePressed: Panels.closeAll()
        }
        Txt { x: 10; anchors.verticalCenter: parent.verticalCenter; visible: input.text === ""; text: f.placeholder; muted: true; size: 13}
    }
}
