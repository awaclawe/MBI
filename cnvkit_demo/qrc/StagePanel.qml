import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: root

    implicitWidth: 500
    implicitHeight: 65

    color: "lightgray"

    property string header: qsTr("Header")

    property int stageNo: 1

    property bool current: false

    default property alias content: content.children

    Item {
        id: noContainer
        width: height
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        Text {
            text: root.stageNo
            anchors.centerIn: parent
            font.pointSize: 20
        }
    }

    Item {
        anchors {
            left: noContainer.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        Text {
            id: headerText
            text: root.header
            anchors {
                left: parent.left
                top: parent.top
                margins: 5
            }
            font.bold: true
            font.pointSize: 10
        }

        Item {
            id: content
            clip: true
            anchors {
                left: parent.left
                right: parent.right
                top: headerText.bottom
                bottom: parent.bottom
                margins: 5
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }

}