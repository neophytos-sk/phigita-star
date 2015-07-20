import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtWebKit import *

app = QApplication(sys.argv)

web = QWebView()
# web.settings().setAttribute(QWebSettings.WebAttribute.DeveloperExtrasEnabled, True)
# or globally:
# QWebSettings.globalSettings().setAttribute(
#     QWebSettings.WebAttribute.DeveloperExtrasEnabled, True)

web.load(QUrl("http://www.google.com"))
web.show()

inspect = QWebInspector()
inspect.setPage(web.page())
inspect.show()

sys.exit(app.exec_())
