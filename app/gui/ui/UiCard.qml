import QtQuick 2.9

Rectangle {
    id: card

    property string tone: "surface"
    property int cornerRadius: 8

    radius: cornerRadius
    border.width: 1
    border.color: window ? window.borderColor : "#27272a"
    color: {
        if (!window) {
            return "#111113"
        }

        if (tone === "raised") {
            return window.elevatedSurfaceColor
        }
        if (tone === "inset") {
            return window.surfaceInsetColor
        }
        if (tone === "muted") {
            return window.surfaceMutedColor
        }

        return window.surfaceColor
    }
}
