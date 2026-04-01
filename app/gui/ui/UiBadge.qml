import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: badge

    property string text
    property string tone: "default"

    implicitWidth: badgeLabel.implicitWidth + 16
    implicitHeight: badgeLabel.implicitHeight + 10
    radius: 6
    border.width: 1
    border.color: tone === "strong" ? (window ? window.accentColor : "#fafafa") : (window ? window.borderColor : "#27272a")
    color: tone === "strong" ? (window ? window.accentColor : "#fafafa") : (window ? window.surfaceInsetColor : "#0d0d10")

    Label {
        id: badgeLabel
        anchors.centerIn: parent
        text: badge.text
        color: tone === "strong" ? "#09090b" : (window ? window.textColor : "#fafafa")
        font.pointSize: 9
        font.bold: true
    }
}
