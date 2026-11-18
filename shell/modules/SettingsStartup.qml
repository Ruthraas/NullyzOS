import QtQuick
import qs.theme
import qs.services
import qs.components

// Configurações → Apps ao iniciar: apps que abrem sozinhos ao entrar na sessão.
SettingsPage {
    id: page
    title: "Apps ao iniciar"
    subtitle: "Abrem sozinhos quando você entra na sessão."

    property string query: ""
    readonly property var picked: Prefs.startupApps.map(id => Apps.byId(id)).filter(e => e)
    readonly property var found: {
        const q = page.query.trim();
        return q.length < 2 ? [] : Apps.search(q).filter(e => !Prefs.startupApps.includes(e.id)).slice(0, 6);
    }
    function add(id) { Prefs.set("startupApps", JSON.stringify(Prefs.startupApps.concat([id]))); }
    function remove(id) { Prefs.set("startupApps", JSON.stringify(Prefs.startupApps.filter(x => x !== id))); }

    Txt {
        visible: page.picked.length === 0
        width: parent.width
        text: "Nenhum app abre sozinho. Procure abaixo para adicionar."
        muted: true; size: 13
    }
    Rectangle {
        visible: page.picked.length > 0
        width: parent.width; height: stCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: stCol
            width: parent.width
            Repeater {
                model: page.picked
                Item {
                    required property var modelData
                    required property int index
                    width: stCol.width; height: 52
                    AppIcon { x: 14; anchors.verticalCenter: parent.verticalCenter; size: 30; entry: parent.modelData }
                    Txt { x: 56; anchors.verticalCenter: parent.verticalCenter; text: parent.modelData.name }
                    Chip { anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter } text: "Tirar"; onClicked: page.remove(parent.modelData.id) }
                    Rectangle {
                        visible: parent.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                }
            }
        }
    }

    Txt { text: "Adicionar"; font.weight: Font.DemiBold }
    Rectangle {
        width: parent.width; height: 40
        radius: Tok.rButton + 2
        color: Tok.surfaceHi
        border { width: 1; color: sInput.activeFocus ? Tok.accent : Tok.border }
        TextInput {
            id: sInput
            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Tok.text
            font { family: Tok.font; pixelSize: Math.round(14 * Tok.fontScale) }
            onTextChanged: page.query = text
        }
        Txt { x: 12; anchors.verticalCenter: parent.verticalCenter; visible: sInput.text === ""; text: "Procurar app: brave, discord, kitty…"; muted: true }
    }
    Repeater {
        model: page.found
        Rectangle {
            required property var modelData
            width: parent.width; height: 48
            radius: Tok.rField
            color: aArea.containsMouse ? Tok.hover : Tok.surface
            border { width: 1; color: Tok.border }
            AppIcon { x: 12; anchors.verticalCenter: parent.verticalCenter; size: 28; entry: parent.modelData }
            Txt { x: 52; anchors.verticalCenter: parent.verticalCenter; text: parent.modelData.name }
            Ico { anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter } size: 16; d: Icons.plus; color: Tok.accent }
            MouseArea { id: aArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { page.add(parent.modelData.id); sInput.text = ""; } }
        }
    }
}
