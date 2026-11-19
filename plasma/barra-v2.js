// Atualiza a barra de cima de quem já tinha o NullyzOS no KDE (rodado uma vez pelo
// kde-sessao): N, nome do app em foco, menu global, espaço, bandeja com som e rede à
// mostra, relógio. Mantém o N e as opções do relógio.
panels().forEach(function (p) {
    if (p.location !== "top") return;
    var h24 = 2, data = true, fmt = "shortDate";
    p.widgets().forEach(function (w) {
        if (w.type === "org.kde.plasma.digitalclock") {
            w.currentConfigGroup = ["Appearance"];
            h24 = w.readConfig("use24hFormat", 2);
            data = w.readConfig("showDate", true);
            fmt = w.readConfig("dateFormat", "shortDate");
        }
        if (w.type !== "org.kde.plasma.kickoff") w.remove();
    });
    p.addWidget("org.nullyzos.appname");
    p.addWidget("org.kde.plasma.appmenu");
    p.addWidget("org.kde.plasma.panelspacer");
    var bandeja = p.addWidget("org.kde.plasma.systemtray");
    try {
        var dentro = desktopById(bandeja.readConfig("SystrayContainmentId"));
        if (dentro) {
            dentro.currentConfigGroup = ["General"];
            dentro.writeConfig("shownItems", ["org.kde.plasma.volume", "org.kde.plasma.networkmanagement", "org.kde.plasma.battery"]);
        }
    } catch (e) {}
    var relogio = p.addWidget("org.kde.plasma.digitalclock");
    relogio.currentConfigGroup = ["Appearance"];
    relogio.writeConfig("showDate", data);
    relogio.writeConfig("dateFormat", fmt);
    relogio.writeConfig("use24hFormat", h24);
});
