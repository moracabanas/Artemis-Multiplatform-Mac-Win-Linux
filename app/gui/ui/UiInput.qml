import QtQuick 2.9
import QtQuick.Controls 2.2

TextField {
    id: control

    leftPadding: 12
    rightPadding: 12
    topPadding: 10
    bottomPadding: 10
    color: window ? window.textColor : "#fafafa"
    selectedTextColor: "#09090b"
    selectionColor: window ? window.accentColor : "#fafafa"

    background: Rectangle {
        radius: 6
        color: window ? window.surfaceInsetColor : "#0d0d10"
        border.width: 1
        border.color: control.activeFocus
                      ? (window ? window.accentColor : "#fafafa")
                      : (window ? window.borderColor : "#27272a")
    }
}
