import QtQuick 2.0
import QtQuick.Controls 2.2
import "ui" as Ui

import ComputerManager 1.0
import Session 1.0

Item {
    property string appName
    property var quitRunningAppFn
    property Session nextSession : null
    property string nextAppName : ""

    property string stageText : qsTr("Quitting %1...").arg(appName)

    function quitAppCompleted(error)
    {
        // Display a failed dialog if we got an error
        if (error !== undefined) {
            errorDialog.text = error
            errorDialog.open()
            console.error(error)
        }

        // If we're supposed to launch another game after this, do so now
        if (error === undefined && nextSession !== null) {
            var component = Qt.createComponent("StreamSegue.qml")
            var segue = component.createObject(stackView, {"appName": nextAppName, "session": nextSession})
            stackView.replace(segue)
        }
        else {
            // Exit this view
            stackView.pop()
        }
    }

    StackView.onActivated: {
        // Hide the toolbar before we start loading
        toolBar.visible = false

        // Connect the quit completion signal
        ComputerManager.quitAppCompleted.connect(quitAppCompleted)

        // Start the quit operation if requested
        if (quitRunningAppFn) {
            quitRunningAppFn()
        }
    }

    StackView.onDeactivating: {
        // Show the toolbar again
        toolBar.visible = true

        // Disconnect the signal
        ComputerManager.quitAppCompleted.disconnect(quitAppCompleted)
    }

    Ui.UiCard {
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 520)
        implicitHeight: quitColumn.implicitHeight + 36
        height: implicitHeight
        tone: "raised"
        cornerRadius: 8

        Column {
            id: quitColumn
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            Row {
                spacing: 12

                Item {
                    width: 24
                    height: 24

                    BusyIndicator {
                        id: stageSpinner
                        anchors.fill: parent
                    }
                }

                Ui.UiSectionHeader {
                    width: parent.width - 48
                    eyebrow: qsTr("SESSION")
                    title: stageText
                    description: qsTr("Artemis is closing the active stream before returning to the application browser.")
                }
            }
        }
    }

    ErrorMessageDialog {
        id: errorDialog
    }
}
