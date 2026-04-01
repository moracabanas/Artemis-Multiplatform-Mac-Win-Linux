import QtQuick 2.9
import QtQuick.Controls 2.2

Button {
    id: control

    property string tone: "default"

    implicitHeight: 38
    leftPadding: 14
    rightPadding: 14
    topPadding: 8
    bottomPadding: 8

    background: Rectangle {
        radius: 6
        border.width: 1
        border.color: control.visualFocus
                      ? (window ? window.accentColor : "#fafafa")
                      : (window ? window.borderColor : "#27272a")
        opacity: control.enabled ? 1.0 : 0.45
        color: {
            if (control.tone === "ghost") {
                return control.down ? (window ? window.surfaceInsetColor : "#0d0d10")
                                    : "transparent"
            }
            if (control.tone === "muted") {
                return control.down ? (window ? window.surfaceInsetColor : "#0d0d10")
                                    : (window ? window.surfaceMutedColor : "#1c1c21")
            }

            return control.down ? (window ? window.surfaceInsetColor : "#0d0d10")
                                : (window ? window.surfaceColor : "#111113")
        }
    }

    contentItem: Label {
        text: control.text
        color: window ? window.textColor : "#fafafa"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: control.font.family
            pointSize: control.font.pointSize > 0 ? control.font.pointSize : 11
            weight: Font.DemiBold
        }
        opacity: control.enabled ? 1.0 : 0.45
    }
}
