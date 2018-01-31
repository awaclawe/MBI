import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: root

    property real radius: 20

    property string text: qsTr("Default Text")
    property color background: "white"

    property bool command: false

    property bool current: false

    Rectangle {

        width: 2 * root.radius
        height: 2 * root.radius
        radius: root.radius / (root.command + 1)

        x: -root.radius
        y: -root.radius

        color: root.background

        antialiasing: true

        border {
            width: root.current * 2 + 1
        }

        Text {
            anchors.centerIn: parent

            text: root.text

            width: root.radius * Math.sqrt(2)
            height: root.radius * Math.sqrt(2)

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            wrapMode: Text.WordWrap

            font.pointSize: 6
            font.bold: root.command
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }


    }


}