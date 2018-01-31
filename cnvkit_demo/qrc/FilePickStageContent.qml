import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.0

Item {
    id: root

    width: 250
    height: 60

    property string buttonText: qsTr("Button")
    property string nameFilter: ""
    property string dialogTitle: qsTr("Title")
    property bool enabled: true

    property url filePath: fileDialog.fileUrl

    signal picked(url path)

    readonly property bool isSet: Qt.resolvedUrl(filePath) !== ""

    FileDialog {
        id: fileDialog
        title: root.dialogTitle
        folder: shortcuts.home
        nameFilters: [ root.nameFilter, "All files (*)" ]
        selectExisting: true
        selectMultiple: false
        onAccepted: root.picked(fileDialog.fileUrl)
    }


    Button {
        id: button
        text: root.buttonText
        onClicked: fileDialog.open()
        enabled: root.enabled

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
    }

    Text {
        id: headerText
        visible: root.isSet
        anchors {
            top: parent.top
            right: parent.right
            left: button.right
            leftMargin: 5
        }

        text: qsTr("File picked:")
    }

    Text {
        id: mainText
        visible: root.isSet
        anchors {
            top: headerText.bottom
            right: parent.right
            left: button.right
            bottom: parent.bottom
            leftMargin: 5
        }

        font.bold: true
        font.pointSize: 10

        text: root.filePath
    }

}