import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "ui" as Ui

NavigableDialog {
    id: dialog
    width: Math.min(parent ? parent.width - 48 : implicitWidth, 560)

    property alias text: dialogLabel.dialogText
    property alias showSpinner: dialogSpinner.visible
    property alias imageSrc: dialogImage.source

    property string helpText
    property string helpUrl : "https://github.com/moonlight-stream/moonlight-docs/wiki/Troubleshooting"
    property string helpTextSeparator : " "

    onOpened: {
        // Force keyboard focus on the label so keyboard navigation works
        dialogLabel.forceActiveFocus()
    }

    contentItem: RowLayout {
        spacing: 14

        BusyIndicator {
            id: dialogSpinner
            visible: false
        }

        Ui.UiIcon {
            id: dialogImage
            source: (standardButtons & Dialog.Yes) ?
                        "qrc:/res/lucide/circle-question-mark.svg" :
                        "qrc:/res/lucide/circle-alert.svg"
            iconSize: 22
            visible: !showSpinner
        }

        Label {
            property string dialogText

            id: dialogLabel
            text: dialogText + ((helpText && (standardButtons & Dialog.Help)) ? (helpTextSeparator + helpText) : "")
            color: window ? window.textColor : "white"
            wrapMode: Text.Wrap
            elide: Label.ElideRight
            lineHeight: 1.25

            // Cap the width so the dialog doesn't grow horizontally forever. This
            // will cause word wrap to kick in.
            Layout.maximumWidth: 400
            Layout.maximumHeight: 400

            Keys.onReturnPressed: {
                accept()
            }

            Keys.onEnterPressed: {
                accept()
            }

            Keys.onEscapePressed: {
                reject()
            }
        }
    }

    onHelpRequested: {
        Qt.openUrlExternally(helpUrl)
        close()
    }
}
