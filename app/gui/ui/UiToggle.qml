import QtQuick 2.9
import QtQuick.Controls 2.2

CheckBox {
    id: control

    spacing: 10
    padding: 0

    indicator: Rectangle {
        implicitWidth: 16
        implicitHeight: 16
        radius: 3
        x: control.leftPadding
        y: control.height / 2 - height / 2
        border.width: 1
        border.color: control.visualFocus
                      ? (window ? window.accentColor : "#fafafa")
                      : (window ? window.borderStrongColor : "#3f3f46")
        color: control.checked ? (window ? window.accentColor : "#fafafa") : (window ? window.surfaceInsetColor : "#0d0d10")

        Rectangle {
            anchors.centerIn: parent
            visible: control.checked
            width: 7
            height: 7
            radius: 1
            color: "#09090b"
        }
    }

    contentItem: Label {
        text: control.text
        leftPadding: control.indicator.width + control.spacing
        color: window ? window.textColor : "#fafafa"
        verticalAlignment: Text.AlignVCenter
        font: control.font
        wrapMode: Text.Wrap
        opacity: control.enabled ? 1.0 : 0.5
    }
}
