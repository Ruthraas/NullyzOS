pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Música e vídeo tocando (MPRIS: Spotify, navegador, Haruna...). O "atual" é o que está
// tocando; se nenhum está, o último que apareceu.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var player: players.find(p => p.isPlaying) || (players.length ? players[players.length - 1] : null)
    readonly property bool active: player !== null
    readonly property string title: player ? (player.trackTitle || player.identity || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""
    readonly property string art: player ? (player.trackArtUrl || "") : ""
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string app: player ? (player.identity || "") : ""

    function toggle() { if (player && player.canTogglePlaying) player.togglePlaying(); }
    function next() { if (player && player.canGoNext) player.next(); }
    function previous() { if (player && player.canGoPrevious) player.previous(); }
}
