import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: toast
    width: 300
    height: 50
    radius: 16
    color: window ? window.elevatedSurfaceColor : "#151518"
    border.color: window ? window.borderStrongColor : "#3f3f46"
    border.width: 1
    opacity: 0.95
    
    property alias text: toastText.text
    
    Text {
        id: toastText
        anchors.centerIn: parent
        color: "#FFFFFF"
        font.pixelSize: 14
        font.bold: true
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    function showToast(message) {
        toast.text = message
        toast.opacity = 1.0
        return true
    }
}
