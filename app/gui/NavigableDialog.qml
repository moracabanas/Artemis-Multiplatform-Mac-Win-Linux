import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "ui" as Ui

Dialog {
    id: dialog

    // We should use Overlay.overlay here but that's not available in Qt 5.9 :(
    parent: ApplicationWindow.contentItem
    modal: true
    dim: false
    padding: 20

    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    background: Rectangle {
        radius: 8
        color: window ? window.elevatedSurfaceColor : "#151518"
        border.width: 1
        border.color: window ? window.borderStrongColor : "#3f3f46"
    }

    function standardButton(button) {
        if (button === Dialog.Ok) {
            return okButton
        }
        if (button === Dialog.Cancel) {
            return cancelButton
        }
        if (button === Dialog.Yes) {
            return yesButton
        }
        if (button === Dialog.No) {
            return noButton
        }
        if (button === Dialog.Help) {
            return helpButton
        }

        return null
    }

    footer: Item {
        implicitHeight: footerRow.visible ? footerRow.implicitHeight + 8 : 0

        RowLayout {
            id: footerRow
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            spacing: 8
            visible: dialog.standardButtons !== Dialog.NoButton

            Ui.UiButton {
                id: helpButton
                visible: dialog.standardButtons & Dialog.Help
                text: qsTr("Help")
                tone: "muted"
                onClicked: dialog.helpRequested()
            }

            Ui.UiButton {
                id: noButton
                visible: dialog.standardButtons & Dialog.No
                text: qsTr("No")
                tone: "muted"
                onClicked: dialog.reject()
            }

            Ui.UiButton {
                id: cancelButton
                visible: dialog.standardButtons & Dialog.Cancel
                text: qsTr("Cancel")
                tone: "muted"
                onClicked: dialog.reject()
            }

            Ui.UiButton {
                id: yesButton
                visible: dialog.standardButtons & Dialog.Yes
                text: qsTr("Yes")
                onClicked: dialog.accept()
            }

            Ui.UiButton {
                id: okButton
                visible: dialog.standardButtons & Dialog.Ok
                text: qsTr("OK")
                onClicked: dialog.accept()
            }
        }
    }

    onAboutToHide: {
        // We must force focus back to the last item for platforms without
        // support for more than one active window like Steam Link. If
        // we don't, gamepad and keyboard navigation will break after a
        // dialog appears.
        stackView.forceActiveFocus()
    }
}
