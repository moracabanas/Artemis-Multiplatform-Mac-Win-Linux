import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "ui" as Ui

import ClipboardManager 1.0

Ui.UiCard {
    id: clipboardSettingsCard
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
            title: qsTr("Clipboard sync")
            description: qsTr("Synchronize clipboard content between your device and the streaming server. Requires an Apollo host with clipboard permissions.")
        }

        Ui.UiToggle {
            id: enableClipboardSync
            text: qsTr("Enable clipboard synchronization")
            font.pointSize: 12
            checked: ClipboardManager.isEnabled
            onCheckedChanged: {
                ClipboardManager.isEnabled = checked
            }
        }

        Ui.UiCard {
            width: parent.width
            implicitHeight: filteringColumn.implicitHeight + 24
            height: implicitHeight
            tone: "surface"
            cornerRadius: 6
            enabled: enableClipboardSync.checked
            opacity: enabled ? 1.0 : 0.55

            Column {
                id: filteringColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Label {
                    width: parent.width
                    text: qsTr("Filtering")
                    font.pointSize: 11
                    font.bold: true
                    color: window ? window.textColor : "#fafafa"
                }

                Ui.UiToggle {
                    id: textOnlyFilter
                    text: qsTr("Text content only")
                    font.pointSize: 11
                    checked: ClipboardManager.textOnlyMode
                    onCheckedChanged: {
                        ClipboardManager.textOnlyMode = checked
                    }
                }

                Label {
                    width: parent.width
                    text: qsTr("Only sync text content and ignore images or files.")
                    font.pointSize: 10
                    wrapMode: Text.Wrap
                    color: window ? window.mutedTextColor : "#a1a1aa"
                }

                Row {
                    spacing: 10
                    width: parent.width

                    Label {
                        text: qsTr("Max content size")
                        font.pointSize: 11
                        color: window ? window.textColor : "#fafafa"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Ui.UiSpinBox {
                        id: maxSizeSpinBox
                        from: 1
                        to: 100
                        value: ClipboardManager.maxContentSizeMB
                        onValueChanged: {
                            ClipboardManager.maxContentSizeMB = value
                        }
                    }

                    Label {
                        text: "MB"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 11
                        color: window ? window.mutedTextColor : "#a1a1aa"
                    }
                }
            }
        }

        Ui.UiCard {
            width: parent.width
            implicitHeight: privacyColumn.implicitHeight + 24
            height: implicitHeight
            tone: "surface"
            cornerRadius: 6
            enabled: enableClipboardSync.checked
            opacity: enabled ? 1.0 : 0.55

            Column {
                id: privacyColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Label {
                    width: parent.width
                    text: qsTr("Notifications")
                    font.pointSize: 11
                    font.bold: true
                    color: window ? window.textColor : "#fafafa"
                }

                Ui.UiToggle {
                    id: showNotifications
                    text: qsTr("Show sync notifications")
                    font.pointSize: 11
                    checked: ClipboardManager.showNotifications
                    onCheckedChanged: {
                        ClipboardManager.showNotifications = checked
                    }
                }

                Label {
                    width: parent.width
                    text: qsTr("Display a toast when clipboard content is uploaded or fetched during a session.")
                    font.pointSize: 10
                    wrapMode: Text.Wrap
                    color: window ? window.mutedTextColor : "#a1a1aa"
                }
            }
        }

        Label {
            width: parent.width
            text: qsTr("Clipboard sync is only active during streaming sessions and only when the selected Apollo host grants clipboard access.")
            font.pointSize: 10
            wrapMode: Text.Wrap
            color: window ? window.mutedTextColor : "#a1a1aa"
            visible: enableClipboardSync.checked
        }
    }
}
