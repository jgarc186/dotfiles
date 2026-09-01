pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string osLogo: ""
    property string osName: "Linux"

    FileView {
        path: "/etc/os-release"
        onLoaded: {
            const logo = text().match(/^LOGO=\"?(.*?)\"?$/m);
            const name = text().match(/^PRETTY_NAME=\"?(.*?)\"?$/m);
            if (logo)
                root.osLogo = logo[1];
            if (name)
                root.osName = name[1];
        }
    }
}
