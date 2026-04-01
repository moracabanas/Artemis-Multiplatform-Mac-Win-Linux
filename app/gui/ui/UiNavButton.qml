import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

Button {
    id: control

    property string iconSource
    property bool active: false
    property string supportingText: ""

    implicitHeight: supportingText !== "" ? 58 : 44
    leftPadding: 12
    rightPadding: 12
    topPadding: 10
    bottomPadding: 10

    background: Rectangle {
        radius: 6
        border.width: control.active || control.visualFocus ? 1 : 1
        border.color: control.active
                      ? (window ? window.accentColor : "#fafafa")
                      : ((control.visualFocus || control.hovered)
                         ? (window ? window.borderStrongColor : "#3f3f46")
                         : (window ? window.borderColor : "#27272a"))
        color: control.active
               ? (window ? window.surfaceMutedColor : "#1c1c21")
               : (control.down
                  ? (window ? window.surfaceInsetColor : "#0d0d10")
                  : "transparent")
    }

    contentItem: RowLayout {
        spacing: 10

        UiIcon {
            iconSize: 16
            source: control.iconSource
            Layout.alignment: Qt.AlignVCenter
            iconOpacity: control.enabled
                         ? ((control.active || control.hovered || control.visualFocus) ? 1.0 : 0.82)
                         : 0.45
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Label {
                text: control.text
                color: window ? window.textColor : "#fafafa"
                font {
                    family: control.font.family
                    pointSize: control.font.pointSize > 0 ? control.font.pointSize : 11
                    weight: Font.DemiBold
                }
                opacity: control.enabled ? 1.0 : 0.45
            }

            Label {
                visible: control.supportingText !== ""
                text: control.supportingText
                color: window ? window.mutedTextColor : "#a1a1aa"
                font.pointSize: 9
                wrapMode: Text.Wrap
                opacity: control.enabled ? 1.0 : 0.45
                Layout.fillWidth: true
            }
        }
    }
}
