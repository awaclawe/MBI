import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: root

    property real fromX: 0
    property real fromY: 0
    property real toX: 0
    property real toY: 0

    Path {
        startX: root.fromX; startY: root.fromY
        PathLine { x: root.toX; y: root.toY }
    }

}