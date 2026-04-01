import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "ui" as Ui

import ServerCommandManager 1.0

Ui.UiCard {
    id: serverCommandsCard
    width: parent.width
    implicitHeight: contentColumn.implicitHeight + 28
    height: implicitHeight
    tone: "inset"
    cornerRadius: 8

    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Ui.UiSectionHeader {
            width: parent.width
            title: qsTr("Server commands")
            description: qsTr("Execute actions on an Apollo host during a streaming session. Availability depends on the host permission system.")
        }

        GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            Ui.UiButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: qsTr("Restart Server")
                enabled: ServerCommandManager.hasPermission && !ServerCommandManager.isExecuting
                onClicked: {
                    confirmDialog.commandId = "restart_server"
                    confirmDialog.commandName = qsTr("Restart Server")
                    confirmDialog.commandDescription = qsTr("This restarts the host streaming service and disconnects the current session.")
                    confirmDialog.open()
                }
            }

            Ui.UiButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: qsTr("Shutdown Server")
                enabled: ServerCommandManager.hasPermission && !ServerCommandManager.isExecuting
                onClicked: {
                    confirmDialog.commandId = "shutdown_server"
                    confirmDialog.commandName = qsTr("Shutdown Server")
                    confirmDialog.commandDescription = qsTr("This shuts down the host computer and disconnects the current session.")
                    confirmDialog.open()
                }
            }

            Ui.UiButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: qsTr("Suspend Server")
                enabled: ServerCommandManager.hasPermission && !ServerCommandManager.isExecuting
                onClicked: {
                    confirmDialog.commandId = "suspend_computer"
                    confirmDialog.commandName = qsTr("Suspend Computer")
                    confirmDialog.commandDescription = qsTr("This suspends the host computer and disconnects the current session.")
                    confirmDialog.open()
                }
            }

            Ui.UiButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: qsTr("Custom Command")
                enabled: ServerCommandManager.hasPermission && !ServerCommandManager.isExecuting
                onClicked: {
                    customCommandDialog.open()
                }
            }
        }

        Label {
            width: parent.width
            text: qsTr("These controls show up in-session when the active Apollo host exposes them and your client is allowed to execute them.")
            font.pointSize: 10
            wrapMode: Text.Wrap
            color: window ? window.mutedTextColor : "#a1a1aa"
        }
    }

    NavigableDialog {
        id: confirmDialog
        width: Math.min(420, parent.width - 48)
        standardButtons: Dialog.Yes | Dialog.No

        property string commandId: ""
        property string commandName: ""
        property string commandDescription: ""

        Column {
            spacing: 12
            width: parent.width

            Label {
                width: parent.width
                text: confirmDialog.commandName
                font.pointSize: 14
                font.bold: true
                color: window ? window.textColor : "#fafafa"
                wrapMode: Text.Wrap
            }

            Label {
                width: parent.width
                text: confirmDialog.commandDescription
                font.pointSize: 11
                color: window ? window.mutedTextColor : "#a1a1aa"
                wrapMode: Text.Wrap
            }
        }

        onAccepted: {
            ServerCommandManager.executeCommand(commandId)
        }
    }

    NavigableDialog {
        id: customCommandDialog
        width: Math.min(420, parent.width - 48)
        standardButtons: Dialog.Ok | Dialog.Cancel

        Column {
            spacing: 12
            width: parent.width

            Label {
                width: parent.width
                text: qsTr("Enter a custom command to execute on the host.")
                font.pointSize: 11
                color: window ? window.textColor : "#fafafa"
                wrapMode: Text.Wrap
            }

            Ui.UiInput {
                id: customCommandField
                width: parent.width
                placeholderText: qsTr("custom-script.sh")
            }

            Label {
                width: parent.width
                text: qsTr("Only execute commands you trust. Custom commands may be disabled or handled differently by the host.")
                font.pointSize: 10
                color: window ? window.mutedTextColor : "#a1a1aa"
                wrapMode: Text.Wrap
            }
        }

        onAccepted: {
            if (customCommandField.text.trim() !== "") {
                ServerCommandManager.executeCustomCommand(customCommandField.text.trim())
                customCommandField.text = ""
            }
        }

        onRejected: {
            customCommandField.text = ""
        }
    }

    Connections {
        target: ServerCommandManager

        function onCommandExecuted(commandId, success, message) {
            if (success) {
                successToast.text = qsTr("Command '%1' executed successfully").arg(commandId)
                successToast.show()
            } else {
                errorToast.text = qsTr("Command '%1' failed: %2").arg(commandId).arg(message)
                errorToast.show()
            }
        }

        function onCommandFailed(commandId, error) {
            errorToast.text = qsTr("Command '%1' failed: %2").arg(commandId).arg(error)
            errorToast.show()
        }
    }

    Rectangle {
        id: successToast
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(320, parent.width * 0.85)
        height: 42
        radius: 6
        color: window ? window.surfaceMutedColor : "#1c1c21"
        border.width: 1
        border.color: window ? window.borderStrongColor : "#3f3f46"
        visible: false

        property string text: ""

        Label {
            anchors.centerIn: parent
            text: successToast.text
            color: window ? window.textColor : "#fafafa"
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
        }

        function show() {
            visible = true
            hideTimer.start()
        }

        Timer {
            id: hideTimer
            interval: 3000
            onTriggered: successToast.visible = false
        }
    }

    Rectangle {
        id: errorToast
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(320, parent.width * 0.85)
        height: 42
        radius: 6
        color: window ? window.surfaceMutedColor : "#1c1c21"
        border.width: 1
        border.color: window ? window.borderStrongColor : "#3f3f46"
        visible: false

        property string text: ""

        Label {
            anchors.centerIn: parent
            text: errorToast.text
            color: window ? window.textColor : "#fafafa"
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
        }

        function show() {
            visible = true
            errorHideTimer.start()
        }

        Timer {
            id: errorHideTimer
            interval: 3500
            onTriggered: errorToast.visible = false
        }
    }
}
