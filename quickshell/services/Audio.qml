pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property real stepSize: 0.05

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted: source?.audio?.muted ?? false

    function setVolume(volume: real): void {
        if (sink?.ready && sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, volume));
    }

    function incrementVolume(amount: real): void {
        setVolume(volume + (amount || stepSize));
    }

    function decrementVolume(amount: real): void {
        setVolume(volume - (amount || stepSize));
    }

    function toggleMute(): void {
        if (sink?.ready && sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    // Pipewire only publishes volume/mute for nodes something is tracking
    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
