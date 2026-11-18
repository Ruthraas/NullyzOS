pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.theme

// Som (PipeWire): volume e mudo da saída padrão. `available` = PipeWire conectado e com saída.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool available: Pipewire.ready && !!(sink && sink.audio)
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: available ? sink.audio.muted : false
    readonly property string icon: !available || muted || volume <= 0.001 ? Icons.volumeOff
        : volume < 0.5 ? Icons.volumeLow : Icons.volumeHigh
    readonly property string label: !available ? "Sem saída de som" : (muted ? "Mudo" : Math.round(volume * 100) + "%")

    function setVolume(v) { if (available) sink.audio.volume = Math.max(0, Math.min(1, v)); }
    function toggleMute() { if (available) sink.audio.muted = !sink.audio.muted; }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
}
