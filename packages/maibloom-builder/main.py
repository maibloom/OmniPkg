import sys
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QProgressBar, QLabel
from PyQt5.QtCore import QBasicTimer

class ProgressBarApp(QWidget):
    def __init__(self):
        super().__init__()

        self.initUI()

        self.timer = QBasicTimer()
        self.step = 0

    def initUI(self):
        self.setWindowTitle('Installation Progress')

        self.layout = QVBoxLayout()

        self.label = QLabel('Installation is in progress...', self)
        self.layout.addWidget(self.label)

        self.progressBar = QProgressBar(self)
        self.layout.addWidget(self.progressBar)

        self.setLayout(self.layout)

        self.startProgress()

    def startProgress(self):
        self.step = 0
        self.progressBar.setValue(self.step)
        self.timer.start(100, self)  # Update every 100 ms

    def timerEvent(self, event):
        if self.step >= 100:
            self.timer.stop()
            return
        self.step += 1
        self.progressBar.setValue(self.step)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = ProgressBarApp()
    ex.resize(300, 100)
    ex.show()
    sys.exit(app.exec_())
