import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: root

    property real nodeRadius: 33

    readonly property real spacing: 2.5 * nodeRadius

    property color duringColor: "#FFE082"
    property color doneColor: "#A5D6A7"

    Canvas {
        id: arrowsCanvas

        width: 300
        height: 800

        onPaint: {
            var ctx = arrowsCanvas.getContext("2d");

            ctx.lineWidth = 2
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1);

            ctx.beginPath();
            arrowNode(ctx, bamNode, coverageNode)
            arrowNode(ctx, targetNode, antitargetNode)
            arrowNode(ctx, targetNode, coverageNode)
            arrowNode(ctx, antitargetNode, antitargetOutNode)
            arrowNode(ctx, antitargetOutNode, coverageNode)
            arrowNode(ctx, coverageNode, coverageOutNode)
            arrowNode(ctx, coverageOutNode, referenceNode)
            arrowNode(ctx, referenceNode, referenceOutNode)
            arrowNode(ctx, coverageOutNode, fixNode)
            arrowNode(ctx, referenceOutNode, fixNode)
            arrowNode(ctx, fixNode, cnrNode)
            arrowNode(ctx, cnrNode, segmentNode)
            arrowNode(ctx, segmentNode, cnsNode)
            ctx.stroke();
        }

        function arrowNode(ctx, fromNode, toNode) {
            arrow(ctx, fromNode.x, fromNode.y, toNode.x, toNode.y)
        }

        function arrow(ctx, fromX, fromY, toX, toY) {
            var dx = toX - fromX
            var dy = toY - fromY
            var dl = Math.sqrt(dx * dx + dy * dy)
            var nx = dx / dl
            var ny = dy / dl
            var size = 1

            ctx.moveTo(fromX, fromY);
            ctx.lineTo(toX, toY);
        }

    }

    CNVPipelineNode {
        id: faNode
        text: qsTr("Reference genome (.fa)")
        radius: root.nodeRadius
        x: bamNode.x
        y: bamNode.y - root.spacing
    }

    CNVPipelineNode {
        id: bamNode
        text: qsTr("Aligned sequencing reads (.bam)")
        radius: root.nodeRadius
        x: targetNode.x + root.spacing
        y: targetNode.y
    }

    CNVPipelineNode {
        id: targetNode
        text: qsTr("Target regions (.bed)")
        radius: root.nodeRadius
        x: 150
        y: 170
    }

    CNVPipelineNode {
        id: antitargetNode
        text: qsTr("antitarget")
        radius: root.nodeRadius
        x: targetNode.x - root.spacing
        y: targetNode.y
        command: true
    }

    CNVPipelineNode {
        id: antitargetOutNode
        text: qsTr("Antitarget regions (.bed)")
        radius: root.nodeRadius
        x: antitargetNode.x
        y: antitargetNode.y + root.spacing
    }

    CNVPipelineNode {
        id: coverageNode
        text: qsTr("coverage")
        radius: root.nodeRadius
        x: antitargetOutNode.x + root.spacing
        y: antitargetOutNode.y
        command: true
    }

    CNVPipelineNode {
        id: coverageOutNode
        text: qsTr("Bin Coverages (.cnn)")
        radius: root.nodeRadius
        x: coverageNode.x
        y: coverageNode.y + root.spacing
    }

    CNVPipelineNode {
        id: fixNode
        text: qsTr("fix")
        radius: root.nodeRadius
        x: coverageOutNode.x
        y: coverageOutNode.y + root.spacing
        command: true
    }

    CNVPipelineNode {
        id: referenceNode
        text: qsTr("reference")
        radius: root.nodeRadius
        x: coverageOutNode.x - root.spacing
        y: coverageOutNode.y
        command: true
    }

    CNVPipelineNode {
        id: referenceOutNode
        text: qsTr("Reference (.cnn)")
        radius: root.nodeRadius
        x: referenceNode.x
        y: referenceNode.y + root.spacing
    }

    CNVPipelineNode {
        id: cnrNode
        text: qsTr("Copy Ratios (.cnr)")
        radius: root.nodeRadius
        x: fixNode.x
        y: fixNode.y + root.spacing
    }

    CNVPipelineNode {
        id: segmentNode
        text: qsTr("segment")
        radius: root.nodeRadius
        x: cnrNode.x
        y: cnrNode.y + root.spacing
        command: true
    }

    CNVPipelineNode {
        id: cnsNode
        text: qsTr("Copy Segments (.cns)")
        radius: root.nodeRadius
        x: segmentNode.x
        y: segmentNode.y + root.spacing
    }

    states: [
        State {
            name: "PICK_REFERENCE"
            PropertyChanges { target: faNode; background: root.duringColor }
        },
        State {
            name: "REFERENCE_PICKED"
            PropertyChanges { target: faNode; background: root.doneColor }
        },
        State {
            name: "PICK_BAM"
            extend: "REFERENCE_PICKED"
            PropertyChanges { target: bamNode; background: root.duringColor }
        },
        State {
            name: "BAM_PICKED"
            extend: "REFERENCE_PICKED"
            PropertyChanges { target: bamNode; background: root.doneColor }
        },
        State {
            name: "PICK_TARGET"
            extend: "BAM_PICKED"
            PropertyChanges { target: targetNode; background: root.duringColor }
        },
        State {
            name: "TARGET_PICKED"
            extend: "BAM_PICKED"
            PropertyChanges { target: targetNode; background: root.doneColor }
        },
        State {
            name: "DO_ANTITARGET"
            extend: "TARGET_PICKED"
            PropertyChanges { target: antitargetNode; background: root.duringColor }
        },
        State {
            name: "ANTITARGET_DONE"
            extend: "TARGET_PICKED"
            PropertyChanges { target: antitargetNode; background: root.doneColor }
            PropertyChanges { target: antitargetOutNode; background: root.doneColor }
        },
        State {
            name: "DO_COVERAGE"
            extend: "ANTITARGET_DONE"
            PropertyChanges { target: coverageNode; background: root.duringColor }
        },
        State {
            name: "COVERAGE_DONE"
            extend: "ANTITARGET_DONE"
            PropertyChanges { target: coverageNode; background: root.doneColor }
            PropertyChanges { target: coverageOutNode; background: root.doneColor }
        },
        State {
            name: "DO_REFERENCE"
            extend: "COVERAGE_DONE"
            PropertyChanges { target: referenceNode; background: root.duringColor }
        },
        State {
            name: "REFERENCE_DONE"
            extend: "COVERAGE_DONE"
            PropertyChanges { target: referenceNode; background: root.doneColor }
            PropertyChanges { target: referenceOutNode; background: root.doneColor }
        },
        State {
            name: "DO_FIX"
            extend: "REFERENCE_DONE"
            PropertyChanges { target: fixNode; background: root.duringColor }
        },
        State {
            name: "FIX_DONE"
            extend: "REFERENCE_DONE"
            PropertyChanges { target: fixNode; background: root.doneColor }
            PropertyChanges { target: cnrNode; background: root.doneColor }
        },
        State {
            name: "DO_SEGMENT"
            extend: "FIX_DONE"
            PropertyChanges { target: segmentNode; background: root.duringColor }
        },
        State {
            name: "SEGMENT_DONE"
            extend: "FIX_DONE"
            PropertyChanges { target: segmentNode; background: root.doneColor }
            PropertyChanges { target: cnsNode; background: root.doneColor }
        }
    ]

}

