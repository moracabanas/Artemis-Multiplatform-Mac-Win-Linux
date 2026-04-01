import QtQuick 2.0
import QtQuick.Controls 2.2

MenuItem {
    id: control
    // Qt 5.10 has a menu property, but we need to support 5.9
    // so we must make our own.
    property Menu parentMenu

    // Ensure focus can't be given to an invisible item
    enabled: visible
    height: visible ? implicitHeight : 0
    focusPolicy: visible ? Qt.TabFocus : Qt.NoFocus
    leftPadding: 12
    rightPadding: 12
    topPadding: 10
    bottomPadding: 10
    implicitWidth: Math.max(220, menuLabel.implicitWidth + leftPadding + rightPadding + 24)
    implicitHeight: menuLabel.implicitHeight + topPadding + bottomPadding

    background: Rectangle {
        radius: 6
        color: control.highlighted ? (window ? window.surfaceMutedColor : "#1c1c21") : "transparent"
        border.width: 1
        border.color: control.highlighted ? (window ? window.borderStrongColor : "#3f3f46") : "transparent"
    }

    contentItem: Label {
        id: menuLabel
        text: control.text
        color: control.enabled
               ? (window ? window.textColor : "#fafafa")
               : (window ? window.mutedTextColor : "#a1a1aa")
        font.pointSize: 10
        font.bold: control.highlighted
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    onTriggered: {
        // We must close the context menu first or
        // it can steal focus from any dialogs that
        // onTriggered may spawn.
        parentMenu.close()
    }

    Keys.onReturnPressed: {
        triggered()
    }

    Keys.onEnterPressed: {
        triggered()
    }

    Keys.onEscapePressed: {
        parentMenu.close()
    }
}
