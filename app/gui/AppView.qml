import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "ui" as Ui

import AppModel 1.0
import ComputerManager 1.0
import SdlGamepadKeyNavigation 1.0

CenteredGridView {
    property int computerIndex
    property AppModel appModel : createModel()
    property bool activated
    property bool showHiddenGames
    property bool showGames
    property color cardColor: window ? window.surfaceColor : "#18181b"
    property color cardBorderColor: window ? window.borderColor : "#2f2f35"
    property color accentColor: window ? window.accentColor : "#fafafa"

    id: appGrid
    focus: true
    activeFocusOnTab: true
    topMargin: 12
    bottomMargin: 8
    cellWidth: 256
    cellHeight: 228

    function appStateText(running, hidden, directLaunch) {
        if (running) {
            return qsTr("Running")
        }
        if (hidden) {
            return qsTr("Hidden")
        }
        if (directLaunch) {
            return qsTr("Direct launch")
        }
        return qsTr("Ready")
    }

    function appStateColor(running, hidden, directLaunch) {
        if (running) {
            return "#fafafa"
        }
        if (hidden) {
            return "#27272a"
        }
        if (directLaunch) {
            return "#e4e4e7"
        }
        return "#111113"
    }

    function appStateTextColor(running, hidden, directLaunch) {
        if (running || directLaunch) {
            return "#09090b"
        }

        return "#fafafa"
    }

    function appSummary(running, hidden, directLaunch) {
        if (running) {
            return qsTr("Resume the current session or quit it before launching something else.")
        }
        if (hidden) {
            return qsTr("Hidden from the normal grid. Use the context menu to unhide it.")
        }
        if (directLaunch) {
            return qsTr("Configured to launch immediately when this host is selected.")
        }
        return qsTr("Launch this app on the selected host.")
    }

    function actionText(running) {
        return running ? qsTr("Open actions to resume or quit") : qsTr("Click to launch")
    }

    function showLaunchPermissionDialog() {
        launchPermissionDialog.text = appModel.launchPermissionErrorText()
        launchPermissionDialog.helpText = qsTr("Use Help to open Apollo's permission guide.")
        launchPermissionDialog.open()
    }

    function computerLost()
    {
        // Go back to the PC view on PC loss
        stackView.pop()
    }

    Component.onCompleted: {
        // Don't show any highlighted item until interacting with them.
        // We do this here instead of onActivated to avoid losing the user's
        // selection when backing out of a different page of the app.
        currentIndex = -1
    }

    StackView.onActivated: {
        appModel.computerLost.connect(computerLost)
        activated = true

        // Highlight the first item if a gamepad is connected
        if (currentIndex == -1 && SdlGamepadKeyNavigation.getConnectedGamepads() > 0) {
            currentIndex = 0
        }

        if (!showGames && !showHiddenGames) {
            // Check if there's a direct launch app
            var directLaunchAppIndex = model.getDirectLaunchAppIndex();
            if (directLaunchAppIndex >= 0) {
                // Start the direct launch app if nothing else is running
                currentIndex = directLaunchAppIndex
                currentItem.launchOrResumeSelectedApp(false)

                // Set showGames so we will not loop when the stream ends
                showGames = true
            }
        }
    }

    StackView.onDeactivating: {
        appModel.computerLost.disconnect(computerLost)
        activated = false
    }

    function createModel()
    {
        var model = Qt.createQmlObject('import AppModel 1.0; AppModel {}', parent, '')
        model.initialize(ComputerManager, computerIndex, showHiddenGames)
        return model
    }

    model: appModel

    delegate: NavigableItemDelegate {
        id: appDelegate
        width: 240
        height: 220
        grid: appGrid
        hoverEnabled: true

        property alias appContextMenu: appContextMenuLoader.item

        // Dim the app if it's hidden
        opacity: model.hidden ? 0.78 : 1.0

        background: Ui.UiCard {
            cornerRadius: 8
            border.width: highlighted ? 2 : 1
            border.color: highlighted ? appGrid.accentColor : appGrid.cardBorderColor
            color: highlighted ? (window ? window.elevatedSurfaceColor : "#151518")
                               : (window ? window.surfaceColor : "#111113")
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Row {
                Layout.fillWidth: true
                spacing: 8

                Ui.UiBadge {
                    text: appGrid.appStateText(model.running, model.hidden, model.directLaunch)
                    tone: model.running || model.directLaunch ? "strong" : "default"
                }

                Ui.UiBadge {
                    visible: model.directLaunch && !model.running
                    text: qsTr("Quick launch")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: 6
                    color: window ? window.surfaceInsetColor : "#0d0d10"
                    border.width: 1
                    border.color: window ? window.borderColor : "#27272a"

                    Ui.UiIcon {
                        anchors.centerIn: parent
                        source: model.running ? "qrc:/res/lucide/power.svg" : "qrc:/res/lucide/gamepad-2.svg"
                        iconSize: 18
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Label {
                        id: appNameText
                        Layout.fillWidth: true
                        text: model.name
                        color: window ? window.textColor : "white"
                        font.pointSize: 16
                        font.bold: true
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: model.running
                              ? qsTr("Resume the existing session or quit it before launching something else.")
                              : (model.hidden
                                 ? qsTr("Hidden from the default grid.")
                                 : (model.directLaunch
                                    ? qsTr("Launches immediately when the host opens.")
                                    : qsTr("Ready to launch on the selected host.")))
                        color: window ? window.mutedTextColor : "#a1a1aa"
                        font.pointSize: 10
                        wrapMode: Text.Wrap
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: appGrid.appSummary(model.running, model.hidden, model.directLaunch)
                color: window ? window.mutedTextColor : "#a1a1aa"
                wrapMode: Text.Wrap
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: model.running

                Ui.UiButton {
                    Layout.fillWidth: true
                    text: qsTr("Resume")
                    onClicked: launchOrResumeSelectedApp(true)
                }

                Ui.UiButton {
                    Layout.fillWidth: true
                    text: qsTr("Quit")
                    tone: "muted"
                    onClicked: doQuitGame()
                }
            }
        }

        function launchOrResumeSelectedApp(quitExistingApp)
        {
            var runningId = appModel.getRunningAppId()
            var isResume = runningId === model.appid

            if (!isResume && appModel.isApolloHost() && !appModel.hasLaunchAppPermission()) {
                appGrid.showLaunchPermissionDialog()
                return
            }

            if (runningId !== 0 && runningId !== model.appid) {
                if (quitExistingApp) {
                    quitAppDialog.appName = appModel.getRunningAppName()
                    quitAppDialog.segueToStream = true
                    quitAppDialog.nextAppName = model.name
                    quitAppDialog.nextAppIndex = index
                    quitAppDialog.open()
                }

                return
            }

            var component = Qt.createComponent("StreamSegue.qml")
            var segue = component.createObject(stackView, {
                                                   "appName": model.name,
                                                   "session": appModel.createSessionForApp(index),
                                                   "isResume": isResume
                                               })
            stackView.push(segue)
        }

        onClicked: {
            if (!model.running) {
                launchOrResumeSelectedApp(true)
            }
        }

        onPressAndHold: {
            // popup() ensures the menu appears under the mouse cursor
            if (appContextMenu.popup) {
                appContextMenu.popup()
            }
            else {
                // Qt 5.9 doesn't have popup()
                appContextMenu.open()
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton;
            onClicked: {
                parent.pressAndHold()
            }
        }

        Keys.onReturnPressed: {
            // Open the app context menu if activated via the gamepad or keyboard
            // for running games. If the game isn't running, the above onClicked
            // method will handle the launch.
            if (model.running) {
                // This will be keyboard/gamepad driven so use
                // open() instead of popup()
                appContextMenu.open()
            }
        }

        Keys.onEnterPressed: {
            // Open the app context menu if activated via the gamepad or keyboard
            // for running games. If the game isn't running, the above onClicked
            // method will handle the launch.
            if (model.running) {
                // This will be keyboard/gamepad driven so use
                // open() instead of popup()
                appContextMenu.open()
            }
        }

        Keys.onMenuPressed: {
            // This will be keyboard/gamepad driven so use open() instead of popup()
            appContextMenu.open()
        }

        function doQuitGame() {
            quitAppDialog.appName = appModel.getRunningAppName()
            quitAppDialog.segueToStream = false
            quitAppDialog.open()
        }

        Loader {
            id: appContextMenuLoader
            asynchronous: true
            sourceComponent: NavigableMenu {
                id: appContextMenu
                NavigableMenuItem {
                    parentMenu: appContextMenu
                    text: model.running ? qsTr("Resume Game") : qsTr("Launch Game")
                    onTriggered: launchOrResumeSelectedApp(true)
                }
                NavigableMenuItem {
                    parentMenu: appContextMenu
                    text: qsTr("Quit Game")
                    onTriggered: doQuitGame()
                    visible: model.running
                }
                NavigableMenuItem {
                    parentMenu: appContextMenu
                    checkable: true
                    checked: model.directLaunch
                    text: qsTr("Direct Launch")
                    onTriggered: appModel.setAppDirectLaunch(model.index, !model.directLaunch)
                    enabled: !model.hidden

                    ToolTip.text: qsTr("Launch this app immediately when the host is selected, bypassing the app selection grid.")
                    ToolTip.delay: 1000
                    ToolTip.timeout: 3000
                    ToolTip.visible: hovered
                }
                NavigableMenuItem {
                    parentMenu: appContextMenu
                    checkable: true
                    checked: model.hidden
                    text: qsTr("Hide Game")
                    onTriggered: appModel.setAppHidden(model.index, !model.hidden)
                    enabled: model.hidden || (!model.running && !model.directLaunch)

                    ToolTip.text: qsTr("Hide this game from the app grid. To access hidden games, right-click on the host and choose %1.").arg(qsTr("View All Apps"))
                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                }
            }
        }
    }

    Ui.UiEmptyState {
        anchors.centerIn: parent
        width: Math.min(appGrid.width - 32, 560)
        visible: appGrid.count === 0
        iconSource: "qrc:/res/lucide/gamepad-2.svg"
        title: qsTr("No applications are available on this host")
        body: qsTr("The host may not have any exported apps yet, or some apps are currently hidden. Open the host actions menu if you need to view hidden apps.")
    }

    NavigableMessageDialog {
        id: quitAppDialog
        property string appName : ""
        property bool segueToStream : false
        property string nextAppName: ""
        property int nextAppIndex: 0
        text:qsTr("Are you sure you want to quit %1? Any unsaved progress will be lost.").arg(appName)
        standardButtons: Dialog.Yes | Dialog.No

        function quitApp() {
            var component = Qt.createComponent("QuitSegue.qml")
            var params = {"appName": appName, "quitRunningAppFn": function() { appModel.quitRunningApp() }}
            if (segueToStream) {
                // Store the session and app name if we're going to stream after
                // successfully quitting the old app.
                params.nextAppName = nextAppName
                params.nextSession = appModel.createSessionForApp(nextAppIndex)
            }
            else {
                params.nextAppName = null
                params.nextSession = null
            }

            stackView.push(component.createObject(stackView, params))
        }

        onAccepted: quitApp()
    }

    ErrorMessageDialog {
        id: launchPermissionDialog
        helpUrl: "https://github.com/ClassicOldSong/Apollo/wiki/Permission-System"
    }

    ScrollBar.vertical: ScrollBar {}
}
