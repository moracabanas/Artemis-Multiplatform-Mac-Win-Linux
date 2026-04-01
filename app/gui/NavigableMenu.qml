import QtQuick 2.0
import QtQuick.Controls 2.2

Menu {
    padding: 6
    implicitWidth: 240
    width: implicitWidth

    background: Rectangle {
        radius: 8
        color: window ? window.elevatedSurfaceColor : "#151518"
        border.width: 1
        border.color: window ? window.borderColor : "#27272a"
    }

    onOpened: {
        // Give focus to the first visible and enabled menu item
        for (var i = 0; i < count; i++) {
            var item = itemAt(i)
            if (item.visible && item.enabled) {
                item.forceActiveFocus(Qt.TabFocusReason)
                break
            }
        }
    }
}
