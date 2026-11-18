import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.services
import qs.components

// Dock: apps fixados + abertos. Tudo vem de Configurações → Dock: posição (baixo, esquerda,
// direita), tamanho, ampliação em onda ao passar o mouse, ocultar sozinho, estilo e indicador.
// Clique abre/foca; botão direito abre o menu (nova janela, fixar, mover, fechar).
// A janela tem espessura fixa (desenho por software) e só a cápsula e o menu recebem clique
// (máscara). Trocar a posição recria a janela (shell.qml).
PanelWindow {
    id: dock
    required property var modelData
    screen: modelData

    readonly property string pos: Prefs.dockPosition
    readonly property bool vertical: pos === "esquerda" || pos === "direita"
    readonly property int icon: Prefs.dockIcon
    readonly property real mag: Prefs.dockMagnify
    readonly property int gap: 8
    readonly property int pad: 12
    readonly property int thick: icon + pad * 2               // espessura da cápsula
    readonly property int depth: 300                          // espessura da janela (ampliado + nome + menu)

    anchors {
        top: dock.vertical
        bottom: true
        left: !dock.vertical || dock.pos === "esquerda"
        right: !dock.vertical || dock.pos === "direita"
    }
    implicitHeight: vertical ? 0 : depth
    implicitWidth: vertical ? depth : 0
    exclusiveZone: Prefs.dockAutohide ? 0 : thick + 18
    color: "transparent"
    WlrLayershell.namespace: "nullyzos-dock"
    mask: Region {
        item: dock.shown ? pill : hot
        Region { item: menuBox }
    }

    // ---- itens --------------------------------------------------------------------------
    // Fixados primeiro, depois abertos que não estão fixados. Lê Apps.all para refazer a
    // lista quando os .desktop terminam de carregar.
    readonly property var items: {
        void Apps.all.length;
        const list = [];
        for (const id of Apps.pinned) {
            const e = Apps.byId(id);
            if (e) list.push({ id: e.id, entry: e, pinned: true });
        }
        if (Prefs.dockShowOpen) {
            for (const t of Hypr.toplevels) {
                const appId = t.appId || "";
                if (!appId || list.some(x => x.id.toLowerCase() === appId.toLowerCase())) continue;
                list.push({ id: appId, entry: Apps.byId(appId), pinned: false });
            }
        }
        return list;
    }

    // ---- mostrar / ocultar --------------------------------------------------------------
    property bool hovering: false
    property string menuFor: ""                 // id do app com o menu aberto
    readonly property bool shown: !Prefs.dockAutohide || hovering || menuFor !== "" || peek.running
    Timer { id: peek; interval: 1500; running: true }          // aparece um instante ao entrar
    Timer { id: leave; interval: 450; onTriggered: dock.hovering = false }
    Timer { id: menuLeave; interval: 1600; onTriggered: dock.menuFor = "" }

    // Posição do mouse ao longo do dock, em coordenadas "sem ampliação" (-1 = fora).
    property real along: -1
    readonly property real baseLength: items.length * icon + Math.max(0, items.length - 1) * gap
    function scaleAt(index) {
        if (along < 0 || mag <= 0) return 1;
        const c = index * (icon + gap) + icon / 2;
        const d = Math.abs(along - c) / (icon * 2.4);
        return 1 + mag * Math.max(0, 1 - d * d);
    }

    // Faixa invisível na borda: com o dock oculto, encostar o mouse aqui traz ele de volta.
    Item {
        id: hot
        width: dock.vertical ? 4 : pill.width
        height: dock.vertical ? pill.height : 4
        x: dock.pos === "direita" ? parent.width - width : dock.vertical ? 0 : (parent.width - width) / 2
        y: dock.vertical ? (parent.height - height) / 2 : parent.height - height
        HoverHandler { onHoveredChanged: if (hovered) { leave.stop(); dock.hovering = true; } }
    }

    // ---- cápsula ------------------------------------------------------------------------
    Glass {
        id: pill
        readonly property real len: list.implicitLength + dock.pad * 2
        width: dock.vertical ? dock.thick : len
        height: dock.vertical ? len : dock.thick
        x: dock.pos === "esquerda" ? 10 : dock.pos === "direita" ? parent.width - width - 10 : (parent.width - width) / 2
        y: dock.vertical ? (parent.height - height) / 2 : parent.height - height - 10
        radius: Math.min(26, dock.thick / 2)
        topLight: Prefs.dockStyle === "vidro"
        color: Prefs.dockStyle === "solido" ? Tok.surface : Prefs.dockStyle === "transparente" ? "transparent" : Tok.glass
        border.width: Prefs.dockStyle === "transparente" ? 0 : 1
        Behavior on width { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutCubic } }

        // Ocultar: escorrega para fora da tela (entra com overshoot, sai acelerando)
        transform: Translate {
            x: dock.shown ? 0 : (dock.pos === "esquerda" ? -dock.thick - 20 : dock.pos === "direita" ? dock.thick + 20 : 0)
            y: dock.shown || dock.vertical ? 0 : dock.thick + 20
            Behavior on x { NumberAnimation { duration: Tok.panel; easing.type: dock.shown ? Easing.OutBack : Easing.InCubic } }
            Behavior on y { NumberAnimation { duration: Tok.panel; easing.type: dock.shown ? Easing.OutBack : Easing.InCubic } }
        }

        HoverHandler {
            onHoveredChanged: {
                if (hovered) { leave.stop(); menuLeave.stop(); dock.hovering = true; }
                else { leave.restart(); dock.along = -1; if (dock.menuFor !== "") menuLeave.restart(); }
            }
            onPointChanged: {
                if (!hovered) return;
                const p = dock.vertical ? point.position.y : point.position.x;
                // cápsula ampliada fica centrada: converte para a posição sem ampliação
                dock.along = p - (pill.len - dock.baseLength) / 2;
            }
        }

        Grid {
            id: list
            readonly property real implicitLength: dock.vertical ? implicitHeight : implicitWidth
            anchors.centerIn: parent
            columns: dock.vertical ? 1 : Math.max(1, dock.items.length)
            spacing: dock.gap

            Repeater {
                model: dock.items
                Item {
                    id: slot
                    required property var modelData
                    required property int index
                    readonly property int open: Hypr.windowsOf(modelData.id)
                    readonly property real s: dock.scaleAt(index)
                    readonly property string name: modelData.entry ? modelData.entry.name : modelData.id
                    // Comprimento acompanha a ampliação (os vizinhos abrem espaço); a espessura não.
                    width: dock.vertical ? dock.icon : dock.icon * s
                    height: dock.vertical ? dock.icon * s : dock.icon
                    Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
                    Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

                    AppIcon {
                        id: ic
                        size: dock.icon * slot.s
                        entry: slot.modelData.entry
                        fallbackName: slot.modelData.id
                        // Cresce para longe da borda da tela; clique amassa (antecipação)
                        x: dock.pos === "esquerda" ? 0 : dock.pos === "direita" ? slot.width - width : (slot.width - width) / 2
                        y: dock.vertical ? (slot.height - height) / 2 : slot.height - height
                        scale: area.pressed ? 0.88 : 1
                        transformOrigin: dock.pos === "esquerda" ? Item.Left : dock.pos === "direita" ? Item.Right : Item.Bottom
                        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                    }

                    // Indicador de aberto, entre o ícone e a borda da tela
                    Rectangle {
                        visible: Prefs.dockIndicator !== "nenhum"
                        readonly property bool line: Prefs.dockIndicator === "traco"
                        readonly property real len: slot.open > 0 ? (line ? 14 : 5) : 0
                        width: dock.vertical ? (line ? 3 : 5) : len
                        height: dock.vertical ? len : (line ? 3 : 5)
                        radius: 2.5
                        color: Tok.text
                        opacity: slot.open > 0 ? 0.9 : 0
                        x: dock.pos === "esquerda" ? -7 : dock.pos === "direita" ? slot.width + 2 : (slot.width - width) / 2
                        y: dock.vertical ? (slot.height - height) / 2 : slot.height + 3
                        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
                        Behavior on width { NumberAnimation { duration: Tok.fast } }
                        Behavior on height { NumberAnimation { duration: Tok.fast } }
                    }

                    // Nome do app, do lado oposto à borda
                    Rectangle {
                        width: label.implicitWidth + 20; height: 28; radius: 10
                        color: Tok.surface
                        border { width: 1; color: Tok.edge }
                        opacity: area.containsMouse && dock.menuFor === "" ? 1 : 0
                        x: dock.pos === "esquerda" ? slot.width + dock.icon * dock.mag + 18
                           : dock.pos === "direita" ? -width - dock.icon * dock.mag - 18 : (slot.width - width) / 2
                        y: dock.vertical ? (slot.height - height) / 2 : -height - dock.icon * dock.mag - 14
                        Behavior on opacity { NumberAnimation { duration: Tok.fast } }
                        Txt { id: label; anchors.centerIn: parent; size: 13; text: slot.name }
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                dock.menuFor = dock.menuFor === slot.modelData.id ? "" : slot.modelData.id;
                                menuBox.anchorTo(slot);
                            } else {
                                dock.menuFor = "";
                                Hypr.activate(slot.modelData.id, slot.modelData.entry);
                            }
                        }
                        Accessible.name: slot.name
                    }
                }
            }
        }
    }

    // ---- menu do botão direito -------------------------------------------------------------
    Glass {
        id: menuBox
        readonly property var item: dock.items.find(i => i.id === dock.menuFor) || null
        readonly property bool isOpen: item !== null
        property point at: Qt.point(0, 0)
        function anchorTo(slot) {
            const p = slot.mapToItem(dock.contentItem, slot.width / 2, slot.height / 2);
            menuBox.at = p;
        }
        width: isOpen ? 200 : 0
        height: isOpen ? menuCol.implicitHeight + 12 : 0
        visible: isOpen
        radius: Tok.rField
        color: Tok.vm ? Tok.surface : Tok.glass
        x: dock.pos === "esquerda" ? pill.x + pill.width + 10
           : dock.pos === "direita" ? pill.x - width - 10
           : Math.max(8, Math.min(dock.width - width - 8, at.x - width / 2))
        y: dock.vertical ? Math.max(8, Math.min(dock.height - height - 8, at.y - height / 2)) : pill.y - height - 10
        HoverHandler { onHoveredChanged: if (hovered) menuLeave.stop(); else menuLeave.restart() }

        Column {
            id: menuCol
            x: 6; y: 6
            width: parent.width - 12
            visible: menuBox.isOpen
            Txt {
                width: parent.width
                leftPadding: 10; topPadding: 4; bottomPadding: 6
                text: menuBox.item ? (menuBox.item.entry ? menuBox.item.entry.name : menuBox.item.id) : ""
                muted: true; size: 12
                font.weight: Font.DemiBold
            }
            Repeater {
                model: {
                    const it = menuBox.item;
                    if (!it) return [];
                    const open = Hypr.windowsOf(it.id) > 0;
                    const pinned = Apps.isPinned(it.id);
                    const back = dock.vertical ? "Mover para cima" : "Mover para a esquerda";
                    const fwd = dock.vertical ? "Mover para baixo" : "Mover para a direita";
                    const out = [];
                    if (it.entry) out.push([open ? "Nova janela" : "Abrir", "novo"]);
                    out.push([pinned ? "Tirar do dock" : "Fixar no dock", pinned ? "tirar" : "fixar"]);
                    if (pinned) { out.push([back, "antes"]); out.push([fwd, "depois"]); }
                    if (open) out.push(["Fechar" + (Hypr.windowsOf(it.id) > 1 ? " todas" : ""), "fechar"]);
                    return out;
                }
                Rectangle {
                    required property var modelData
                    width: menuCol.width; height: 32
                    radius: Tok.rButton
                    color: mArea.containsMouse ? (modelData[1] === "fechar" ? Qt.rgba(Tok.error.r, Tok.error.g, Tok.error.b, 0.16) : Tok.hover) : "transparent"
                    Txt { x: 10; anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[0]; size: 13
                          color: parent.modelData[1] === "fechar" ? Tok.error : Tok.text }
                    MouseArea {
                        id: mArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const it = menuBox.item, a = parent.modelData[1];
                            dock.menuFor = "";
                            if (!it) return;
                            if (a === "novo" && it.entry) it.entry.execute();
                            else if (a === "fixar") Apps.pin(it.id);
                            else if (a === "tirar") Apps.unpin(it.id);
                            else if (a === "antes") Apps.movePinned(it.id, -1);
                            else if (a === "depois") Apps.movePinned(it.id, 1);
                            else if (a === "fechar") Hypr.closeApp(it.id);
                        }
                    }
                }
            }
        }
    }
}
