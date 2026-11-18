import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Apps: loja (Flathub: procurar, instalar, remover, sem senha) e os apps
// padrão (navegador, PDF, imagens, vídeo e música, texto, pastas), gravados com xdg-mime.
SettingsPage {
    id: page
    title: "Apps"
    subtitle: "Instalar apps do Flathub e escolher quais abrem cada tipo de arquivo."

    // [rótulo, tipos MIME, categoria do .desktop para sugerir]
    readonly property var kinds: [
        ["Navegador", ["x-scheme-handler/http", "x-scheme-handler/https", "text/html"], "WebBrowser"],
        ["PDF", ["application/pdf"], "Viewer"],
        ["Imagens", ["image/png", "image/jpeg", "image/webp", "image/gif"], "Graphics"],
        ["Vídeo e música", ["video/mp4", "video/x-matroska", "video/webm", "audio/mpeg", "audio/flac", "audio/ogg"], "AudioVideo"],
        ["Texto", ["text/plain"], "TextEditor"],
        ["Pastas", ["inode/directory"], "FileManager"]
    ]
    property var defaults: ({})         // rótulo → id do .desktop

    function candidates(cat) {
        return Apps.all.filter(e => (e.categories || []).includes(cat)).slice(0, 8);
    }
    function setDefault(kind, id) {
        Quickshell.execDetached(["xdg-mime", "default", id + ".desktop"].concat(kind[1]));
        const d = Object.assign({}, page.defaults);
        d[kind[0]] = id;
        page.defaults = d;
    }

    Process {
        running: true
        command: ["sh", "-c", "for m in x-scheme-handler/http application/pdf image/png video/mp4 text/plain inode/directory; do printf '%s ' $m; xdg-mime query default $m; echo; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const map = { "x-scheme-handler/http": "Navegador", "application/pdf": "PDF", "image/png": "Imagens",
                              "video/mp4": "Vídeo e música", "text/plain": "Texto", "inode/directory": "Pastas" };
                const d = {};
                for (const l of text.split("\n")) {
                    const f = l.trim().split(" ");
                    if (map[f[0]] && f[1]) d[map[f[0]]] = f[1].replace(/\.desktop$/, "");
                }
                page.defaults = d;
            }
        }
    }

    // ---- loja --------------------------------------------------------------------------
    Txt { text: "Instalar apps (Flathub)"; font.weight: Font.DemiBold }
    Rectangle {
        visible: !Flatpak.has("com.brave.Browser")
        width: parent.width; height: 64
        radius: Tok.rField
        color: Tok.selection
        border { width: 1; color: Tok.accent }
        Column {
            x: 16; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 200
            spacing: 2
            Txt { text: "Brave, o navegador do NullyzOS"; font.weight: Font.DemiBold }
            Txt { width: parent.width; text: "Rápido e com bloqueio de anúncios. Publicado pelo próprio Brave no Flathub."; muted: true; size: 12 }
        }
        Chip {
            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
            text: Flatpak.busy === "com.brave.Browser" ? "Instalando…" : "Instalar"
            active: true
            onClicked: Flatpak.install("com.brave.Browser")
        }
    }
    Rectangle {
        width: parent.width; height: 40
        radius: Tok.rButton + 2
        color: Tok.surfaceHi
        border { width: 1; color: search.activeFocus ? Tok.accent : Tok.border }
        Ico { x: 12; anchors.verticalCenter: parent.verticalCenter; size: 15; color: Tok.muted; d: Icons.search }
        TextInput {
            id: search
            anchors { fill: parent; leftMargin: 36; rightMargin: 12 }
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Tok.text
            font { family: Tok.font; pixelSize: Math.round(14 * Tok.fontScale) }
            onTextChanged: searchDelay.restart()
            Keys.onReturnPressed: Flatpak.search(text)
        }
        Txt { x: 36; anchors.verticalCenter: parent.verticalCenter; visible: search.text === ""; text: "Procurar no Flathub: spotify, discord, obs, gimp…"; muted: true }
        Timer { id: searchDelay; interval: 500; onTriggered: Flatpak.search(search.text) }
    }
    Txt { visible: Flatpak.searching; text: "Procurando…"; muted: true; size: 13 }
    Txt {
        visible: Flatpak.busy !== "" || Flatpak.error !== ""
        width: parent.width
        text: Flatpak.busy !== "" ? "Baixando " + Flatpak.busy + "… " + Flatpak.progress : Flatpak.error
        color: Flatpak.busy !== "" ? Tok.muted : Tok.error
        size: 12
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }

    component AppRow: Item {
        id: ar
        property string appId
        property string name
        property string desc
        property bool first: false
        width: parent ? parent.width : 0
        height: 54
        Column {
            x: 16; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 150
            spacing: 2
            Txt { width: parent.width; text: ar.name; font.weight: Font.DemiBold; size: 13 }
            Txt { width: parent.width; text: ar.desc || ar.appId; muted: true; size: 12 }
        }
        Chip {
            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
            text: Flatpak.busy === ar.appId ? "…" : Flatpak.has(ar.appId) ? "Remover" : "Instalar"
            active: !Flatpak.has(ar.appId)
            onClicked: Flatpak.has(ar.appId) ? Flatpak.remove(ar.appId) : Flatpak.install(ar.appId)
        }
        Rectangle {
            visible: !ar.first
            anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
            height: 1; color: Tok.border
        }
    }

    Rectangle {
        visible: Flatpak.results.length > 0
        width: parent.width; height: resCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: resCol
            width: parent.width
            Repeater {
                model: Flatpak.results
                AppRow { required property var modelData; required property int index; appId: modelData.id; name: modelData.name; desc: modelData.desc; first: index === 0 }
            }
        }
    }

    Txt { visible: Flatpak.installed.length > 0; text: "Instalados do Flathub"; font.weight: Font.DemiBold }
    Rectangle {
        visible: Flatpak.installed.length > 0
        width: parent.width; height: instCol.implicitHeight
        radius: Tok.rField
        color: Tok.surface
        border { width: 1; color: Tok.border }
        Column {
            id: instCol
            width: parent.width
            Repeater {
                model: Flatpak.installed
                AppRow { required property var modelData; required property int index; appId: modelData.id; name: modelData.name; first: index === 0 }
            }
        }
    }

    Item { width: 1; height: 6 }

    // ---- apps padrão -------------------------------------------------------------------
    Txt { text: "Apps padrão"; font.weight: Font.DemiBold }
    Repeater {
        model: page.kinds
        SettingsRow {
            id: kindRow
            required property var modelData
            title: modelData[0]
            description: {
                const id = page.defaults[modelData[0]];
                const e = id ? Apps.byId(id) : null;
                return e ? "Agora: " + e.name : (id ? "Agora: " + id : "Nenhum escolhido");
            }
            Flow {
                width: 300
                spacing: 6
                layoutDirection: Qt.RightToLeft
                Repeater {
                    model: page.candidates(kindRow.modelData[2])
                    Chip {
                        required property var modelData
                        text: modelData.name
                        active: page.defaults[kindRow.modelData[0]] === modelData.id
                        onClicked: page.setDefault(kindRow.modelData, modelData.id)
                    }
                }
            }
        }
    }
}
