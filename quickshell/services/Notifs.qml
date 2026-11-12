//
// The notification daemon: owns org.freedesktop.Notifications on the session
// bus, in swaync's old place.
//
// Only one process can own that name, and the first to ask wins - so if swaync
// (or dunst, or mako) is still running, this server never registers and every
// notification keeps going to the other one, with nothing on screen saying so.
//
// Each notification is wrapped in a Notif, for two reasons. The server has no
// idea what a popup is, so the popup state (up, absorbing, held by the pointer)
// has to live somewhere. And the server destroys its Notification as soon as it
// closes, which is exactly when the popup still has an animation to play - so
// the wrapper freezes a copy of everything the card draws at that moment.
//
// Two lists, not one filtered one: `list` is the history (what the server still
// tracks) and `popups` is what the top-right drawer holds. A dismissed popup has
// to leave the history immediately but stay in the drawer until it has been
// absorbed back into the frame.
//
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config

Singleton {
    id: root

    // History, newest first
    property list<Notif> list: []
    // The drawer, newest first, including popups still being absorbed
    property list<Notif> popups: []

    // Survives a reload: rewriting Scheme.qml on every wallpaper or mode change
    // reloads the whole config, and do-not-disturb silently switching itself off
    // on a theme change is the kind of thing nobody notices until a meeting.
    property alias dnd: persist.dnd

    readonly property int count: list.length

    PersistentProperties {
        id: persist

        reloadableId: "notifs"

        property bool dnd: false
        // When each notification in the history arrived, as JSON of id ->
        // epoch ms. The server keeps notifications across a reload but not
        // when they came, and the wrappers are rebuilt, so without this every
        // theme change restamped the whole history "now". A string because a
        // plain property type is certain to survive the hand-over. Ids restart
        // with quickshell, but so does this.
        property string times: "{}"
    }

    NotificationServer {
        id: server

        // Keeps the bus name and the tracked notifications across a reload, so
        // history survives a theme change. The wrappers don't, and are rebuilt
        // from what it re-announces - see onNotification.
        keepOnReload: true

        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true

        // Emitted when Quickshell hands this generation the server (see live)
        onTrackedNotificationsChanged: root.live = true

        onNotification: notification => {
            // A transient notification exists only as a popup, so one that
            // will never pop up - under do-not-disturb, or re-announced after
            // a reload - is left untracked, and the server discards it when
            // this returns. Expiring it from here would do nothing: the server
            // only learns the id once this handler is done.
            if (notification.transient && (notification.lastGeneration || (root.dnd && notification.urgency !== NotificationUrgency.Critical)))
                return;

            // Untracked notifications are discarded as soon as this returns -
            // including a duplicate, so this comes before the check below
            notification.tracked = true;

            // Delivered twice when both the watchdog and Quickshell's own
            // handover connected this server
            if (root.list.some(n => n.notification === notification))
                return;

            // After a reload the server announces everything it kept, flagged
            // lastGeneration. Those go back into the history without popping
            // up a second time.
            root.add(notification, !notification.lastGeneration);
        }
    }

    // Whether this generation's server is the one receiving notifications.
    //
    // Quickshell only connects a reloaded NotificationServer to its handler in
    // a post-reload hook (onPostReload in services/notifications/qml.cpp),
    // which fires when the previous generation finishes being destroyed. Twice
    // while this was being built, right after a burst of file writes, a reload
    // came up with the server still owning the bus name and answering on it
    // but nothing in QML connected: every notification was accepted and then
    // silently dropped, until quickshell was restarted. The hook not firing is
    // the likely cause, not a proven one - ~50 reloads afterwards, overlapping
    // ones included, never reproduced it - so treat this as a safety net whose
    // recovery path has not been exercised. That code is unchanged in
    // quickshell master as of 0.3.2.
    //
    // A server that went live emitted trackedNotificationsChanged. One that
    // hasn't within a few seconds gets the hook run by hand, and says so in
    // `qs log`.
    property bool live: false

    Timer {
        interval: 3000
        running: !root.live

        onTriggered: {
            console.warn("Notifs: the reload never handed this generation the notification server; connecting it by hand");
            server.postReload();
        }
    }

    function add(notification: Notification, pop: bool): void {
        // A re-announced notification keeps the time it first arrived
        const times = JSON.parse(persist.times);
        const kept = notification.lastGeneration ? times[notification.id] : undefined;
        const time = kept ? new Date(kept) : new Date();

        // A new arrival means any re-announcing is over, so whatever isn't in
        // the history by now never will be. Pruning during the re-announce
        // would throw away times for notifications not yet re-added.
        if (!notification.lastGeneration)
            for (const id of Object.keys(times))
                if (!list.some(n => String(n.notifId) === id))
                    delete times[id];

        times[notification.id] = time.getTime();
        persist.times = JSON.stringify(times);

        const notif = notifComp.createObject(root, {
            notification,
            notifId: notification.id,
            time
        });
        list = [notif, ...list];

        if (pop)
            notif.raise();

        // Drop the oldest past the cap. dismiss() closes it on the bus too, so
        // the sender knows it is gone rather than holding a dead id. Over a
        // slice rather than `while (too long)`, which would spin forever on
        // the UI thread if a dismissal ever failed to shorten the list.
        for (const n of list.slice(Config.notifs.maxHistory))
            n.dismiss();
    }

    function clear(): void {
        // Copied first: each dismiss() rewrites `list` under the loop
        for (const n of [...list])
            n.dismiss();
    }

    // Drops a closed notification's arrival time from the persisted record
    function forget(id: int): void {
        const times = JSON.parse(persist.times);
        delete times[id];
        persist.times = JSON.stringify(times);
    }

    // Called by the drawer once a popup has finished being absorbed
    function absorbed(notif: Notif): void {
        if (!notif.listed || notif.popup)
            return;
        notif.listed = false;
        popups = popups.filter(n => n !== notif);
        if (notif.closed)
            notif.destroy();
    }

    // Relative time for the card header. `now` is passed in so the caller's
    // binding depends on the clock and re-evaluates every minute.
    function ago(time: date, now: date): string {
        const mins = Math.floor((now - time) / 60000);
        if (mins < 1)
            return "now";
        if (mins < 60)
            return `${mins}m`;
        const hours = Math.floor(mins / 60);
        if (hours < 24)
            return `${hours}h`;
        return Qt.formatDateTime(time, "d MMM");
    }

    // Something usable as an Image source for the app icon, or "". Senders
    // give a theme icon name, an absolute path or a file:// URL, and plenty
    // give nothing but a desktop entry.
    function iconSource(icon: string, entry: string): string {
        const name = icon || (entry ? DesktopEntries.byId(entry)?.icon ?? "" : "");
        if (!name)
            return "";
        if (name.includes("://"))
            return name;
        if (name.startsWith("/"))
            return "file://" + name.split("/").map(encodeURIComponent).join("/");
        return Quickshell.iconPath(name, true);
    }

    Component {
        id: notifComp

        Notif {}
    }

    component Notif: QtObject {
        id: notif

        required property Notification notification
        // Copied out, since the notification can be gone by the time it is
        // needed (dropping its arrival time from the persisted record)
        required property int notifId
        // When it arrived - before the last reload, for a re-announced one
        required property date time

        // Up in the drawer. False while it is being absorbed.
        property bool popup: false
        // In the drawer at all, absorbing included. Only absorbed() clears it.
        property bool listed: false
        // The pointer is on it, which holds the timeout
        property bool hovered: false
        // Gone from the server; the frozen copy below is all that is left
        property bool closed: false

        // Bound while the notification lives - a sender replacing one by id
        // updates these in place - and frozen by freeze() when it closes
        property string summary: notification?.summary ?? ""
        property string body: notification?.body ?? ""
        property string appName: notification?.appName ?? ""
        // libnotify's `-i` arrives as an image-path hint, which Quickshell
        // hands over as image://icon/<name>. That is a theme icon rather than
        // a picture, and the icon provider answers a missing one with a
        // magenta checkerboard that still loads - so it is moved to the icon
        // slot, where a name that doesn't resolve comes back empty.
        readonly property string themedImage: (notification?.image ?? "").startsWith("image://icon/") ? notification.image.slice(13) : ""
        property string image: themedImage ? "" : notification?.image ?? ""
        property string icon: root.iconSource(notification?.appIcon || themedImage, notification?.desktopEntry ?? "")
        property bool critical: notification?.urgency === NotificationUrgency.Critical
        // Plain objects rather than the NotificationActions, which die with
        // their notification
        property var actions: (notification?.actions ?? []).map(a => ({
                    identifier: a.identifier,
                    text: a.text
                }))

        readonly property bool hasDefault: actions.some(a => a.identifier === "default")
        readonly property var buttons: actions.filter(a => a.identifier !== "default")

        // expireTimeout is in ms as the sender gave it (-1 when it gave none),
        // and 0 or less means "your call"
        readonly property int timeout: {
            if (critical)
                return 0;
            const t = notification?.expireTimeout ?? 0;
            return t > 0 ? t : Config.notifs.defaultTimeout;
        }

        readonly property Timer timer: Timer {
            interval: Math.max(1, notif.timeout)
            running: notif.popup && !notif.hovered && notif.timeout > 0
            onTriggered: notif.popup = false
        }

        // Transient ones were never meant for the history, so they go however
        // the popup does: timed out, clicked away, or pushed out by a newer
        // one. Not when drop() is what cleared popup - that one is already
        // closing, and expiring it there would close it a second time.
        onPopupChanged: if (!popup && !closed && notification?.transient)
            notification.expire()

        readonly property Connections conn: Connections {
            target: notif.notification

            function onClosed(): void {
                notif.drop();
            }

            // A sender updating a notification in place (notify-send -r, a
            // download's progress) means it has something new to say
            function onSummaryChanged(): void {
                notif.raise();
            }

            function onBodyChanged(): void {
                notif.raise();
            }
        }

        // Pop up, or stay up for another full timeout if already up
        function raise(): void {
            if (closed || (root.dnd && !critical))
                return;

            popup = true;
            // restart() starts the timer whatever `running` is bound to, so it
            // is guarded by the same condition: a critical one has no timeout,
            // and unguarded it got a 1ms timer and vanished as it appeared
            if (!hovered && timeout > 0)
                timer.restart();

            if (!listed) {
                listed = true;
                root.popups = [notif, ...root.popups];
            }

            // Make room by absorbing the oldest one still up
            const up = root.popups.filter(n => n.popup);
            for (let i = up.length - 1; i >= Config.notifs.maxPopups; i--)
                up[i].popup = false;
        }

        function dismiss(): void {
            if (notification)
                notification.dismiss();
            else
                drop();
        }

        // Out of the history now; out of the drawer once it has been absorbed
        function drop(): void {
            if (closed)
                return;
            freeze();
            closed = true;
            popup = false;
            root.list = root.list.filter(n => n !== notif);
            root.forget(notifId);
            if (!listed)
                notif.destroy();
        }

        function invoke(identifier: string): void {
            const action = (notification?.actions ?? []).find(a => a.identifier === identifier);
            // invoke() dismisses a non-resident notification by itself
            if (action)
                action.invoke();
            popup = false;
        }

        // Assigning a property drops its binding, so this pins every value at
        // what it is now, before the notification it is bound to goes away
        function freeze(): void {
            summary = summary;
            body = body;
            appName = appName;
            image = image;
            icon = icon;
            critical = critical;
            actions = actions;
        }
    }
}
