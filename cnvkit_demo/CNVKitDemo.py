#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
DESCRIPTION
"""

import sys

from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt5.QtGui import QGuiApplication, QIcon

import cnvkit_demo.resources

from cnvkit_demo.Controller import Controller

__author__ = "Aleksandra Wacławek"

__version = "0.0.1"
__maintainer__ = "Aleksandra Wacławek"
__email__ = "waclawek.ola@gmail.com"


if __name__ == '__main__':

    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()

    qmlRegisterType(Controller, "CNVKitDemo", 1, 0, "Controller")

    engine.quit.connect(app.quit)

    engine.load("qrc/main.qml")

    win = engine.rootObjects()[0]
    win.show()

    ret = app.exec_()

    sys.exit(ret)
