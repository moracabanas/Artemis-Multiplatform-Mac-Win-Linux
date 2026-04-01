import QtQuick 2.9

Item {
    id: root

    property string source
    property int iconSize: 18
    property real iconOpacity: 1.0

    implicitWidth: iconSize
    implicitHeight: iconSize
    width: implicitWidth
    height: implicitHeight

    Image {
        anchors.fill: parent
        source: root.source
        opacity: root.iconOpacity
        sourceSize.width: root.iconSize
        sourceSize.height: root.iconSize
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
