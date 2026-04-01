import QtQuick 2.9
import QtQuick.Controls 2.2

SpinBox {
    id: control

    implicitHeight: 38
    editable: false

    contentItem: TextInput {
        text: control.textFromValue(control.value, control.locale)
        color: window ? window.textColor : "#fafafa"
        font: control.font
        readOnly: true
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        selectByMouse: false
    }

    background: Rectangle {
        radius: 6
        color: window ? window.surfaceInsetColor : "#0d0d10"
        border.width: 1
        border.color: control.visualFocus
                      ? (window ? window.accentColor : "#fafafa")
                      : (window ? window.borderColor : "#27272a")
    }

    up.indicator: Rectangle {
        implicitWidth: 28
        implicitHeight: control.height
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: "+"
            color: control.up.enabled ? (window ? window.textColor : "#fafafa") : (window ? window.subtleTextColor : "#71717a")
            font.pointSize: 12
            font.bold: true
        }
    }

    down.indicator: Rectangle {
        implicitWidth: 28
        implicitHeight: control.height
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: "-"
            color: control.down.enabled ? (window ? window.textColor : "#fafafa") : (window ? window.subtleTextColor : "#71717a")
            font.pointSize: 14
            font.bold: true
        }
    }
}
