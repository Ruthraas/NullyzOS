import QtQuick
import Quickshell
import qs.theme
import qs.services
import qs.components

// Configurações Nullyz no KDE → Aparência: tema claro/escuro e cor de destaque (esquema de
// cores Nullyz do Plasma), vidro nos painéis, velocidade das animações e lado dos botões das
// janelas. Tudo aplica na hora; vale só no KDE (o Hyprland tem a dele).
SettingsPage {
    id: page
    title: "Aparência"
    subtitle: "Cores, vidro, animações e janelas do KDE."

    readonly property bool light: Prefs.theme === "claro"
    function hexOf(name, lt) { const a = Tok.accents[name] || Tok.accents.violeta; return String(lt ? a.light : a.color); }
    // Tema ou destaque escolhidos à mão: sai do rice (paleta) e volta ao Nullyz escuro/claro
    function applyColors(theme, accent) {
        Prefs.setMany({ theme: theme, accent: accent, palette: "" });
        Quickshell.execDetached(["sh", "-c", "rm -f \"${XDG_CONFIG_HOME:-$HOME/.config}/nullyzos/rice-kde\""]);
        Kde.applyColors(theme === "claro" ? "NullyzClaro" : "NullyzEscuro", hexOf(accent, theme === "claro"));
        Kde.setGlass(Prefs.kdeGlass, theme === "claro");
    }

    SettingsRow {
        title: "Tema"
        description: Prefs.palette ? "Agora com as cores do rice " + (Tok.scheme ? Tok.scheme.name : "") + ". Escolher aqui volta para o Nullyz." : "Escuro ou claro, em tudo: painéis, janelas e apps."
        Segmented {
            options: [["escuro", "Escuro"], ["claro", "Claro"]]
            current: Prefs.palette ? "" : Prefs.theme
            onPicked: v => page.applyColors(v, Tok.accents[Prefs.accent] ? Prefs.accent : "violeta")
        }
    }

    Item {
        width: parent.width; height: 20
        Txt { text: "Cor de destaque"; font.weight: Font.DemiBold }
    }
    Row {
        spacing: 14
        Repeater {
            model: Tok.accentOrder
            Item {
                id: dot
                required property string modelData
                readonly property bool chosen: !Prefs.palette && Prefs.accent === modelData
                width: 36; height: 36
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border { width: 2; color: Tok.accents[dot.modelData].color }
                    scale: dot.chosen ? 1 : 0.6
                    opacity: dot.chosen ? 1 : 0
                    Behavior on scale { NumberAnimation { duration: Tok.panel; easing.type: Easing.OutBack } }
                    Behavior on opacity { NumberAnimation { duration: Tok.fast } }
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 26; height: 26; radius: 13
                    color: Tok.accents[dot.modelData].color
                    scale: dotArea.pressed ? 0.85 : (dotArea.containsMouse ? 1.1 : 1)
                    Behavior on scale { NumberAnimation { duration: Tok.fast; easing.type: Easing.OutBack } }
                }
                MouseArea {
                    id: dotArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.applyColors(Prefs.palette ? "escuro" : Prefs.theme, dot.modelData)
                    Accessible.name: "Cor " + Tok.accents[dot.modelData].name
                }
            }
        }
    }

    Item { width: 1; height: 6 }

    // Cores do wallpaper: só o destaque (recurso do Plasma) ou tudo (esquema de cores gerado
    // do wallpaper do Plasma, como o Material You). "Tudo" lê o fundo aqui e gera o esquema.
    SettingsRow {
        title: "Cores do wallpaper"
        description: Prefs.palette === "wallpaper" ? "Tudo sai do fundo: janelas, painéis, menus e apps."
            : Prefs.wallpaperTint ? "A cor de destaque sai do fundo e acompanha quando ele troca."
            : "Deixe o KDE pegar as cores do seu wallpaper."
        Segmented {
            readonly property bool wall: Prefs.palette === "wallpaper"
            options: [["nao", "Não"], ["destaque", "Só o destaque"], ["tudo", "Tudo"]]
            current: wall ? "tudo" : Prefs.wallpaperTint ? "destaque" : "nao"
            onPicked: v => {
                if (v === "tudo") {
                    Prefs.setMany({ palette: "wallpaper", accent: "tema", wallpaperTint: false });
                    Kde.setAccentFromWallpaper(false);
                    Kde.readWallpaper();
                    regen.restart();
                } else {
                    Kde.setAccentFromWallpaper(v === "destaque");
                    if (wall) page.applyColors(Prefs.theme === "claro" ? "claro" : "escuro", "violeta");
                    Prefs.set("wallpaperTint", v === "destaque");
                }
            }
        }
    }
    // Lê o wallpaper do Plasma e, com as cores no Tok, gera e aplica o esquema
    WallpaperSampler {
        source: Prefs.palette === "wallpaper" ? Kde.wallpaperUrl : ""
        onPainted: if (Prefs.palette === "wallpaper") regen.restart()   // cores lidas → esquema novo
    }
    Timer { id: regen; interval: 1500; onTriggered: if (Prefs.palette === "wallpaper") Kde.applyWallpaperColors() }
    Connections {
        target: Kde
        function onWallpaperUrlChanged() { if (Prefs.palette === "wallpaper") regen.restart(); }
    }
    // As preferências chegam do arquivo depois de a página abrir: lê o fundo quando a paleta
    // "wallpaper" aparece (e já na abertura, se ela já estiver lá)
    function startWall() { if (Prefs.palette === "wallpaper") { Kde.readWallpaper(); regen.restart(); } }
    Connections { target: Prefs; function onPaletteChanged() { page.startWall(); } }
    Component.onCompleted: startWall()
    SettingsRow {
        title: "Vidro"
        description: "Barra, dock e menus translúcidos, com o fundo desfocado por trás."
        Toggle {
            checked: Prefs.kdeGlass
            onToggled: v => { Prefs.set("kdeGlass", v); Kde.setGlass(v, page.light); }
        }
    }
    SettingsRow {
        title: "Animações"
        description: "Velocidade de abrir, fechar e trocar de janela."
        Segmented {
            options: [[0, "Desligadas"], [0.5, "Rápidas"], [1, "Normais"], [2, "Suaves"]]
            current: Prefs.kdeAnim
            onPicked: v => { Prefs.set("kdeAnim", v); Kde.setAnimations(v); }
        }
    }
    SettingsRow {
        title: "Botões das janelas"
        description: "Fechar, minimizar e maximizar: à esquerda (redondos coloridos) ou à direita."
        Segmented {
            options: [[true, "Esquerda"], [false, "Direita"]]
            current: Prefs.kdeButtonsLeft
            onPicked: v => { Prefs.set("kdeButtonsLeft", v); Kde.setButtonsLeft(v); }
        }
    }

    Txt {
        width: parent.width
        text: "Para trocar tudo de uma vez (paleta, cores e cantos), use Rices."
        muted: true; size: 12
        wrapMode: Text.Wrap; elide: Text.ElideNone
    }
}
