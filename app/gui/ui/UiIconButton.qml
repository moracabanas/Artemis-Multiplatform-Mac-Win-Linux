import QtQuick 2.9
import QtQuick.Controls 2.2

Button {
    id: control

    property string iconSource
    property int iconSize: 18

    implicitWidth: 38
    implicitHeight: 38
    leftPadding: 9
    rightPadding: 9
    topPadding: 9
    bottomPadding: 9

    background: Rectangle {
        radius: 6
        border.width: 1
        border.color: control.visualFocus
                      ? (window ? window.accentColor : "#fafafa")
                      : ((control.hovered || control.down)
                         ? (window ? window.borderStrongColor : "#3f3f46")
                         : (window ? window.borderColor : "#27272a"))
        color: control.down ? (window ? window.surfaceInsetColor : "#0d0d10")
                            : ((control.hovered || control.visualFocus)
                               ? (window ? window.surfaceMutedColor : "#1c1c21")
                               : (window ? window.surfaceColor : "#111113"))
    }

    contentItem: UiIcon {
        source: control.iconSource
        iconSize: control.iconSize
        anchors.centerIn: parent
    }
}
