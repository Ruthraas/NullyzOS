import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Wallpapers: os seus fundos (padrão Nullyz + pasta Imagens), ajuste,
// escurecer e trocar sozinho; e a galeria online por categoria (anime, natureza, espaço…,
// do Wallhaven; e os do KDE Plasma, licenças livres) com busca. Baixar salva em
// Imagens/Wallpapers, aplica e anota de onde veio em CREDITOS.txt.
SettingsPage {
    id: page
    title: "Wallpapers"
    subtitle: "O fundo da área de trabalho. Os seus ou da galeria online."

    property var images: []
    readonly property string current: Prefs.currentWallpaper
    property var gallery: []            // [{ id, name, author, license, thumb, full }]
    property bool galleryLoading: false
    property bool galleryFailed: false
    property int galleryShown: 12
    property string category: "anime"
    property int galleryPage: 1
    readonly property var categories: [["anime", "Anime"], ["natureza", "Natureza"], ["espaco", "Espaço"],
        ["minimalista", "Minimalista"], ["cidades", "Cidades"], ["escuro", "Escuro"], ["kde", "KDE Plasma"]]
    Component.onCompleted: loadGallery()
    property string downloading: ""     // id em download

    readonly property string script: Qt.resolvedUrl("../scripts/galeria.sh").toString().replace("file://", "")

    function loadLocal() { if (!local.running) local.running = true; }
    // Usa um fundo: no Hyprland o shell desenha (Prefs); no KDE também vai para o Plasma.
    readonly property bool kde: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").indexOf("KDE") >= 0
    function use(path) {
        const padrao = path === Prefs.defaultWallpaper;
        Prefs.set("wallpaper", padrao ? "" : path);
        if (kde) Quickshell.execDetached(["plasma-apply-wallpaperimage", padrao ? "/usr/share/wallpapers/Nullyz" : path]);
    }
    // Categoria nova (ou busca) começa do zero; "Mostrar mais" pede a próxima página.
    function loadGallery(more) {
        if (galleryLoading) return;
        galleryLoading = true; galleryFailed = false;
        if (!more) { gallery = []; galleryPage = 1; galleryShown = 12; }
        else galleryPage++;
        galleryProc.append = !!more;
        galleryProc.command = category === "kde" ? ["sh", page.script]
            : ["sh", page.script, "wallhaven", category, String(galleryPage), query.text];
        galleryProc.running = true;
    }
    function pick(c) { if (c === category && gallery.length) return; category = c; loadGallery(false); }
    function download(w) {
        if (downloading) return;
        downloading = w.id;
        dl.command = ["sh", page.script, "baixar", w.full, w.name, w.author || "?", w.license || "?"];
        dl.running = true;
    }

    Process {
        id: local
        running: true
        command: ["sh", Qt.resolvedUrl("../scripts/wallpapers.sh").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                // O padrão sempre primeiro; o resto na ordem das pastas.
                const list = text.split("\n").filter(l => l !== "" && l !== Prefs.defaultWallpaper);
                list.unshift(Prefs.defaultWallpaper);
                if (!list.includes(page.current)) list.push(page.current);
                page.images = list;
            }
        }
    }
    Process {
        id: galleryProc
        property bool append: false
        stdout: StdioCollector {
            onStreamFinished: {
                const got = text.split("\n").filter(l => l.split("\t").length >= 6).map(l => {
                    const f = l.split("\t");
                    return { id: f[0], name: f[1], author: f[2], license: f[3], thumb: f[4], full: f[5] };
                });
                page.gallery = galleryProc.append ? page.gallery.concat(got) : got;
                if (galleryProc.append) page.galleryShown = page.gallery.length;
                page.galleryFailed = page.gallery.length === 0;
                page.galleryLoading = false;
            }
        }
    }
    Process {
        id: dl
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim();
                if (path) { page.use(path); page.loadLocal(); }
            }
        }
        onExited: code => { page.downloading = ""; if (code !== 0) page.galleryFailed = true; }
    }

    // ---- os seus --------------------------------------------------------------------------
    Txt { text: "Seus fundos"; font.weight: Font.DemiBold }
    Flow {
        width: parent.width
        spacing: 12
        Repeater {
            model: page.images
            SettingsThumb {
                required property string modelData
                path: modelData
                selected: modelData === page.current
                onPicked: page.use(modelData)
            }
        }
    }
    Row {
        spacing: 8
        Txt { anchors.verticalCenter: parent.verticalCenter; text: "Os da pasta Imagens aparecem aqui."; muted: true; size: 13 }
        Chip { text: "Abrir a pasta"; height: 28; onClicked: Quickshell.execDetached(["sh", "-c", "xdg-open \"$(xdg-user-dir PICTURES)\""]) }
    }

    SettingsRow {
        title: "Ajuste da imagem"
        description: "Preencher corta as sobras; Ajustar mostra a imagem inteira; Centralizar usa o tamanho original."
        Segmented {
            options: [["preencher", "Preencher"], ["ajustar", "Ajustar"], ["centralizar", "Centralizar"]]
            current: Prefs.wallpaperFit
            onPicked: v => Prefs.set("wallpaperFit", v)
        }
    }
    SettingsRow {
        title: "Escurecer o fundo"
        description: Prefs.wallpaperDim > 0 ? Math.round(Prefs.wallpaperDim * 100) + "% mais escuro" : "Sem escurecer"
        Slider {
            width: 220
            value: Prefs.wallpaperDim / 0.6
            onMoved: v => Prefs.set("wallpaperDim", Math.round(v * 0.6 * 100) / 100)
        }
    }
    SettingsRow {
        title: "Trocar sozinho"
        description: "Passa para o próximo dos seus fundos de tempos em tempos."
        Segmented {
            options: [[0, "Não"], [15, "15 min"], [60, "1 hora"], [1440, "1 dia"]]
            current: Prefs.wallpaperCycle
            onPicked: v => Prefs.set("wallpaperCycle", v)
        }
    }

    Item { width: 1; height: 8 }

    // ---- galeria online ---------------------------------------------------------------------
    Item {
        width: parent.width; height: 22
        Txt { anchors.verticalCenter: parent.verticalCenter; text: "Galeria online"; font.weight: Font.DemiBold }
        Txt {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            text: page.category === "kde" ? "KDE Plasma · licenças livres" : "wallhaven.cc · só SFW, 1920×1080 ou mais"
            muted: true; size: 12
        }
    }
    Flow {
        width: parent.width
        spacing: 8
        Repeater {
            model: page.categories
            Chip {
                required property var modelData
                text: modelData[1]
                active: page.category === modelData[0]
                onClicked: { query.text = ""; page.pick(modelData[0]); }
            }
        }
    }
    Rectangle {
        width: parent.width; height: 38
        radius: Tok.rButton + 2
        color: Tok.surfaceHi
        border { width: 1; color: query.activeFocus ? Tok.accent : Tok.border }
        Ico { x: 12; anchors.verticalCenter: parent.verticalCenter; size: 15; d: Icons.search; color: Tok.muted }
        TextInput {
            id: query
            anchors { fill: parent; leftMargin: 36; rightMargin: 12 }
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Tok.text
            font { family: Tok.font; pixelSize: Math.round(14 * Tok.fontScale) }
            Keys.onReturnPressed: if (text.trim()) { page.category = "busca"; page.loadGallery(false); }
        }
        Txt { x: 36; anchors.verticalCenter: parent.verticalCenter; visible: query.text === ""; text: "Procurar (em inglês): cyberpunk, mountains, ghibli… e Enter"; muted: true }
    }
    Txt {
        visible: page.gallery.length === 0
        width: parent.width
        text: page.galleryLoading ? "Buscando…" : page.galleryFailed ? "Não deu para buscar agora (sem internet?)." : "Nada encontrado."
        muted: true; size: 13
    }
    Flow {
        visible: page.gallery.length > 0
        width: parent.width
        spacing: 12
        Repeater {
            model: page.gallery.slice(0, page.galleryShown)
            Item {
                id: gw
                required property var modelData
                width: 200; height: 150
                Rectangle {
                    id: frame
                    width: parent.width; height: 112
                    radius: Tok.rButton + 2
                    color: Tok.surfaceHi
                    clip: true
                    scale: gArea.pressed ? 0.96 : (gArea.containsMouse ? 1.03 : 1)
                    Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                    Image {
                        anchors { fill: parent; margins: 2 }
                        source: gw.modelData.thumb
                        sourceSize: Qt.size(400, 224)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: Tok.panel } }
                    }
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border { width: 1; color: Tok.edge }
                    }
                    // Baixando: véu com a mensagem
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: Tok.scrim
                        visible: page.downloading === gw.modelData.id
                        Txt { anchors.centerIn: parent; text: "Baixando…"; size: 13; font.weight: Font.DemiBold }
                    }
                    MouseArea {
                        id: gArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.download(gw.modelData)
                        Accessible.name: "Usar " + gw.modelData.name
                    }
                }
                Column {
                    anchors { top: frame.bottom; topMargin: 6 }
                    width: parent.width
                    Txt { width: parent.width; text: gw.modelData.name; size: 13; font.weight: Font.Medium }
                    Txt { width: parent.width; text: gw.modelData.id.startsWith("wh-") ? (gw.modelData.author ? "fonte: " + gw.modelData.author : "wallhaven.cc") : (gw.modelData.author ? "por " + gw.modelData.author : ""); muted: true; size: 11 }
                }
            }
        }
    }
    Chip {
        visible: page.gallery.length > 0
        text: page.galleryLoading ? "Buscando…" : "Mostrar mais"
        onClicked: {
            if (page.gallery.length > page.galleryShown) page.galleryShown += 12;
            else if (page.category !== "kde") page.loadGallery(true);
        }
    }
    Txt {
        visible: page.gallery.length > 0
        width: parent.width
        text: page.category === "kde"
            ? "Clique para baixar e usar. Ficam em Imagens/Wallpapers, com o autor e a licença em CREDITOS.txt."
            : "Clique para baixar e usar. Cada imagem é do artista ou da obra de origem: serve de fundo, não para redistribuir. A fonte fica anotada em Imagens/Wallpapers/CREDITOS.txt."
        muted: true; size: 12
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
}
