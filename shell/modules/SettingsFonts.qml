import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Fontes.
//  - Interface: qualquer fonte instalada (busca), desenhada nela mesma; tamanho do texto.
//  - Terminal: qualquer fonte monoespaçada instalada (fc-list :spacing=mono).
//  - Baixar: busca pacotes de fonte nos repositórios oficiais e instala (pkexec,
//    /usr/lib/nullyzos/limpeza fonte); depois o shell reinicia e volta nesta página.
//  - Arquivo .ttf/.otf da internet: abre ~/.local/share/fonts; "Atualizar lista" relê.
SettingsPage {
    id: page
    title: "Fontes"
    subtitle: "As letras da interface e do terminal."

    readonly property string script: Qt.resolvedUrl("../scripts/fontes.sh").toString().replace("file://", "")
    // Fontes "de sistema" que não fazem sentido como fonte de interface
    readonly property var hidden: /^(Noto Color Emoji|Symbols|Font Awesome|Material|DejaVu Math|Noto (Sans|Serif) (Symbols|Math)|Twemoji|Emoji)/
    // Uma entrada por família: "Geist Black", "Geist Light"… somem quando "Geist" existe.
    readonly property var weights: / (Thin|Hairline|ExtraLight|UltraLight|Light|Book|Regular|Medium|SemiBold|DemiBold|Bold|ExtraBold|UltraBold|Black|Heavy|ExtraBlack|Condensed|SemiCondensed|Narrow|Display|Text)( (Thin|Light|Medium|SemiBold|Bold|Italic))*$/
    readonly property var allFonts: {
        const all = Qt.fontFamilies().filter(f => !page.hidden.test(f) && !f.startsWith("."));
        const set = new Set(all);
        return all.filter(f => { const base = f.replace(page.weights, ""); return base === f || !set.has(base); });
    }
    property var monoFonts: ["Geist Mono"]
    property string uiQuery: ""
    property string monoQuery: ""
    property string pkgQuery: ""
    property var pkgResults: []          // [{ name, installed, desc }]
    property bool searching: false
    property string busy: ""
    property string message: ""

    function filter(list, q) {
        q = q.trim().toLowerCase();
        return (q ? list.filter(f => f.toLowerCase().includes(q)) : list).slice(0, 24);
    }
    function restartHere() {
        Quickshell.execDetached(["sh", "-c", "sleep 0.4; pkill -x qs; sleep 0.7; qs -n -c nullyzos -d; sleep 1.5; qs -c nullyzos ipc call nullyzos settingsPage fontes"]);
    }
    function install(pkg) {
        if (busy) return;
        busy = pkg;
        message = "";
        job.command = ["pkexec", "/usr/lib/nullyzos/limpeza", "fonte", pkg];
        job.running = true;
        Panels.settingsAside = true;          // o pedido de senha fica por baixo das Configurações
    }

    Process {
        running: true
        command: ["sh", page.script, "mono"]
        stdout: StdioCollector { onStreamFinished: { const l = text.split("\n").filter(x => x); if (l.length) page.monoFonts = l; } }
    }
    Process {
        id: search
        stdout: StdioCollector {
            onStreamFinished: {
                page.pkgResults = text.split("\n").filter(x => x).map(l => {
                    const f = l.split("\t");
                    return { name: f[0], installed: f[1] === "1", desc: f[2] || "" };
                });
                page.searching = false;
            }
        }
    }
    Timer {
        id: searchDelay
        interval: 400
        onTriggered: {
            if (page.pkgQuery.trim().length < 2) { page.pkgResults = []; return; }
            page.searching = true;
            search.command = ["sh", page.script, "busca", page.pkgQuery.trim()];
            search.running = true;
        }
    }
    Process {
        id: job
        stderr: StdioCollector { id: jobErr }
        onExited: code => {
            Panels.settingsAside = false;
            page.busy = "";
            if (code === 0) { page.message = "Instalada. Reiniciando o shell para ela aparecer…"; page.restartHere(); }
            else if (code !== 126) page.message = "Não deu para instalar: " + (jobErr.text.trim() || "erro " + code);
        }
    }
    Process { id: refresh; command: ["sh", page.script, "atualizar"]; onExited: page.restartHere() }

    // ---- peças -------------------------------------------------------------------------
    component SearchField: Rectangle {
        id: sf
        property alias text: input.text
        property string placeholder
        width: parent.width; height: 38
        radius: Tok.rButton + 2
        color: Tok.surfaceHi
        border { width: 1; color: input.activeFocus ? Tok.accent : Tok.border }
        Ico { x: 12; anchors.verticalCenter: parent.verticalCenter; size: 15; color: Tok.muted; d: "M10.5 17a6.5 6.5 0 1 0 0-13 6.5 6.5 0 0 0 0 13z M15.5 15.5L20 20" }
        TextInput {
            id: input
            anchors { fill: parent; leftMargin: 36; rightMargin: 12 }
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Tok.text
            font { family: Tok.font; pixelSize: Math.round(14 * Tok.fontScale) }
            Keys.onEscapePressed: text = ""
        }
        Txt { x: 36; anchors.verticalCenter: parent.verticalCenter; visible: input.text === ""; text: sf.placeholder; muted: true }
    }

    component FontCard: Rectangle {
        id: fc
        property string family
        property bool chosen: false
        property string sample: "Aa"
        signal picked()
        width: 140; height: 84
        radius: Tok.rField
        color: area.containsMouse ? Tok.hover : Tok.surface
        border { width: chosen ? 2 : 1; color: chosen ? Tok.accent : Tok.border }
        scale: area.pressed ? 0.96 : 1
        Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: Tok.fast } }
        Txt {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 10 }
            text: fc.sample
            size: fc.sample.length > 3 ? 15 : 26
            font.family: fc.family
        }
        Txt {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 10 }
            width: parent.width - 16
            horizontalAlignment: Text.AlignHCenter
            text: fc.family
            size: 12
            muted: !fc.chosen
            font.family: fc.family
        }
        MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: fc.picked() }
    }

    // ---- interface ---------------------------------------------------------------------
    Item {
        width: parent.width; height: 20
        Txt { text: "Fonte da interface"; font.weight: Font.DemiBold }
        Txt { anchors.right: parent.right; text: "Agora: " + Tok.font + " · " + page.allFonts.length + " instaladas"; muted: true; size: 13 }
    }
    SearchField { id: uiSearch; placeholder: "Procurar entre as fontes instaladas"; onTextChanged: page.uiQuery = text }
    Flow {
        width: parent.width
        spacing: 10
        Repeater {
            model: page.filter(page.allFonts, page.uiQuery)
            FontCard {
                required property string modelData
                family: modelData
                chosen: Tok.font === modelData
                onPicked: Prefs.set("uiFont", modelData)
            }
        }
    }
    SettingsRow {
        title: "Tamanho do texto"
        description: "Barra, painéis e Configurações. Os apps têm o próprio ajuste."
        Row {
            spacing: 8
            Repeater {
                model: [[0.9, "Pequeno"], [1, "Normal"], [1.1, "Grande"], [1.25, "Enorme"]]
                Chip {
                    required property var modelData
                    text: modelData[1]
                    active: Math.abs(Tok.fontScale - modelData[0]) < 0.01
                    onClicked: Prefs.set("textScale", modelData[0])
                }
            }
        }
    }

    Item { width: 1; height: 6 }

    // ---- terminal ----------------------------------------------------------------------
    Item {
        width: parent.width; height: 20
        Txt { text: "Fonte do terminal"; font.weight: Font.DemiBold }
        Txt { anchors.right: parent.right; text: "Só as de largura fixa · " + page.monoFonts.length; muted: true; size: 13 }
    }
    SearchField { placeholder: "Procurar fontes de terminal"; onTextChanged: page.monoQuery = text; visible: page.monoFonts.length > 8 }
    Flow {
        width: parent.width
        spacing: 10
        Repeater {
            model: page.filter(page.monoFonts, page.monoQuery)
            FontCard {
                required property string modelData
                family: modelData
                sample: "~ › ls"
                chosen: Terminal.fontFamily === modelData
                onPicked: Terminal.set("fontFamily", modelData)
            }
        }
    }

    Item { width: 1; height: 6 }

    // ---- baixar ------------------------------------------------------------------------
    Txt { text: "Baixar mais fontes"; font.weight: Font.DemiBold }
    Txt {
        width: parent.width
        text: "Dos repositórios oficiais (ex.: inter, jetbrains, fira, ibm plex, roboto). Pede sua senha."
        muted: true; size: 13
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
    SearchField { placeholder: "Procurar fonte para baixar"; onTextChanged: { page.pkgQuery = text; searchDelay.restart(); } }
    Txt { visible: page.searching; text: "Procurando…"; muted: true; size: 13 }
    Txt { visible: !page.searching && page.pkgQuery.trim().length >= 2 && page.pkgResults.length === 0; text: "Nenhuma fonte com esse nome nos repositórios."; muted: true; size: 13 }
    Rectangle {
        visible: page.pkgResults.length > 0
        width: parent.width
        height: results.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: results
            width: parent.width
            Repeater {
                model: page.pkgResults
                Item {
                    required property var modelData
                    required property int index
                    width: results.width; height: 52
                    Column {
                        x: 16; anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 150
                        spacing: 2
                        Txt { width: parent.width; text: parent.parent.modelData.name; font.weight: Font.DemiBold; size: 13 }
                        Txt { width: parent.width; text: parent.parent.modelData.desc; muted: true; size: 12 }
                    }
                    Chip {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        text: parent.modelData.installed ? "Instalada" : page.busy === parent.modelData.name ? "Instalando…" : "Instalar"
                        active: parent.modelData.installed
                        onClicked: if (!parent.modelData.installed) page.install(parent.modelData.name)
                    }
                    Rectangle {
                        visible: parent.index > 0
                        anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: Tok.border
                    }
                }
            }
        }
    }
    Txt {
        visible: page.message !== ""
        width: parent.width
        text: page.message
        color: page.message.startsWith("Instalada") ? Tok.accent : Tok.error
        size: 13
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }

    SettingsRow {
        title: "Fonte baixada da internet"
        description: "Arquivo .ttf ou .otf: coloque na pasta de fontes e clique em Atualizar lista."
        Row {
            spacing: 8
            Chip {
                text: "Abrir pasta"
                onClicked: Quickshell.execDetached(["sh", "-c", "mkdir -p \"$HOME/.local/share/fonts\" && xdg-open \"$HOME/.local/share/fonts\""])
            }
            Chip { text: "Atualizar lista"; onClicked: refresh.running = true }
        }
    }
}
