pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

Item {
    id: root

    required property int index
    required property int activeWsId
    required property var occupied
    required property int groupOffset

    readonly property int ws: groupOffset + index + 1
    readonly property bool isOccupied: occupied[ws] ?? false
    readonly property bool focused: activeWsId === ws

    // Unanimated, for the active indicator and occupied background to key off
    readonly property int size: Appearance.sizes.bar.innerWidth - Appearance.padding.small

    // The focused workspace picks a random expressive shape every time focus
    // lands on it; the rest stay square (occupied) or circular (empty).
    readonly property list<int> focusedShapes: [MaterialShape.Slanted, MaterialShape.Oval, MaterialShape.Pill, MaterialShape.Triangle, MaterialShape.Diamond, MaterialShape.Pentagon, MaterialShape.Gem, MaterialShape.VerySunny, MaterialShape.Sunny, MaterialShape.Cookie4Sided, MaterialShape.Cookie6Sided, MaterialShape.Cookie7Sided, MaterialShape.Cookie9Sided, MaterialShape.Cookie12Sided, MaterialShape.Clover4Leaf, MaterialShape.SoftBurst]

    function updateShape(): void {
        const shape = indicator.item as MaterialShape;
        if (!shape)
            return;

        if (focused)
            shape.shape = focusedShapes[Math.floor(Math.random() * focusedShapes.length)];
        else
            shape.shape = Qt.binding(() => isOccupied ? MaterialShape.Square : MaterialShape.Circle);
    }

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: size
    implicitHeight: size

    onFocusedChanged: updateShape()
    Component.onCompleted: updateShape()

    Loader {
        id: indicator

        anchors.centerIn: parent
        sourceComponent: {
            switch (Config.bar.workspaces.displayType) {
            case "text":
                return textComponent;
            case "icons":
                return iconComponent;
            default:
                return shapeComponent;
            }
        }
        onItemChanged: root.updateShape()
    }

    Component {
        id: shapeComponent

        MaterialShape {
            implicitSize: root.size

            color: root.focused ? Colours.palette.m3onPrimary : root.isOccupied ? Colours.palette.m3onSurface : Colours.layer(Colours.palette.m3outlineVariant, 2)
            scale: root.focused ? 2 / 3 : root.isOccupied ? 1 / 3 : 1 / 4

            Behavior on scale {
                Anim {}
            }
        }
    }

    Component {
        id: iconComponent

        MaterialIcon {
            readonly property string overrideColour: Config.bar.workspaces.iconColours[root.ws - 1] ?? ""

            animate: true
            text: Config.bar.workspaces.icons[root.ws - 1] || Config.bar.workspaces.defaultIcon
            color: {
                if (root.focused)
                    return Colours.palette.m3onPrimary;
                if (overrideColour)
                    return Colours.role(overrideColour);
                return root.isOccupied ? Colours.palette.m3onSurface : Colours.layer(Colours.palette.m3outlineVariant, 2);
            }
            // The focused glyph fills in; the rest stay outlined
            fill: root.focused ? 1 : 0
            size: Appearance.font.size.iconSmall
        }
    }

    Component {
        id: textComponent

        StyledText {
            animate: true
            text: root.ws
            color: root.focused ? Colours.palette.m3onPrimary : root.isOccupied ? Colours.palette.m3onSurface : Colours.layer(Colours.palette.m3outlineVariant, 2)
            font.family: Appearance.font.family.workspaces
            font.pointSize: Appearance.font.size.smaller
        }
    }
}
