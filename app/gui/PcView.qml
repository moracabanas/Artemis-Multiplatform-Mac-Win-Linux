import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "ui" as Ui

import ComputerModel 1.0

import ComputerManager 1.0
import StreamingPreferences 1.0
import SystemProperties 1.0
import SdlGamepadKeyNavigation 1.0

CenteredGridView {
    property ComputerModel computerModel : createModel()
    property color cardColor: window ? window.surfaceColor : "#18181b"
    property color cardBorderColor: window ? window.borderColor : "#2f2f35"
    property color accentColor: window ? window.accentColor : "#fafafa"

    id: pcGrid
    focus: true
    activeFocusOnTab: true
    topMargin: 8
    bottomMargin: 8
    cellWidth: Math.max(520, width - 28)
    cellHeight: 212
    objectName: qsTr("Computers")

    function statusText(online, paired, busy, statusUnknown) {
        if (statusUnknown) {
            return qsTr("Checking")
        }
        if (!online) {
            return qsTr("Offline")
        }
        if (!paired) {
            return qsTr("Needs pairing")
        }
        if (busy) {
            return qsTr("Streaming")
        }
        return qsTr("Ready")
    }

    function statusColor(online, paired, busy, statusUnknown) {
        if (statusUnknown) {
            return "#18181b"
        }
        if (!online) {
            return "#1f1f23"
        }
        if (!paired) {
            return "#111113"
        }
        if (busy) {
            return "#e4e4e7"
        }
        return "#fafafa"
    }

    function statusTextColor(online, paired, busy, statusUnknown) {
        if (busy || (online && paired && !statusUnknown)) {
            return "#09090b"
        }

        return "#fafafa"
    }

    function statusBorderColor(online, paired, busy, statusUnknown) {
        if (statusUnknown) {
            return "#3f3f46"
        }
        if (!online) {
            return "#3f3f46"
        }
        if (!paired) {
            return "#52525b"
        }
        if (busy) {
            return "#f4f4f5"
        }
        return "#fafafa"
    }

    function serverLabel(apolloVersion, apolloHost) {
        if (apolloVersion) {
            return qsTr("Apollo %1").arg(apolloVersion)
        }
        if (apolloHost) {
            return qsTr("Apollo host")
        }
        return qsTr("Compatible host")
    }

    function statusIcon(online, paired, busy, statusUnknown) {
        if (statusUnknown) {
            return "qrc:/res/lucide/search.svg"
        }
        if (!online) {
            return "qrc:/res/lucide/triangle-alert.svg"
        }
        if (!paired) {
            return "qrc:/res/lucide/lock.svg"
        }
        if (busy) {
            return "qrc:/res/lucide/power.svg"
        }
        return "qrc:/res/lucide/monitor.svg"
    }

    function actionText(online, paired, apolloHost, serverPermissions) {
        if (!online) {
            return qsTr("Wake the machine, test the path, rename it, or inspect host details from one place.")
        }
        if (!paired) {
            return qsTr("Complete pairing once, then browsing and stream launch controls will unlock.")
        }
        if (apolloHost && (serverPermissions & 0x04000000) === 0) {
            return qsTr("Browse the exported app list now. Launch permission is still controlled by Apollo.")
        }
        return qsTr("Open the app library, start a stream, or manage this host.")
    }

    function primaryActionLabel(online, paired) {
        if (!online) {
            return qsTr("Open host actions")
        }
        if (!paired) {
            return qsTr("Pair host")
        }
        return qsTr("Open apps")
    }

    function statusTitle(online, paired, busy, statusUnknown) {
        if (statusUnknown) {
            return qsTr("Checking availability")
        }
        if (!online) {
            return qsTr("Host is offline")
        }
        if (!paired) {
            return qsTr("Pairing required")
        }
        if (busy) {
            return qsTr("Session is active")
        }
        return qsTr("Ready to browse")
    }

    function statusDescription(online, paired, busy, statusUnknown, apolloHost, serverPermissions) {
        if (statusUnknown) {
            return qsTr("Artemis is refreshing this host and checking what actions are available right now.")
        }
        if (!online) {
            return qsTr("Open the actions menu to wake the machine, run a network test, rename it, or inspect details.")
        }
        if (!paired) {
            return qsTr("Select this row to pair the client, then app browsing and session launch will be available.")
        }
        if (busy) {
            return qsTr("A stream is already running. Open the row to browse apps or manage the active session.")
        }
        if (apolloHost && (serverPermissions & 0x04000000) === 0) {
            return qsTr("Select the row to browse exported apps. Apollo still controls whether launching is allowed.")
        }
        return qsTr("Select the row to open the app library, launch a stream, or manage this host.")
    }

    function openAppView(targetIndex, showHiddenGames) {
        if (targetIndex < 0) {
            return
        }

        var component = Qt.createComponent("AppView.qml")
        var appView = component.createObject(stackView, {
            "computerIndex": targetIndex,
            "objectName": computerModel.data(computerModel.index(targetIndex, 0), ComputerModel.NameRole) || "Computer",
            "showHiddenGames": showHiddenGames === true
        })
        stackView.push(appView)
    }

    function startStandardPairing(targetIndex) {
        otpPairDialog.computerIndex = -1
        var pin = computerModel.generatePinString()
        pairDialog.computerIndex = targetIndex
        computerModel.pairComputer(targetIndex, pin)
        pairDialog.pin = pin
        pairDialog.open()
    }

    function startOtpPairing(targetIndex) {
        pairDialog.computerIndex = -1
        otpPairDialog.computerIndex = targetIndex
        otpPairDialog.open()
    }

    Component.onCompleted: {
        // Don't show any highlighted item until interacting with them.
        // We do this here instead of onActivated to avoid losing the user's
        // selection when backing out of a different page of the app.
        currentIndex = -1
    }

    // Note: Any initialization done here that is critical for streaming must
    // also be done in CliStartStreamSegue.qml, since this code does not run
    // for command-line initiated streams.
    StackView.onActivated: {
        // Setup signals on CM
        ComputerManager.computerAddCompleted.connect(addComplete)

        // Highlight the first item if a gamepad is connected
        if (currentIndex == -1 && SdlGamepadKeyNavigation.getConnectedGamepads() > 0) {
            currentIndex = 0
        }
    }

    StackView.onDeactivating: {
        ComputerManager.computerAddCompleted.disconnect(addComplete)
    }

    function pairingComplete(error)
    {
        console.log("PcView.pairingComplete called with error:", error)

        var targetIndex = pairDialog.computerIndex >= 0 ? pairDialog.computerIndex : otpPairDialog.computerIndex
        
        // Close both PIN dialogs
        pairDialog.close()
        otpProgressDialog.close()

        // Display a failed dialog if we got an error
        if (error !== undefined) {
            console.log("PcView: Showing error dialog:", error)
            errorDialog.text = error
            errorDialog.helpText = ""
            errorDialog.open()
        } else {
            console.log("PcView: Pairing successful, attempting navigation")
            console.log("PcView: Target index for navigation:", targetIndex)
            
            if (targetIndex >= 0) {
                console.log("PcView: Creating AppView for computer index:", targetIndex)
                pcGrid.openAppView(targetIndex, false)
                console.log("PcView: Navigation completed")
            } else {
                console.log("PcView: No valid target index, cannot navigate")
            }
        }

        pairDialog.computerIndex = -1
        otpPairDialog.computerIndex = -1
    }

    function addComplete(success, detectedPortBlocking)
    {
        if (!success) {
            errorDialog.text = qsTr("Unable to connect to the specified PC.")

            if (detectedPortBlocking) {
                errorDialog.text += "\n\n" + qsTr("This PC's Internet connection is blocking Moonlight. Streaming over the Internet may not work while connected to this network.")
            }
            else {
                errorDialog.helpText = qsTr("Click the Help button for possible solutions.")
            }

            errorDialog.open()
        }
    }

    function createModel()
    {
        var model = Qt.createQmlObject('import ComputerModel 1.0; ComputerModel {}', parent, '')
        model.initialize(ComputerManager)
        model.pairingCompleted.connect(pairingComplete)
        model.connectionTestCompleted.connect(testConnectionDialog.connectionTestComplete)
        return model
    }

    Ui.UiEmptyState {
        anchors.centerIn: parent
        width: Math.min(pcGrid.width - 32, 560)
        visible: pcGrid.count === 0
        busy: StreamingPreferences.enableMdns
        iconSource: "qrc:/res/lucide/server.svg"
        title: StreamingPreferences.enableMdns
               ? qsTr("Searching for compatible hosts on your local network...")
               : qsTr("Automatic host discovery is disabled.")
        body: StreamingPreferences.enableMdns
              ? qsTr("Make sure your host is on the same network and allowed through its firewall. If it still does not appear, use the Add Host action to register it manually.")
              : qsTr("Turn on local discovery in Settings or use the Add Host action to register a host directly.")
    }

    model: computerModel

    delegate: NavigableItemDelegate {
        id: hostTile
        width: Math.max(480, pcGrid.cellWidth - 12)
        height: 176
        grid: pcGrid
        hoverEnabled: true

        property alias pcContextMenu : pcContextMenuLoader.item

        function openHostMenu(anchorItem) {
            var target = anchorItem || hostMenuButton

            if (target) {
                var position = target.mapToItem(hostTile, 0, target.height + 6)
                pcContextMenu.x = position.x - Math.max(0, pcContextMenu.width - target.width)
                pcContextMenu.y = position.y
                pcContextMenu.open()
            }
            else if (pcContextMenu.popup) {
                pcContextMenu.popup()
            }
            else {
                pcContextMenu.open()
            }
        }

        function activatePrimaryAction() {
            if (model.online) {
                if (!model.serverSupported) {
                    errorDialog.text = qsTr("The version of GeForce Experience on %1 is not supported by this build of Moonlight. You must update Moonlight to stream from %1.").arg(model.name)
                    errorDialog.helpText = ""
                    errorDialog.open()
                }
                else if (model.paired) {
                    pcGrid.openAppView(index, false)
                }
                else {
                    if (computerModel.isOTPSupported(index)) {
                        pcGrid.startOtpPairing(index)
                    } else {
                        pcGrid.startStandardPairing(index)
                    }
                }
            }
            else {
                openHostMenu()
            }
        }

        background: Ui.UiCard {
            cornerRadius: 8
            border.width: highlighted ? 2 : 1
            border.color: highlighted ? pcGrid.accentColor : pcGrid.cardBorderColor
            color: highlighted ? (window ? window.elevatedSurfaceColor : "#151518")
                               : (window ? window.surfaceColor : "#111113")
        }

        contentItem: RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Row {
                    Layout.fillWidth: true
                    spacing: 8

                    Ui.UiBadge {
                        text: pcGrid.statusText(model.online, model.paired, model.busy, model.statusUnknown)
                        tone: (model.online && model.paired && !model.statusUnknown) || model.busy ? "strong" : "default"
                    }

                    Ui.UiBadge {
                        text: pcGrid.serverLabel(model.apolloVersion, model.apolloHost)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Ui.UiCard {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        tone: "inset"
                        cornerRadius: 8

                        BusyIndicator {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            visible: model.statusUnknown
                            running: visible
                        }

                        Ui.UiIcon {
                            anchors.centerIn: parent
                            visible: !model.statusUnknown
                            source: pcGrid.statusIcon(model.online, model.paired, model.busy, model.statusUnknown)
                            iconSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Label {
                            id: pcNameText
                            text: model.name
                            Layout.fillWidth: true
                            font.pointSize: 20
                            font.bold: true
                            color: window ? window.textColor : "#fafafa"
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.online
                                  ? (model.paired
                                     ? qsTr("Ready to browse apps, launch sessions, and manage the host.")
                                     : qsTr("Host is online but still needs pairing before streaming can start."))
                                  : qsTr("Host is currently offline or unreachable from this device.")
                            color: window ? window.mutedTextColor : "#a1a1aa"
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: window ? window.borderColor : "#27272a"
            }

            ColumnLayout {
                Layout.preferredWidth: 248
                Layout.fillHeight: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Ui.UiSectionHeader {
                        Layout.fillWidth: true
                        eyebrow: qsTr("STATUS")
                        title: pcGrid.statusTitle(model.online, model.paired, model.busy, model.statusUnknown)
                        description: pcGrid.statusDescription(model.online, model.paired, model.busy, model.statusUnknown, model.apolloHost, model.serverPermissions)
                    }

                    Ui.UiIconButton {
                        id: hostMenuButton
                        iconSource: "qrc:/res/lucide/chevron-down.svg"
                        onClicked: hostTile.openHostMenu(hostMenuButton)
                    }
                }

                Label {
                    Layout.fillWidth: true
                    visible: pcGrid.count === 1
                    text: model.online && model.paired
                          ? qsTr("Click the row to open apps.")
                          : qsTr("Click the row to continue.")
                    color: window ? window.mutedTextColor : "#a1a1aa"
                    font.pointSize: 9
                    wrapMode: Text.Wrap
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Loader {
            id: pcContextMenuLoader
            asynchronous: true
            sourceComponent: NavigableMenu {
                id: pcContextMenu
                MenuItem {
                    id: statusMenuItem
                    text: qsTr("PC Status: %1").arg(model.online ? qsTr("Online") : qsTr("Offline"))
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 10
                    bottomPadding: 10
                    implicitWidth: 220
                    enabled: false

                    background: Rectangle {
                        radius: 6
                        color: "transparent"
                    }

                    contentItem: Label {
                        text: statusMenuItem.text
                        color: window ? window.mutedTextColor : "#a1a1aa"
                        font.pointSize: 10
                        font.bold: true
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                NavigableMenuItem {
                    parentMenu: pcContextMenu
                    text: qsTr("View All Apps")
                    onTriggered: {
                        pcGrid.openAppView(index, true)
                    }
                    visible: model.online && model.paired
                }
                NavigableMenuItem {
                    parentMenu: pcContextMenu
                    text: qsTr("Wake PC")
                    onTriggered: computerModel.wakeComputer(index)
                    visible: !model.online && model.wakeable
                }
                NavigableMenuItem {
                    parentMenu: pcContextMenu
                    text: computerModel.isOTPSupported(index) ? qsTr("Pair with PIN") : qsTr("Pair")
                    onTriggered: pcGrid.startStandardPairing(index)
                    visible: model.online && !model.paired
                }
                NavigableMenuItem {
                    parentMenu: pcContextMenu
                    text: qsTr("Pair with OTP / passphrase")
                    onTriggered: pcGrid.startOtpPairing(index)
                    visible: model.online && !model.paired && computerModel.isOTPSupported(index)
                }
                NavigableMenuItem {
                    parentMenu: pcContextMenu
                    text: qsTr("Test Network")
                    onTriggered: {
                        computerModel.testConnectionForComputer(index)
                        testConnectionDialog.open()
                    }
                }

                NavigableMenuItem {
                    parentMenu: pcContextMenu
                    text: qsTr("Rename PC")
                    onTriggered: {
                        renamePcDialog.pcIndex = index
                        renamePcDialog.originalName = model.name
                        renamePcDialog.open()
                    }
                }
                NavigableMenuItem {
                    parentMenu: pcContextMenu
                    text: qsTr("Delete PC")
                    onTriggered: {
                        deletePcDialog.pcIndex = index
                        deletePcDialog.pcName = model.name
                        deletePcDialog.open()
                    }
                }
                NavigableMenuItem {
                    parentMenu: pcContextMenu
                    text: qsTr("View Details")
                    onTriggered: {
                        showPcDetailsDialog.pcDetails = model.details
                        showPcDetailsDialog.open()
                    }
                }
            }
        }

        onClicked: activatePrimaryAction()

        onPressAndHold: {
            openHostMenu()
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton;
            onClicked: {
                parent.pressAndHold()
            }
        }

        Keys.onMenuPressed: {
            // We must use open() here so the menu is positioned on
            // the ItemDelegate and not where the mouse cursor is
            pcContextMenu.open()
        }

        Keys.onDeletePressed: {
            deletePcDialog.pcIndex = index
            deletePcDialog.pcName = model.name
            deletePcDialog.open()
        }
    }

    ErrorMessageDialog {
        id: errorDialog

        // Using Setup-Guide here instead of Troubleshooting because it's likely that users
        // will arrive here by forgetting to enable GameStream or not forwarding ports.
        helpUrl: "https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide"
    }

    NavigableMessageDialog {
        id: pairDialog
        property int computerIndex: -1

        // Pairing dialog must be modal to prevent double-clicks from triggering
        // pairing twice
        modal: true
        closePolicy: Popup.CloseOnEscape

        // don't allow edits to the rest of the window while open
        property string pin : "0000"
        text:qsTr("Please enter %1 on your host PC. This dialog will close when pairing is completed.").arg(pin)+"\n\n"+
             qsTr("If your host PC is running Sunshine, navigate to the Sunshine web UI to enter the PIN.")
        standardButtons: Dialog.Cancel
        onRejected: {
            // FIXME: We should interrupt pairing here
            pairDialog.computerIndex = -1
        }
    }

    NavigableMessageDialog {
        id: deletePcDialog
        // don't allow edits to the rest of the window while open
        property int pcIndex : -1
        property string pcName : ""
        text: qsTr("Are you sure you want to remove '%1'?").arg(pcName)
        standardButtons: Dialog.Yes | Dialog.No

        onAccepted: {
            computerModel.deleteComputer(pcIndex)
        }
    }

    NavigableMessageDialog {
        id: testConnectionDialog
        closePolicy: Popup.CloseOnEscape
        standardButtons: Dialog.Ok

        onAboutToShow: {
            testConnectionDialog.text = qsTr("Moonlight is testing your network connection to determine if any required ports are blocked.") + "\n\n" + qsTr("This may take a few seconds…")
            showSpinner = true
        }

        function connectionTestComplete(result, blockedPorts)
        {
            if (result === -1) {
                text = qsTr("The network test could not be performed because none of Moonlight's connection testing servers were reachable from this PC. Check your Internet connection or try again later.")
                imageSrc = "qrc:/res/lucide/triangle-alert.svg"
            }
            else if (result === 0) {
                text = qsTr("This network does not appear to be blocking Moonlight. If you still have trouble connecting, check your PC's firewall settings.") + "\n\n" + qsTr("If you are trying to stream over the Internet, install the Moonlight Internet Hosting Tool on your gaming PC and run the included Internet Streaming Tester to check your gaming PC's Internet connection.")
                imageSrc = "qrc:/res/lucide/circle-check.svg"
            }
            else {
                text = qsTr("Your PC's current network connection seems to be blocking Moonlight. Streaming over the Internet may not work while connected to this network.") + "\n\n" + qsTr("The following network ports were blocked:") + "\n"
                text += blockedPorts
                imageSrc = "qrc:/res/lucide/circle-alert.svg"
            }

            // Stop showing the spinner and show the image instead
            showSpinner = false
        }
    }

    NavigableDialog {
        id: renamePcDialog
        property string label: qsTr("Enter the new name for this PC:")
        property string originalName
        property int pcIndex : -1;

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
                computerModel.renameComputer(pcIndex, editText.text)
            }
        }

        ColumnLayout {
            Label {
                text: renamePcDialog.label
                font.bold: true
            }

            Ui.UiInput {
                id: editText
                placeholderText: renamePcDialog.originalName
                Layout.fillWidth: true
                focus: true

                Keys.onReturnPressed: {
                    renamePcDialog.accept()
                }

                Keys.onEnterPressed: {
                    renamePcDialog.accept()
                }
            }
        }
    }

    NavigableDialog {
        id: showPcDetailsDialog
        property string pcDetails : "";
        title: qsTr("Computer Details")
        standardButtons: Dialog.Ok
        
        // Make the dialog larger
        implicitWidth: 600
        implicitHeight: 500
        
            ScrollView {
            id: detailsScrollView
            anchors.fill: parent
            anchors.margins: 8  // Slightly larger margin for better appearance
            clip: true
            
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            
            // Ensure scrollbars stay within bounds
            ScrollBar.vertical.width: 12
            ScrollBar.horizontal.height: 12
            
            TextArea {
                id: detailsLabel
                text: showPcDetailsDialog.pcDetails
                wrapMode: Text.Wrap
                selectByMouse: true
                readOnly: true
                font.family: "SF Pro Display, Segoe UI, system-ui, Arial"
                font.pixelSize: 14  // Slightly larger for better readability
                font.weight: Font.Normal
                textFormat: Text.PlainText  // Use plain text to maintain transparent background
                
                // Use default text color for dark theme compatibility
                // Enhanced padding for better spacing
                padding: 20
                
                // Remove white border - use transparent background
                background: Rectangle {
                    color: "transparent"
                    border.width: 0
                }
                
                // Allow the text to expand naturally within the scroll area
                width: Math.max(detailsScrollView.availableWidth, implicitWidth)
                
                Keys.onReturnPressed: {
                    showPcDetailsDialog.accept()
                }

                Keys.onEnterPressed: {
                    showPcDetailsDialog.accept()
                }

                Keys.onEscapePressed: {
                    showPcDetailsDialog.reject()
                }
            }
        }
    }

    NavigableDialog {
        id: otpPairDialog
        property int computerIndex: -1
        property string computerName: computerIndex >= 0 ? (computerModel.data(computerModel.index(computerIndex, 0), ComputerModel.NameRole) || "") : ""
        
        title: qsTr("OTP Pairing")
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        closePolicy: Popup.CloseOnEscape
        
        onOpened: {
            // Clear previous values and focus on PIN field
            pinField.text = ""
            passphraseField.text = ""
            pinField.forceActiveFocus()
        }
        
        onAccepted: {
            if (pinField.text.length === 4) {
                // Start OTP pairing
                computerModel.pairComputerWithOTP(computerIndex, pinField.text, passphraseField.text)
                
                // Show progress dialog
                otpProgressDialog.open()
            } else {
                // Show error for invalid PIN
                errorDialog.text = qsTr("PIN must be exactly 4 digits")
                errorDialog.helpText = ""
                errorDialog.open()
            }
        }

        onRejected: {
            otpPairDialog.computerIndex = -1
        }
        
        ColumnLayout {
            width: parent.width
            spacing: 15
            
            Label {
                text: qsTr("Pairing with Apollo Server: %1").arg(otpPairDialog.computerName)
                font.bold: true
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
            
            Label {
                text: qsTr("Apollo servers use OTP (One-Time Password) pairing for enhanced security.")
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                
                Label {
                    text: qsTr("PIN (4 digits):")
                    font.bold: true
                }
                
                Ui.UiInput {
                    id: pinField
                    placeholderText: qsTr("Enter 4-digit PIN")
                    Layout.fillWidth: true
                    maximumLength: 4
                    inputMethodHints: Qt.ImhDigitsOnly
                    
                    Keys.onReturnPressed: {
                        if (pinField.text.length === 4) {
                            passphraseField.forceActiveFocus()
                        }
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                
                Label {
                    text: qsTr("Passphrase (optional):")
                    font.bold: true
                }
                
                Ui.UiInput {
                    id: passphraseField
                    placeholderText: qsTr("Enter passphrase (leave blank for default)")
                    Layout.fillWidth: true
                    
                    Keys.onReturnPressed: {
                        if (pinField.text.length === 4) {
                            otpPairDialog.accept()
                        }
                    }
                }
            }
            
            Label {
                text: qsTr("Enter the PIN from your Apollo server's web interface. Apollo generates this PIN for you.")
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                color: "gray"
                font.pointSize: 9
            }
        }
    }
    
    NavigableMessageDialog {
        id: otpProgressDialog
        title: qsTr("OTP Pairing in Progress")
        text: qsTr("Pairing with Apollo server...\n\nThis may take a few seconds.")
        standardButtons: Dialog.NoButton
        modal: true
        closePolicy: Popup.NoAutoClose
        showSpinner: true
        
        // The dialog will be closed automatically when pairing completes
        // via the pairingComplete() function
    }

    ScrollBar.vertical: ScrollBar {}
}
