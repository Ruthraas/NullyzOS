import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services
import qs.components

// Configurações → Monitores: resolução, taxa de atualização e escala de cada tela.
// Depois de mudar, pergunta se quer manter; sem resposta em 15 s volta ao que era (se a tela
// apagou com o modo novo, ninguém fica preso).
SettingsPage {
    id: page
    title: "Monitores"
    subtitle: "Resolução, taxa de atualização e tamanho dos itens na tela."

    property var mons: []
    property string previous: ""       // regras antes da última mudança (para voltar)
    property int countdown: 0

    function refresh() { if (!query.running) query.running = true; }
    function parseMode(s) {
        const m = /^(\d+)x(\d+)@([\d.]+)/.exec(s);
        return m ? { w: +m[1], h: +m[2], hz: Math.round(+m[3]) } : null;
    }
    function apply(name, rule) {
        if (page.countdown === 0) page.previous = JSON.stringify(HyprConf.monitors);
        HyprConf.setMonitor(name, rule);
        page.countdown = 15;
        tick.restart();
        later.restart();
    }
    function keep() { page.countdown = 0; tick.stop(); }
    function revert() {
        page.countdown = 0;
        tick.stop();
        HyprConf.setMonitors(page.previous || "{}");
        later.restart();
    }

    Process {
        id: query
        running: true
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: { try { page.mons = JSON.parse(text); } catch (e) { page.mons = []; } }
        }
    }
    Timer { id: later; interval: 900; onTriggered: page.refresh() }
    Timer {
        id: tick
        interval: 1000; repeat: true
        onTriggered: { page.countdown -= 1; if (page.countdown <= 0) page.revert(); }
    }

    // ---- confirmação -----------------------------------------------------------------
    Rectangle {
        visible: page.countdown > 0
        width: parent.width; height: visible ? 64 : 0
        radius: Tok.rField
        color: Tok.selection
        border { width: 1; color: Tok.accent }
        Txt {
            x: 16; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 260
            text: "Manter estas configurações? Volta sozinho em " + page.countdown + " s."
            wrapMode: Text.Wrap
            elide: Text.ElideNone
        }
        Row {
            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
            spacing: 8
            Chip { text: "Voltar"; onClicked: page.revert() }
            Chip { text: "Manter"; active: true; onClicked: page.keep() }
        }
    }

    Repeater {
        model: page.mons
        Rectangle {
            id: mon
            required property var modelData
            readonly property var modes: (modelData.availableModes || []).map(page.parseMode).filter(m => m)
            readonly property var sizes: {
                const seen = {}, out = [];
                for (const m of mon.modes) {
                    const k = m.w + "x" + m.h;
                    if (!seen[k]) { seen[k] = true; out.push({ w: m.w, h: m.h }); }
                }
                // As 8 maiores e sempre a atual (mesmo que seja menor).
                out.sort((a, b) => b.w * b.h - a.w * a.h);
                const top = out.slice(0, 8);
                const cur = out.find(s => s.w === mon.modelData.width && s.h === mon.modelData.height);
                if (cur && !top.includes(cur)) top.push(cur);
                return top;
            }
            readonly property var rates: {
                const out = [];
                for (const m of mon.modes)
                    if (m.w === mon.modelData.width && m.h === mon.modelData.height && !out.includes(m.hz)) out.push(m.hz);
                return out.sort((a, b) => b - a);
            }
            readonly property int hz: Math.round(modelData.refreshRate || 60)
            readonly property string mode: modelData.width + "x" + modelData.height + "@" + hz
            function setMode(w, h, hz) { page.apply(modelData.name, { mode: w + "x" + h + "@" + hz, scale: modelData.scale || 1 }); }

            width: parent.width
            height: inner.implicitHeight + 32
            radius: Tok.rField
            color: Tok.surface
            border { width: 1; color: Tok.border }

            Column {
                id: inner
                x: 16; y: 16
                width: parent.width - 32
                spacing: 12

                Column {
                    spacing: 2
                    Txt { text: mon.modelData.description || mon.modelData.name; font.weight: Font.DemiBold }
                    Txt {
                        muted: true; size: 13
                        text: mon.modelData.width + " × " + mon.modelData.height + " · " + mon.hz + " Hz · tamanho "
                              + Math.round((mon.modelData.scale || 1) * 100) + "%"
                              + (mon.modelData.description ? " · " + mon.modelData.name : "")
                    }
                }

                Txt { text: "Resolução"; muted: true; size: 13}
                Flow {
                    width: parent.width
                    spacing: 8
                    Repeater {
                        model: mon.sizes
                        Chip {
                            required property var modelData
                            text: modelData.w + " × " + modelData.h
                            active: modelData.w === mon.modelData.width && modelData.h === mon.modelData.height
                            onClicked: {
                                // Mesma taxa se existir nessa resolução, senão a maior.
                                const r = mon.modes.filter(m => m.w === modelData.w && m.h === modelData.h).map(m => m.hz);
                                mon.setMode(modelData.w, modelData.h, r.includes(mon.hz) ? mon.hz : Math.max(...r));
                            }
                        }
                    }
                }

                Txt { visible: mon.rates.length > 1; text: "Taxa de atualização"; muted: true; size: 13}
                Flow {
                    visible: mon.rates.length > 1
                    width: parent.width
                    spacing: 8
                    Repeater {
                        model: mon.rates
                        Chip {
                            required property int modelData
                            text: modelData + " Hz"
                            active: modelData === mon.hz
                            onClicked: mon.setMode(mon.modelData.width, mon.modelData.height, modelData)
                        }
                    }
                }

                Txt { text: "Tamanho dos itens"; muted: true; size: 13}
                Flow {
                    width: parent.width
                    spacing: 8
                    Repeater {
                        model: [1, 1.25, 1.5, 1.75, 2]
                        Chip {
                            required property real modelData
                            text: Math.round(modelData * 100) + "%"
                            active: Math.abs((mon.modelData.scale || 1) - modelData) < 0.01
                            onClicked: page.apply(mon.modelData.name, { mode: mon.mode, scale: modelData })
                        }
                    }
                }
            }
        }
    }

    Txt {
        visible: page.mons.length === 0
        text: "Procurando monitores…"
        muted: true
    }
}
