import QtQuick 2.9
import QtQuick.Controls 2.2

Column {
    id: header

    property string eyebrow
    property string title
    property string description

    spacing: 4

    Label {
        visible: header.eyebrow !== ""
        width: parent.width
        text: header.eyebrow
        color: window ? window.mutedTextColor : "#a1a1aa"
        font.pointSize: 9
        font.bold: true
    }

    Label {
        width: parent.width
        text: header.title
        color: window ? window.textColor : "#fafafa"
        font.pointSize: 16
        font.bold: true
        wrapMode: Text.Wrap
    }

    Label {
        visible: header.description !== ""
        width: parent.width
        text: header.description
        color: window ? window.mutedTextColor : "#a1a1aa"
        font.pointSize: 10
        wrapMode: Text.Wrap
    }
}
