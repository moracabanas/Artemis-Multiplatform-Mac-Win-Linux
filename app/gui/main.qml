import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import ComputerManager 1.0
import AutoUpdateChecker 1.0
import StreamingPreferences 1.0
import SystemProperties 1.0
import SdlGamepadKeyNavigation 1.0
import "ui" as Ui

ApplicationWindow {
    property bool pollingActive: false
    property color backgroundColor: "#050505"
    property color backgroundSecondaryColor: "#0a0a0c"
    property color surfaceColor: "#111113"
    property color elevatedSurfaceColor: "#151518"
    property color surfaceMutedColor: "#1c1c21"
    property color surfaceInsetColor: "#0d0d10"
    property color borderColor: "#27272a"
    property color borderStrongColor: "#3f3f46"
    property color accentColor: "#fafafa"
    property color textColor: "#fafafa"
    property color mutedTextColor: "#a1a1aa"
    property color subtleTextColor: "#71717a"
    property color successColor: "#fafafa"
    property color warningColor: "#d4d4d8"
    property color dangerColor: "#a1a1aa"
    property string uiFontFamily: geistRegular.status === FontLoader.Ready ? geistRegular.name : "SF Pro Display, Segoe UI, Arial"

    // Set by SettingsView to force the back operation to pop all
    // pages except the initial view. This is required when doing
    // a retranslate() because AppView breaks for some reason.
    property bool clearOnBack: false

    id: window
    width: 1280
    height: 600
    color: backgroundColor
    font.family: uiFontFamily

    FontLoader {
        id: geistRegular
        source: "qrc:/fonts/Geist-Regular.ttf"
    }

    FontLoader {
        id: geistMedium
        source: "qrc:/fonts/Geist-Medium.ttf"
    }

    FontLoader {
        id: geistSemiBold
        source: "qrc:/fonts/Geist-SemiBold.ttf"
    }

    background: Rectangle {
        color: window.backgroundColor
    }

    // This function runs prior to creation of the initial StackView item
    function doEarlyInit() {
        SdlGamepadKeyNavigation.enable()
    }

    Component.onCompleted: {
        // Show the window according to the user's preferences
        if (SystemProperties.hasDesktopEnvironment) {
            if (StreamingPreferences.uiDisplayMode == StreamingPreferences.UI_MAXIMIZED) {
                window.showMaximized()
            }
            else if (StreamingPreferences.uiDisplayMode == StreamingPreferences.UI_FULLSCREEN) {
                window.showFullScreen()
            }
            else {
                window.show()
            }
        } else {
            window.showFullScreen()
        }

        window.raise()
        window.requestActivate()

        // On some desktop startup paths, the initial visible/active transitions
        // don't reliably kick polling off before PcView renders. Start polling
        // explicitly once so LAN discovery is running from first launch.
        if (!pollingActive) {
            ComputerManager.startPolling()
            pollingActive = true
        }

        // Display any modal dialogs for configuration warnings
        if (SystemProperties.isWow64) {
            wow64Dialog.open()
        }
        else if (!SystemProperties.hasHardwareAcceleration && StreamingPreferences.videoDecoderSelection !== StreamingPreferences.VDS_FORCE_SOFTWARE) {
            if (SystemProperties.isRunningXWayland) {
                xWaylandDialog.open()
            }
            else {
                noHwDecoderDialog.open()
            }
        }

        if (SystemProperties.unmappedGamepads) {
            unmappedGamepadDialog.unmappedGamepads = SystemProperties.unmappedGamepads
            unmappedGamepadDialog.open()
        }
    }
  
    // It would be better to use TextMetrics here, but it always lays out
    // the text slightly more compactly than real Text does in ToolTip,
    // causing unexpected line breaks to be inserted
    Text {
        id: tooltipTextLayoutHelper
        visible: false
        font: ToolTip.toolTip.font
        text: ToolTip.toolTip.text
    }

    // This configures the maximum width of the singleton attached QML ToolTip. If left unconstrained,
    // it will never insert a line break and just extend on forever.
    // Note: ToolTip must be attached to an Item, not ApplicationWindow
    Item {
        id: tooltipHelper
        ToolTip.toolTip.contentWidth: Math.min(tooltipTextLayoutHelper.width, 400)
    }

    function goBack() {
        if (clearOnBack) {
            // Pop all items except the first one
            stackView.pop(null)
            clearOnBack = false
        }
        else {
            stackView.pop()
        }
    }

    // This timer keeps us polling for 5 minutes of inactivity
    // to allow the user to work with Moonlight on a second display
    // while dealing with configuration issues. This will ensure
    // machines come online even if the input focus isn't on Moonlight.
    Timer {
        id: inactivityTimer
        interval: 5 * 60000
        onTriggered: {
            if (!active && pollingActive) {
                ComputerManager.stopPollingAsync()
                pollingActive = false
            }
        }
    }

    onVisibleChanged: {
        // When we become invisible while streaming is going on,
        // stop polling immediately.
        if (!visible) {
            inactivityTimer.stop()

            if (pollingActive) {
                ComputerManager.stopPollingAsync()
                pollingActive = false
            }
        }
        else if (active) {
            // When we become visible and active again, start polling
            inactivityTimer.stop()

            // Restart polling if it was stopped
            if (!pollingActive) {
                ComputerManager.startPolling()
                pollingActive = true
            }
        }

        // Poll for gamepad input only when the window is in focus
        SdlGamepadKeyNavigation.notifyWindowFocus(visible && active)
    }

    onActiveChanged: {
        if (active) {
            // Stop the inactivity timer
            inactivityTimer.stop()

            // Restart polling if it was stopped
            if (!pollingActive) {
                ComputerManager.startPolling()
                pollingActive = true
            }
        }
        else {
            // Start the inactivity timer to stop polling
            // if focus does not return within a few minutes.
            inactivityTimer.restart()
        }

        // Poll for gamepad input only when the window is in focus
        SdlGamepadKeyNavigation.notifyWindowFocus(visible && active)
    }

    // Workaround for lack of instanceof in Qt 5.9.
    //
    // Based on https://stackoverflow.com/questions/13923794/how-to-do-a-is-a-typeof-or-instanceof-in-qml
    function qmltypeof(obj, className) { // QtObject, string -> bool
        // className plus "(" is the class instance without modification
        // className plus "_QML" is the class instance with user-defined properties
        var str = obj.toString();
        return str.startsWith(className + "(") || str.startsWith(className + "_QML");
    }

    function navigateTo(url, objectType)
    {
        var existingItem = stackView.find(function(item, index) {
            return qmltypeof(item, objectType)
        })

        if (existingItem !== null) {
            stackView.pop(existingItem)
        }
        else {
            stackView.push(url)
        }
    }

    function currentItemIs(typeName) {
        return stackView.currentItem && qmltypeof(stackView.currentItem, typeName)
    }

    function showSettings() {
        if (currentItemIs("SettingsView")) {
            return
        }

        stackView.push("qrc:/gui/SettingsView.qml")
    }

    function showComputers() {
        if (stackView.depth > 1) {
            stackView.pop(null)
        }
    }

    function currentPageTitle() {
        if (!stackView.currentItem) {
            return qsTr("Artemis")
        }

        if (currentItemIs("SettingsView")) {
            return qsTr("Settings")
        }

        return stackView.currentItem.objectName
    }

    function currentPageDescription() {
        if (currentItemIs("PcView")) {
            return qsTr("Manage hosts, pairing, local discovery, and session entry points.")
        }
        if (currentItemIs("SettingsView")) {
            return qsTr("Streaming, input, bitrate, Apollo integration, and client behavior.")
        }
        if (currentItemIs("AppView")) {
            return qsTr("Browse exported apps and launch a stream from the selected host.")
        }
        if (currentItemIs("StreamSegue") || currentItemIs("QuitSegue")) {
            return qsTr("Preparing or closing the active streaming session.")
        }

        return qsTr("Desktop streaming client")
    }

    Item {
        id: toolBar
        visible: true
    }

    Item {
        id: shell
        anchors.fill: parent
        anchors.margins: 18

        RowLayout {
            anchors.fill: parent
            spacing: 16

            Ui.UiCard {
                id: sideRail
                visible: toolBar.visible
                Layout.preferredWidth: 240
                Layout.fillHeight: true
                tone: "raised"
                cornerRadius: 10

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Ui.UiCard {
                        Layout.fillWidth: true
                        tone: "inset"
                        cornerRadius: 8
                        implicitHeight: brandBlock.implicitHeight + 24

                        ColumnLayout {
                            id: brandBlock
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Label {
                                text: qsTr("ARTEMIS")
                                color: window.textColor
                                font.pointSize: 11
                                font.bold: true
                            }

                            Label {
                                text: qsTr("Streaming client")
                                color: window.mutedTextColor
                                font.pointSize: 10
                            }
                        }
                    }

                    Ui.UiNavButton {
                        Layout.fillWidth: true
                        text: qsTr("Computers")
                        supportingText: qsTr("Hosts and applications")
                        iconSource: "qrc:/res/lucide/server.svg"
                        active: !currentItemIs("SettingsView")
                        onClicked: showComputers()
                    }

                    Ui.UiNavButton {
                        Layout.fillWidth: true
                        text: qsTr("Settings")
                        supportingText: qsTr("Client and stream preferences")
                        iconSource: "qrc:/res/lucide/settings.svg"
                        active: currentItemIs("SettingsView")
                        onClicked: showSettings()
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Ui.UiCard {
                        Layout.fillWidth: true
                        tone: "inset"
                        cornerRadius: 8
                        implicitHeight: footerRow.implicitHeight + 24

                        RowLayout {
                            id: footerRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Label {
                                    text: qsTr("Version %1").arg(SystemProperties.versionString)
                                    color: window.textColor
                                    font.pointSize: 10
                                    font.bold: true
                                }

                                Label {
                                    text: qsTr("Desktop streaming client")
                                    color: window.mutedTextColor
                                    font.pointSize: 9
                                }
                            }

                            Ui.UiButton {
                                visible: SystemProperties.hasBrowser
                                text: qsTr("Help ?")
                                tone: "ghost"
                                onClicked: Qt.openUrlExternally("https://github.com/wjbeckett/artemis/wiki/Setup-Guide")
                            }
                        }
                    }
                }
            }

            Ui.UiCard {
                id: workspace
                Layout.fillWidth: true
                Layout.fillHeight: true
                tone: "raised"
                cornerRadius: 10

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    Item {
                        id: workspaceHeader
                        visible: toolBar.visible
                        Layout.fillWidth: true
                        implicitHeight: headerRow.implicitHeight

                        RowLayout {
                            id: headerRow
                            anchors.fill: parent
                            spacing: 12

                            Ui.UiIconButton {
                                visible: stackView.depth > 1
                                iconSource: "qrc:/res/lucide/arrow-left.svg"
                                onClicked: goBack()
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: currentPageTitle()
                                    color: window.textColor
                                    font.pointSize: 24
                                    font.bold: true
                                }

                                Label {
                                    text: currentPageDescription()
                                    color: window.mutedTextColor
                                    font.pointSize: 10
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                            }

                            Ui.UiBadge {
                                visible: currentItemIs("SettingsView")
                                text: qsTr("Version %1").arg(SystemProperties.versionString)
                            }

                            Ui.UiButton {
                                id: addPcButton
                                visible: currentItemIs("PcView")
                                text: qsTr("+ Add Host")
                                onClicked: addPcDialog.open()
                            }

                            Ui.UiIconButton {
                                property string browserUrl: ""

                                id: updateButton
                                visible: false
                                iconSource: "qrc:/res/lucide/refresh-cw.svg"

                                onClicked: {
                                    if (SystemProperties.hasBrowser) {
                                        Qt.openUrlExternally(browserUrl)
                                    }
                                }

                                function updateAvailable(version, url)
                                {
                                    updateButton.browserUrl = url
                                    updateButton.visible = true
                                }

                                Component.onCompleted: {
                                    AutoUpdateChecker.onUpdateAvailable.connect(updateAvailable)
                                    AutoUpdateChecker.start()
                                }
                            }

                        }
                    }

                    Rectangle {
                        visible: toolBar.visible
                        Layout.fillWidth: true
                        height: 1
                        color: window.borderColor
                    }

                    StackView {
                        id: stackView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        focus: true
                        clip: true

                        Component.onCompleted: {
                            doEarlyInit()
                            push(initialView)
                        }

                        onCurrentItemChanged: {
                            if (currentItem) {
                                currentItem.forceActiveFocus()
                            }
                        }

                        Keys.onEscapePressed: {
                            if (depth > 1) {
                                goBack()
                            }
                            else {
                                quitConfirmationDialog.open()
                            }
                        }

                        Keys.onBackPressed: {
                            if (depth > 1) {
                                goBack()
                            }
                            else {
                                quitConfirmationDialog.open()
                            }
                        }

                        Keys.onMenuPressed: {
                            showSettings()
                        }

                        Keys.onHangupPressed: {
                            showSettings()
                        }
                    }
                }
            }
        }
    }

    Shortcut {
        id: settingsShortcut
        sequence: StandardKey.Preferences
        onActivated: showSettings()
    }

    Shortcut {
        id: newPcShortcut
        sequence: StandardKey.New
        onActivated: addPcDialog.open()
    }

    Shortcut {
        id: helpShortcut
        sequence: StandardKey.HelpContents
        onActivated: {
            if (SystemProperties.hasBrowser) {
                Qt.openUrlExternally("https://github.com/wjbeckett/artemis/wiki/Setup-Guide")
            }
        }
    }

    ErrorMessageDialog {
        id: noHwDecoderDialog
        text: qsTr("No functioning hardware accelerated video decoder was detected by Artemis. " +
                   "Your streaming performance may be severely degraded in this configuration.")
        helpText: qsTr("Click the Help button for more information on solving this problem.")
        helpUrl: "https://github.com/wjbeckett/artemis/wiki/Fixing-Hardware-Decoding-Problems"
    }

    ErrorMessageDialog {
        id: xWaylandDialog
        text: qsTr("Hardware acceleration doesn't work on XWayland. Continuing on XWayland may result in poor streaming performance. " +
                   "Try running with QT_QPA_PLATFORM=wayland or switch to X11.")
        helpText: qsTr("Click the Help button for more information.")
        helpUrl: "https://github.com/wjbeckett/artemis/wiki/Fixing-Hardware-Decoding-Problems"
    }

    NavigableMessageDialog {
        id: wow64Dialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        text: qsTr("This version of Artemis isn't optimized for your PC. Please download the '%1' version of Artemis for the best streaming performance.").arg(SystemProperties.friendlyNativeArchName)
        onAccepted: {
            Qt.openUrlExternally("https://github.com/wjbeckett/artemis/releases");
        }
    }

    ErrorMessageDialog {
        id: unmappedGamepadDialog
        property string unmappedGamepads : ""
        text: qsTr("Artemis detected gamepads without a mapping:") + "\n" + unmappedGamepads
        helpTextSeparator: "\n\n"
        helpText: qsTr("Click the Help button for information on how to map your gamepads.")
        helpUrl: "https://github.com/wjbeckett/artemis/wiki/Gamepad-Mapping"
    }

    // This dialog appears when quitting via keyboard or gamepad button
    NavigableMessageDialog {
        id: quitConfirmationDialog
        standardButtons: Dialog.Yes | Dialog.No
        text: qsTr("Are you sure you want to quit?")
        // For keyboard/gamepad navigation
        onAccepted: Qt.quit()
    }

    // HACK: This belongs in StreamSegue but keeping a dialog around after the parent
    // dies can trigger bugs in Qt 5.12 that cause the app to crash. For now, we will
    // host this dialog in a QML component that is never destroyed.
    //
    // To repro: Start a stream, cut the network connection to trigger the "Connection
    // terminated" dialog, wait until the app grid times out back to the PC grid, then
    // try to dismiss the dialog.
    ErrorMessageDialog {
        id: streamSegueErrorDialog

        property bool quitAfter: false

        onClosed: {
            if (quitAfter) {
                Qt.quit()
            }

            // StreamSegue assumes its dialog will be re-created each time we
            // start streaming, so fake it by wiping out the text each time.
            text = ""
        }
    }

    NavigableDialog {
        id: addPcDialog
        property string label: qsTr("Enter the IP address of your host PC:")
        width: 420

        standardButtons: Dialog.Ok | Dialog.Cancel

        onOpened: {
            // Force keyboard focus on the textbox so keyboard navigation works
            editText.forceActiveFocus()
        }

        onClosed: {
            editText.clear()
        }

        onAccepted: {
            if (editText.text) {
                ComputerManager.addNewHostManually(editText.text.trim())
            }
        }

        ColumnLayout {
            width: parent.width
            spacing: 12

            Ui.UiSectionHeader {
                Layout.fillWidth: true
                eyebrow: qsTr("MANUAL HOST")
                title: qsTr("Add a host by address")
                description: qsTr("Use a LAN IP address or hostname if automatic discovery does not find your streaming PC.")
            }

            Ui.UiInput {
                id: editText
                Layout.fillWidth: true
                focus: true
                placeholderText: qsTr("192.168.1.78")

                Keys.onReturnPressed: {
                    addPcDialog.accept()
                }

                Keys.onEnterPressed: {
                    addPcDialog.accept()
                }
            }
        }
    }
}
