// Layout do NullyzOS no Plasma: barra em cima (N que abre o menu, menu global do app, bandeja
// e relógio) e dock flutuante embaixo (só ícones, do tamanho do conteúdo). Fundo Nullyz.
var fundo = "file:///usr/share/wallpapers/Nullyz/";   // pacote de wallpaper (o Plasma escolhe o tamanho)

var barra = new Panel;
barra.location = "top";
barra.height = Math.round(gridUnit * 1.6);
barra.floating = false;

var menu = barra.addWidget("org.kde.plasma.kickoff");
menu.currentConfigGroup = ["General"];
menu.writeConfig("icon", "nullyzos-symbolic");   // segue a cor do tema
menu.writeConfig("favoritesPortedToKAstats", true);

barra.addWidget("org.kde.plasma.appmenu");
barra.addWidget("org.kde.plasma.panelspacer");
barra.addWidget("org.kde.plasma.systemtray");
var relogio = barra.addWidget("org.kde.plasma.digitalclock");
relogio.currentConfigGroup = ["Appearance"];
relogio.writeConfig("showDate", true);
relogio.writeConfig("dateFormat", "shortDate");
relogio.writeConfig("use24hFormat", 2);

var dock = new Panel;
dock.location = "bottom";
dock.height = Math.round(gridUnit * 3.4);
dock.floating = true;
dock.lengthMode = "fit";
dock.alignment = "center";
dock.hiding = "none";   // sempre visível, como um dock
var tarefas = dock.addWidget("org.kde.plasma.icontasks");
tarefas.currentConfigGroup = ["General"];
tarefas.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:com.brave.Browser.desktop",
    "applications:nullyzos-configuracoes-kde.desktop"   // as do KDE: pela página "Sistema do KDE"
]);
tarefas.writeConfig("iconSpacing", 2);
tarefas.writeConfig("maxStripes", 1);

var telas = desktops();
for (var i = 0; i < telas.length; i++) {
    telas[i].wallpaperPlugin = "org.kde.image";
    telas[i].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    telas[i].writeConfig("Image", fundo);
}
