import QtQuick 2.9
import QtQuick.Controls 2.2
import "ui" as Ui

import SdlGamepadKeyNavigation 1.0
import SystemProperties 1.0

// https://stackoverflow.com/questions/45029968/how-do-i-set-the-combobox-width-to-fit-the-largest-item
ComboBox {
    id: control
    property int textWidth
    property int desiredWidth : leftPadding + textWidth + indicator.width + rightPadding
    property int maximumWidth : parent.width

    implicitWidth: desiredWidth < maximumWidth ? desiredWidth : maximumWidth
    leftPadding: 14
    rightPadding: 38
    topPadding: 8
    bottomPadding: 8

    background: Rectangle {
        radius: 6
        color: control.enabled
               ? (control.pressed
                  ? (window ? window.surfaceInsetColor : "#0d0d10")
                  : (window ? window.surfaceColor : "#111113"))
               : "#101012"
        border.width: 1
        border.color: control.visualFocus
                      ? (window ? window.accentColor : "#fafafa")
                      : (window ? window.borderColor : "#27272a")
    }

    contentItem: Text {
        leftPadding: 0
        rightPadding: control.indicator.width + control.spacing
        text: control.displayText
        font: control.font
        color: control.enabled ? "#fafafa" : "#71717a"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Ui.UiIcon {
        x: control.width - width - control.rightPadding + 14
        y: control.topPadding + (control.availableHeight - height) / 2
        source: "qrc:/res/lucide/chevron-down.svg"
        iconSize: 14
        iconOpacity: control.enabled ? 1.0 : 0.45
    }

    TextMetrics {
        id: popupMetrics
    }

    TextMetrics {
        id: textMetrics
    }

    function recalculateWidth() {
        textMetrics.font = font
        popupMetrics.font = popup.font
        textWidth = 0
        for (var i = 0; i < count; i++){
            textMetrics.text = textAt(i)
            popupMetrics.text = textAt(i)
            textWidth = Math.max(textMetrics.width, textWidth)
            textWidth = Math.max(popupMetrics.width, textWidth)
        }
    }

    // We call this every time the options change (and init)
    // so we can adjust the combo box width here too
    onActivated: recalculateWidth()

    popup.onAboutToShow: {
        // Switch to normal navigation for combo boxes
        SdlGamepadKeyNavigation.setUiNavMode(false)

        popup.background.color = window ? window.elevatedSurfaceColor : "#151518"
    }

    popup.onAboutToHide: {
        SdlGamepadKeyNavigation.setUiNavMode(true)
    }

    popup.background: Rectangle {
        radius: 6
        color: window ? window.elevatedSurfaceColor : "#151518"
        border.width: 1
        border.color: window ? window.borderColor : "#27272a"
    }
}
