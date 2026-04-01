import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "ui" as Ui

import ServerCommandManager 1.0

Ui.UiCard {
    id: quickMenu
    width: 560
    height: 440
    tone: "raised"
    cornerRadius: 8
    visible: true
    opacity: 1.0
    focus: visible

    property string currentMenu: "main"
    property string toastMessage: ""
    property bool showToast: false

    ListModel {
        id: serverCommandsModel
    }

    ListModel {
        id: mainMenuModel

        ListElement {
            text: qsTr("Disconnect")
            iconSource: "qrc:/res/lucide/square.svg"
            action: "disconnect"
            description: qsTr("Disconnect from the current host session")
        }
        ListElement {
            text: qsTr("Quit")
            iconSource: "qrc:/res/lucide/power.svg"
            action: "quit"
            description: qsTr("Close the current streaming session")
        }
        ListElement {
            text: qsTr("Server Commands")
            iconSource: "qrc:/res/lucide/server.svg"
            action: "server_commands"
            description: qsTr("Open Apollo power and automation controls")
        }
        ListElement {
            text: qsTr("Clipboard Upload")
            iconSource: "qrc:/res/lucide/upload.svg"
            action: "clipboard_upload"
            description: qsTr("Send clipboard contents to the host")
        }
        ListElement {
            text: qsTr("Fetch Clipboard")
            iconSource: "qrc:/res/lucide/download.svg"
            action: "clipboard_fetch"
            description: qsTr("Fetch the current clipboard from the host")
        }
        ListElement {
            text: qsTr("Toggle Performance Stats")
            iconSource: "qrc:/res/lucide/activity.svg"
            action: "toggle_stats"
            description: qsTr("Show or hide the streaming performance overlay")
        }
        ListElement {
            text: qsTr("Toggle Mouse Capture")
            iconSource: "qrc:/res/lucide/mouse-pointer-2.svg"
            action: "toggle_mouse"
            description: qsTr("Switch the current mouse capture mode")
        }
        ListElement {
            text: qsTr("Toggle Keyboard Capture")
            iconSource: "qrc:/res/lucide/keyboard.svg"
            action: "toggle_keyboard"
            description: qsTr("Switch how keyboard shortcuts are captured")
        }
        ListElement {
            text: qsTr("Toggle Fullscreen")
            iconSource: "qrc:/res/lucide/maximize.svg"
            action: "toggle_fullscreen"
            description: qsTr("Toggle fullscreen for the current stream")
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 160 }
    }

    onCurrentMenuChanged: {
        menuListView.currentIndex = 0
    }

    function panelTitle() {
        return currentMenu === "main" ? qsTr("Quick Menu") : qsTr("Server Commands")
    }

    function panelDescription() {
        return currentMenu === "main"
                ? qsTr("Session controls, clipboard tools, and capture toggles.")
                : qsTr("Apollo host actions exposed to this client during the current session.")
    }

    function panelIcon() {
        return currentMenu === "main" ? "qrc:/res/lucide/gamepad-2.svg" : "qrc:/res/lucide/server.svg"
    }

    function commandIcon(commandId) {
        var normalized = commandId.toLowerCase()
        if (normalized.indexOf("shutdown") >= 0) {
            return "qrc:/res/lucide/power.svg"
        }
        if (normalized.indexOf("restart") >= 0) {
            return "qrc:/res/lucide/refresh-cw.svg"
        }
        if (normalized.indexOf("suspend") >= 0 || normalized.indexOf("sleep") >= 0) {
            return "qrc:/res/lucide/moon.svg"
        }
        return "qrc:/res/lucide/server.svg"
    }

    function closeMenuDelayed() {
        closeTimer.restart()
    }

    function closeMenu() {
        if (typeof quickMenuManager !== "undefined") {
            showActionFeedback(qsTr("Closing menu..."))
            quickMenuManager.hide()
        }
    }

    function executeCurrentItem() {
        var currentItem = menuListView.model.get(menuListView.currentIndex)
        if (currentItem) {
            executeAction(currentItem.action)
        }
    }

    function executeAction(action) {
        if (action === "server_commands") {
            if (quickMenuManager.serverCommandManager && quickMenuManager.serverCommandManager.hasPermission) {
                currentMenu = "server_commands"
            }
            else {
                showActionFeedback(qsTr("Server commands are not available for this session."))
                closeMenuDelayed()
            }
            return
        }

        for (var i = 0; i < serverCommandsModel.count; i++) {
            if (serverCommandsModel.get(i).action === action) {
                if (quickMenuManager.serverCommandManager) {
                    quickMenuManager.serverCommandManager.executeCommand(action)
                    closeMenuDelayed()
                }
                return
            }
        }

        showActionFeedback(messageForAction(action))
        if (typeof quickMenuManager !== "undefined") {
            quickMenuManager.executeAction(action)
        }
        closeMenuDelayed()
    }

    function messageForAction(action) {
        switch (action) {
        case "disconnect":
            return qsTr("Disconnecting from the current host...")
        case "quit":
            return qsTr("Quitting the current session...")
        case "clipboard_upload":
            return qsTr("Uploading clipboard to the host...")
        case "clipboard_fetch":
            return qsTr("Fetching clipboard from the host...")
        case "toggle_stats":
            return qsTr("Toggling performance stats...")
        case "toggle_mouse":
            return qsTr("Switching mouse capture mode...")
        case "toggle_keyboard":
            return qsTr("Switching keyboard capture mode...")
        case "toggle_fullscreen":
            return qsTr("Toggling fullscreen...")
        default:
            return qsTr("Executing action...")
        }
    }

    function showActionFeedback(message) {
        toastMessage = message
        showToast = true
        toastTimer.restart()
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            closeMenu()
        }
        else if (event.key === Qt.Key_Up) {
            menuListView.decrementCurrentIndex()
        }
        else if (event.key === Qt.Key_Down) {
            menuListView.incrementCurrentIndex()
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            executeCurrentItem()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Ui.UiCard {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                tone: "inset"
                cornerRadius: 6

                Ui.UiIcon {
                    anchors.centerIn: parent
                    source: panelIcon()
                    iconSize: 18
                }
            }

            Ui.UiSectionHeader {
                Layout.fillWidth: true
                eyebrow: currentMenu === "main" ? qsTr("SESSION") : qsTr("APOLLO")
                title: panelTitle()
                description: panelDescription()
            }
        }

        ListView {
            id: menuListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !(currentMenu === "server_commands" && serverCommandsModel.count === 0)
            focus: true
            clip: true
            spacing: 8
            currentIndex: 0
            model: currentMenu === "main" ? mainMenuModel : serverCommandsModel

            delegate: Button {
                width: menuListView.width
                height: 72
                flat: true

                background: Ui.UiCard {
                    tone: (parent.down || parent.hovered || menuListView.currentIndex === index) ? "muted" : "surface"
                    cornerRadius: 6
                    border.width: menuListView.currentIndex === index ? 2 : 1
                    border.color: menuListView.currentIndex === index
                                  ? (window ? window.accentColor : "#fafafa")
                                  : (window ? window.borderColor : "#27272a")
                }

                onClicked: executeAction(model.action)

                contentItem: RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Ui.UiCard {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        tone: "inset"
                        cornerRadius: 6

                        Ui.UiIcon {
                            anchors.centerIn: parent
                            source: model.iconSource
                            iconSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Label {
                            text: model.text
                            color: window ? window.textColor : "#fafafa"
                            font.pointSize: 13
                            font.bold: true
                        }

                        Label {
                            text: model.description
                            color: window ? window.mutedTextColor : "#a1a1aa"
                            font.pointSize: 10
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }

        Ui.UiEmptyState {
            Layout.fillWidth: true
            visible: currentMenu === "server_commands" && serverCommandsModel.count === 0
            iconSource: "qrc:/res/lucide/server.svg"
            title: qsTr("No server commands exposed")
            body: qsTr("This Apollo host has not exposed server-side actions to the current client or the session does not have permission to execute them.")
        }

        RowLayout {
            Layout.fillWidth: true

            Ui.UiButton {
                id: closeButton
                text: currentMenu === "main" ? qsTr("Close") : qsTr("Back")
                tone: "muted"
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    if (currentMenu === "main") {
                        closeMenu()
                    }
                    else {
                        currentMenu = "main"
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                text: currentMenu === "main" ? qsTr("Esc") : qsTr("Enter to run")
                color: window ? window.subtleTextColor : "#71717a"
                font.pointSize: 10
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    Ui.UiCard {
        id: toastNotification
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 18
        width: Math.min(parent.width - 36, toastText.implicitWidth + 28)
        height: 38
        tone: "muted"
        cornerRadius: 6
        visible: showToast
        opacity: showToast ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Label {
            id: toastText
            text: toastMessage
            color: window ? window.textColor : "#fafafa"
            font.pointSize: 11
            anchors.centerIn: parent
        }
    }

    Timer {
        id: toastTimer
        interval: 2000
        onTriggered: showToast = false
    }

    Timer {
        id: closeTimer
        interval: 1000
        onTriggered: closeMenu()
    }

    Connections {
        target: quickMenuManager.serverCommandManager

        function onCommandsRefreshed() {
            serverCommandsModel.clear()
            var commandIds = quickMenuManager.serverCommandManager.getAvailableCommands()
            for (var i = 0; i < commandIds.length; i++) {
                var commandId = commandIds[i]
                serverCommandsModel.append({
                    iconSource: quickMenu.commandIcon(commandId),
                    text: quickMenuManager.serverCommandManager.getCommandName(commandId),
                    action: commandId,
                    description: quickMenuManager.serverCommandManager.getCommandDescription(commandId)
                })
            }
        }

        function onCommandExecuted(commandId, success, result) {
            showActionFeedback(success
                               ? qsTr("Command '%1' executed successfully").arg(commandId)
                               : qsTr("Command '%1' failed: %2").arg(commandId).arg(result))
        }
    }
}
