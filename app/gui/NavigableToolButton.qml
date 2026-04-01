import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "ui" as Ui

ToolButton {
    id: control
    property string iconSource

    activeFocusOnTab: true
    implicitWidth: 38
    implicitHeight: 38
    padding: 9

    background: Rectangle {
        radius: 6
        color: control.down
               ? (window ? window.surfaceInsetColor : "#0d0d10")
               : ((control.hovered || control.visualFocus)
                  ? (window ? window.surfaceMutedColor : "#1c1c21")
                  : (window ? window.surfaceColor : "#111113"))
        border.width: 1
        border.color: control.visualFocus
                      ? (window ? window.accentColor : "#fafafa")
                      : ((control.hovered || control.down)
                         ? (window ? window.borderStrongColor : "#3f3f46")
                         : (window ? window.borderColor : "#27272a"))
    }

    Ui.UiIcon {
        source: iconSource
        anchors.centerIn: parent
        iconOpacity: control.enabled ? 1.0 : 0.55
        iconSize: 16
    }
    Layout.preferredHeight: implicitHeight

    Keys.onReturnPressed: {
        clicked()
    }

    Keys.onEnterPressed: {
        clicked()
    }

    Keys.onRightPressed: {
        nextItemInFocusChain(true).forceActiveFocus(Qt.TabFocus)
    }

    Keys.onLeftPressed: {
        nextItemInFocusChain(false).forceActiveFocus(Qt.TabFocus)
    }
}
