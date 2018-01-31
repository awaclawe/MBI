import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: root

    width: 250
    height: 60

    property string buttonText: qsTr("Calculate")
    property url antitargetFile: ""
    property bool enabled: true

    signal calculate()

    Button {
        id: button
        text: root.buttonText
        onClicked: root.calculate()
        enabled: root.enabled

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
    }

    Text {
        id: headerText
        visible: false
        anchors {
            top: parent.top
            right: parent.right
            left: button.right
            leftMargin: 5
        }

        text: qsTr("Created antitarget file:")
    }

    Text {
        id: mainText
        visible: false
        anchors {
            top: headerText.bottom
            right: parent.right
            left: button.right
            bottom: parent.bottom
            leftMargin: 5
        }

        font.bold: true
        font.pointSize: 10

        text: root.antitargetFile
    }

    states: [
        State {
            name: "UNPICKED"
        },
        State {
            name: "PICKED"
            PropertyChanges { target: headerText; visible: true }
            PropertyChanges { target: mainText; visible: true }
        }
    ]

    state: "UNPICKED"

}