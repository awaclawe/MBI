import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.0

import CNVKitDemo 1.0

Item {
    id: root

    width: 700
    height: 700

    readonly property string fastaFilter: "FASTA files (*.fa *.fasta)"
    readonly property string bamFilter: "BAM files (*.bam *.BAM)"
    readonly property string bedFilter: "BED files (*.bed *.BED)"

    Controller {
        id: controller

        onLogMessage: logModel.append({ text: msg })
    }

    property color duringColor: "#FFE082"
    property color doneColor: "#A5D6A7"

    Rectangle {
        id: centerPane

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: leftPane.right
            right: rightPane.left
        }

            ColumnLayout {

                spacing: 5

                anchors.fill: parent
                anchors.margins: 5

                StagePanel {
                    id: pickReferenceStage
                    stageNo: 1
                    width: parent.width
                    header: qsTr("Pick reference genome FASTA file")
                    Layout.fillWidth: true

                    FilePickStageContent {
                        anchors.fill: parent
                        enabled: pickReferenceStage.current
                        dialogTitle: qsTr("Please choose a reference genome")
                        nameFilter: root.fastaFilter
                        buttonText: qsTr("Choose FASTA File")
                        onPicked: controller.pickReferenceGenome(path)
                        filePath: controller.referenceUrl
                    }

                }

                StagePanel {
                    id: pickBamStage
                    stageNo: 2
                    header: qsTr("Pick input BAM file")
                    Layout.fillWidth: true

                    FilePickStageContent {
                        anchors.fill: parent
                        enabled: pickBamStage.current
                        dialogTitle: qsTr("Please choose input BAM sequence")
                        nameFilter: root.bamFilter
                        buttonText: qsTr("Choose BAM File")
                        onPicked: controller.pickBam(path)
                        filePath: controller.bamUrl
                    }

                }

                StagePanel {
                    id: pickTargetStage
                    stageNo: 3
                    Layout.fillWidth: true
                    header: qsTr("Pick target BED files")

                    FilePickStageContent {
                        anchors.fill: parent
                        enabled: pickTargetStage.current
                        dialogTitle: qsTr("Please choose input BED targets")
                        nameFilter: root.bedFilter
                        buttonText: qsTr("Choose BED file")
                        onPicked: controller.pickTarget(path)
                        filePath: controller.targetUrl
                    }
                }

                StagePanel {
                    id: doAntitargetsStage
                    stageNo: 4
                    Layout.fillWidth: true
                    header: qsTr("Calculate antitargets")

                    AntitargetStageContent {
                        anchors.fill: parent
                        enabled: doAntitargetsStage.current
                        onCalculate: controller.doAntitarget()
                    }

                }

                StagePanel {
                    id: doCoverageStage
                    stageNo: 5
                    Layout.fillWidth: true
                    header: qsTr("Calculate bin coverages")

                    FileGenerationStageContent {
                        anchors.fill: parent
                        enabled: doCoverageStage.current
                        onCalculate: controller.doCoverage()
                    }
                }

                StagePanel {
                    id: doReferenceStage
                    stageNo: 6
                    Layout.fillWidth: true
                    header: qsTr("Calculate reference")

                    FileGenerationStageContent {
                        anchors.fill: parent
                        enabled: doReferenceStage.current
                        onCalculate: controller.doReference()
                    }
                }

                StagePanel {
                    id: doFixStage
                    stageNo: 7
                    Layout.fillWidth: true
                    header: qsTr("Fix")

                    FileGenerationStageContent {
                        anchors.fill: parent
                        enabled: doFixStage.current
                        onCalculate: controller.foFix()
                    }
                }

                StagePanel {
                    id: doSegmentStage
                    stageNo: 8
                    Layout.fillWidth: true
                    header: qsTr("Calculate copy segments")

                   FileGenerationStageContent {
                        anchors.fill: parent
                        enabled: doSegmentStage.current
                        onCalculate: controller.doSegment()
                    }
                }

                Rectangle {
                    id: logContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    border {
                        width: 1
                    }

                    ListModel {
                        id: logModel
                    }

                    ListView {
                        clip: true
                        anchors.fill: parent
                        anchors.margins: 5
                        model: logModel
                        delegate: Text {
                            text: model.text
                        }
                    }

                }

        }
    }

    Rectangle {
        id: leftPane

        width: 50

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        ColumnLayout {

            anchors.fill: parent
            anchors.margins: 5

            Button {
                 Layout.fillWidth: true
                 text: "RS"
                 onClicked: {
                    logModel.clear()
                    controller.reset()
                 }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        color: "lightgray"
    }

    Rectangle {
        id: rightPane

        width: 300

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            height: 30

            color: "gray"

            Text {
                anchors.centerIn: parent
                text: qsTr("CNVKit Pipeline Graph")
                font.pointSize: 11

            }
        }

        CNVPipeline {
            id: cnvPipeline
            duringColor: root.duringColor
            doneColor: root.doneColor
            state: controller.state
        }

        color: "lightgray"
    }

    states: [
        State {
            name: "PICK_REFERENCE"
            PropertyChanges { target: pickReferenceStage; color: root.duringColor; current: true }
        },
        State {
            name: "REFERENCE_PICKED"
            PropertyChanges { target: pickReferenceStage; color: root.doneColor }
        },
        State {
            name: "PICK_BAM"
            extend: "REFERENCE_PICKED"
            PropertyChanges { target: pickBamStage; color: root.duringColor; current: true }
        },
        State {
            name: "BAM_PICKED"
            extend: "REFERENCE_PICKED"
            PropertyChanges { target: pickBamStage; color: root.doneColor }
        },
        State {
            name: "PICK_TARGET"
            extend: "BAM_PICKED"
            PropertyChanges { target: pickTargetStage; color: root.duringColor; current: true }
        },
        State {
            name: "TARGET_PICKED"
            extend: "BAM_PICKED"
            PropertyChanges { target: pickTargetStage; color: root.doneColor }
        },
        State {
            name: "DO_ANTITARGET"
            extend: "TARGET_PICKED"
            PropertyChanges { target: doAntitargetsStage; color: root.duringColor; current: true }
        },
        State {
            name: "ANTITARGET_DONE"
            extend: "TARGET_PICKED"
            PropertyChanges { target: doAntitargetsStage; color: root.doneColor }
        },
        State {
            name: "DO_COVERAGE"
            extend: "ANTITARGET_DONE"
            PropertyChanges { target: doCoverageStage; color: root.duringColor; current: true }
        },
        State {
            name: "COVERAGE_DONE"
            extend: "ANTITARGET_DONE"
            PropertyChanges { target: doCoverageStage; color: root.doneColor }
        },
        State {
            name: "DO_REFERENCE"
            extend: "COVERAGE_DONE"
            PropertyChanges { target: doReferenceStage; color: root.duringColor; current: true }
        },
        State {
            name: "REFERENCE_DONE"
            extend: "COVERAGE_DONE"
            PropertyChanges { target: doReferenceStage; color: root.doneColor }
        },
        State {
            name: "DO_FIX"
            extend: "REFERENCE_DONE"
            PropertyChanges { target: doFixStage; color: root.duringColor; current: true }
        },
        State {
            name: "FIX_DONE"
            extend: "REFERENCE_DONE"
            PropertyChanges { target: doFixStage; color: root.doneColor }
        },
        State {
            name: "DO_SEGMENT"
            extend: "FIX_DONE"
            PropertyChanges { target: doSegmentStage; color: root.duringColor; current: true }
        },
        State {
            name: "SEGMENT_DONE"
            extend: "FIX_DONE"
            PropertyChanges { target: doSegmentStage; color: root.doneColor }
        }
    ]

    state: controller.state

}