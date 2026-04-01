import QtQuick 2.9
import QtQuick.Controls 2.2

UiCard {
    id: emptyState

    property string iconSource
    property string title
    property string body
    property bool busy: false

    tone: "raised"
    cornerRadius: 8

    implicitHeight: contentColumn.implicitHeight + 32

    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Item {
            width: 32
            height: 32

            BusyIndicator {
                anchors.fill: parent
                visible: emptyState.busy
                running: visible
            }

            UiIcon {
                anchors.centerIn: parent
                visible: !emptyState.busy
                source: emptyState.iconSource
                iconSize: 24
            }
        }

        Label {
            width: parent.width
            text: emptyState.title
            color: window ? window.textColor : "#fafafa"
            font.pointSize: 18
            font.bold: true
            wrapMode: Text.Wrap
        }

        Label {
            width: parent.width
            text: emptyState.body
            color: window ? window.mutedTextColor : "#a1a1aa"
            wrapMode: Text.Wrap
        }
    }
}
