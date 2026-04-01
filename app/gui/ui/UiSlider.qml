import QtQuick 2.9
import QtQuick.Controls 2.2

Slider {
    id: control

    implicitHeight: 28

    background: Item {
        implicitWidth: control.availableWidth
        implicitHeight: 4

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 4
            radius: 2
            color: window ? window.surfaceMutedColor : "#1c1c21"
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: control.visualPosition * parent.width
            height: 4
            radius: 2
            color: window ? window.accentColor : "#fafafa"
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 16
        height: 16
        radius: 4
        color: control.pressed ? "#e4e4e7" : "#ffffff"
        border.width: 1
        border.color: control.visualFocus
                      ? (window ? window.accentColor : "#fafafa")
                      : "#09090b"
    }
}
