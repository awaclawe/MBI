import os

from PyQt5.QtCore import pyqtProperty, pyqtSignal, pyqtSlot
from PyQt5.QtCore import Qt, QObject, QUrl

import cnvlib
import skgenome.tabio

class Controller(QObject):

    def __init__(self, parent=None):
        QObject.__init__(self, parent)
        self._referenceUrl = QUrl()
        self._bamUrl = QUrl()
        self._targetUrl = QUrl()
        self._state = ""
        self.reset()

        # Intermediate variables
        self._target = None
        self._antitarget = None
        self._target_coverage = None
        self._antitarget_coverage = None
        self._reference = None
        self._cnarr = None

    stateChanged = pyqtSignal()
    referenceUrlChanged = pyqtSignal()
    bamUrlChanged = pyqtSignal()
    targetUrlChanged = pyqtSignal()

    logMessage = pyqtSignal(str, arguments=["msg"])

    @pyqtProperty(str, notify=stateChanged)
    def state(self):
        return self._state

    @pyqtProperty(QUrl, notify=referenceUrlChanged)
    def referenceUrl(self):
        return self._referenceUrl

    @referenceUrl.setter
    def referenceUrl(self, value):
        if self._referenceUrl != value:
            self._referenceUrl = value
            self.referenceUrlChanged.emit()

    @pyqtProperty(QUrl, notify=bamUrlChanged)
    def bamUrl(self):
        return self._bamUrl

    @bamUrl.setter
    def bamUrl(self, value):
        if self._bamUrl != value:
            self._bamUrl = value
            self.bamUrlChanged.emit()

    @pyqtProperty(QUrl, notify=targetUrlChanged)
    def targetUrl(self):
        return self._targetUrl

    @targetUrl.setter
    def targetUrl(self, value):
        if self._targetUrl != value:
            self._targetUrl = value
            self.targetUrlChanged.emit()

    @pyqtSlot(QUrl)
    def pickReferenceGenome(self, refernceUrl):
        if self._state != "PICK_REFERENCE":
            raise Exception("Invalid state transition")
        self.referenceUrl = refernceUrl
        self.logMessage.emit("Setting reference genome file path to " + self.referenceUrl.toLocalFile())
        self._set_state("PICK_BAM")

    @pyqtSlot(QUrl)
    def pickBam(self, bamUrl):
        if self._state != "PICK_BAM":
            raise Exception("Invalid state transition")
        self.bamUrl = bamUrl
        self.logMessage.emit("Setting input BAM file path to " + self.bamUrl.toLocalFile())
        self._set_state("PICK_TARGET")

    def _target_path(self):
        target_path = self.targetUrl.toLocalFile()
        return target_path + ".target.bed"

    def _antitarget_path(self):
        target_path = self.targetUrl.toLocalFile()
        return target_path + ".antitarget.bed"

    @pyqtSlot(QUrl)
    def pickTarget(self, targetUrl):
        if self._state != "PICK_TARGET":
            raise Exception("Invalid state transition")
        self.targetUrl = targetUrl

        targetPath = self.targetUrl.toLocalFile()

        self.logMessage.emit("Reading raw target file " + targetPath)
        raw = skgenome.tabio.read_auto(targetPath)
        self.logMessage.emit("Invoking cnvlib.do_target(" + targetPath + ")")
        self._target = cnvlib.do_target(raw)
        self.logMessage.emit("Saving target BED file to " + self._target_path())
        skgenome.tabio.write(self._target, self._target_path())

        self._set_state("DO_ANTITARGET")

    @pyqtSlot()
    def doAntitarget(self):
        if self._state != "DO_ANTITARGET":
            raise Exception("Invalid state transition")

        self.logMessage.emit("Invoking cnvlib.do_antitarget(" + self.targetUrl.toLocalFile() + ")")
        self._antitarget = cnvlib.do_antitarget(self._target)
        self.logMessage.emit("Saving antitarget BED file to " + self._antitarget_path())
        skgenome.tabio.write(self._antitarget, self._antitarget_path())

        self._set_state("DO_COVERAGE")

    def _target_coverage_path(self):
        target_path = self.targetUrl.toLocalFile()
        return target_path + ".targetcoverage.cnn"

    def _antitarget_coverage_path(self):
        target_path = self.targetUrl.toLocalFile()
        return target_path + ".antitargetcoverage.cnn"

    @pyqtSlot()
    def doCoverage(self):
        if self._state != "DO_COVERAGE":
            raise Exception("Invalid state transition")

        bamFname = self.bamUrl.toLocalFile()

        self.logMessage.emit("Invoking cnvlib.do_coverage(" + self._target_path() + ", " + bamFname + ")")
        self._target_coverage = cnvlib.do_coverage(self._target_path(), bamFname)
        self.logMessage.emit("Invoking cnvlib.do_coverage(" + self._antitarget_path() + ", " + bamFname + ")")
        self._antitarget_coverage = cnvlib.do_coverage(self._antitarget_path(), bamFname)

        self.logMessage.emit("Saving target coverage file to " + self._target_coverage_path())
        skgenome.tabio.write(self._target_covegae, self._target_coverage_path())
        self.logMessage.emit("Saving antitarget coverage file to " + self._antitarget_coverage_path())
        skgenome.tabio.write(self._antitarget_coverage, self._antitarget_coverage_path())

        self._set_state("DO_REFERENCE")

    @pyqtSlot()
    def doReference(self):
        if self._state != "DO_REFERENCE":
            raise Exception("Invalid state transition")

        self.logMessage.emit("Invoking cnvlib.do_reference(" + self._target_coverage_path() + ", " + self._antitarget_coverage_path() + ", " + self.referenceUrl.toLocalFile() + ")")
        self._reference = cnvlib.do_reference(self._target_coverage_path(), self._antitarget_coverage_path(),
                                              self.referenceUrl.toLocalFile())

        self._set_state("DO_FIX")

    def _cnarr_path(self):
        target_path = self.targetUrl.toLocalFile()
        return target_path + ".cnr"

    @pyqtSlot()
    def doFix(self):
        if self._state != "DO_FIX":
            raise Exception("Invalid state transition")

        self.logMessage.emit("Invoking cnvlib.do_fix(" + self._target_coverage_path() + ", " + self._antitarget_coverage_path() + ", <internal_reference>" ")")
        self._cnarr = cnvlib.do_fix(self._target_coverage, self._antitarget_coverage, self._reference)

        self.logMessage.emit("Saving fixed CNVs to " + self._cnarr_path())
        skgenome.tabio.write(self._cnarr, self._cnarr_path())

        self._set_state("DO_SEGMENT")

    def _segments_path(self):
        target_path = self.targetUrl.toLocalFile()
        return target_path + ".cns"

    @pyqtSlot()
    def doSegment(self):
        if self._state != "DO_SEGMENT":
            raise Exception("Invalid state transition")

        segments = cnvlib.do_segmentation(self._cnarr, 'cbs')
        self.logMessage.emit("Saving CNV segments to " + self._segments_path())
        skgenome.tabio.write(segments, self._segments_path())

        self._set_state("SEGMENT_DONE")

    @pyqtSlot()
    def reset(self):
        self.referenceUrl = QUrl()
        self.bamUrl = QUrl()
        self.targetUrl = QUrl()
        self._set_state("PICK_REFERENCE")

    def _set_state(self, value):
        if self._state != value:
            self._state = value
            self.stateChanged.emit()
