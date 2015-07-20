'''
Note: Tested with LINUX only (known to work on Ubuntu / Suse)

Xvfb must be installed for this to work
Xvfb is usually found in a xorg-x11-server-extras package.
In Ubuntu install with 'sudo apt-get install xvfb'

To create a virtual frame buffer we execute:
 Xvfb :1 -screen 1 1600x1200x16
'''

__author__ = 'Ben DeMott'
__date__ = 'Aug 20, 2012'

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtWebKit import *
import subprocess
import os
import sys
import time
import signal

class Browser(QObject):
	'''
	Renders a webkit view gets the contents of the page - requires Xvfb
	
	Usage:
		webkit = Browser()
		webkit.save_image('http://google.com', 'google.png', width=1280)
		
		
	Issues:
		-Sometimes there is quite a lot of extra white-space at the bottom of
		 the image.
	'''
	
	image_extensions = ('BMP', 'GIF', 'JPG', 'JPEG', 'PNG', 'PBM', 'PGM', 'PPM', 'TIFF', 'XBM', 'XPM')
	
	def __init__(self, silence_xvfb=True, display='1', screen='0', xvfb_timeout=3):
		'''
		use silence_xvfb=False to show frame-buffer errors (debugging)
		the display and screen arguments are arbitrary really - but this is the
		  X display and screen id's that will be used for the frame buffer.
		'''
		self.html = None
		self.pidfile = '/tmp/.X%s-lock' % display
		redirect = '> /dev/null 2>&1'
		if not silence_xvfb:
			redirect = ''
		cmd = ' '.join(['Xvfb', ':'+display, '-screen', screen, '1600x1200x24', redirect])
		if(os.path.isfile(self.pidfile)):
			self._kill_xvfb()
		os.system(cmd+' &')

		self.xvfb = True
		start = time.time()
		while(True):
			diff = time.time() - start
			if(diff > xvfb_timeout):
				raise SystemError("Timed-Out waiting for Xvfb to start - {0} sec".format(xvfb_timeout))
			if(os.path.isfile(self.pidfile)):
				break
			else:
				time.sleep(0.05)

		# You must tell QT which X11 display to connect to through the env variable
		# 'DISPLAY' - the argument '-display' passed to the constructor doesn't
		# seem to work.
		os.putenv('DISPLAY', ':%s' % display)
		self.qtapp = QApplication([])
		self.browser = QWebPage()
		self.browser.mainFrame().setScrollBarPolicy(Qt.Horizontal, Qt.ScrollBarAlwaysOff)
		self.browser.mainFrame().setScrollBarPolicy(Qt.Vertical,   Qt.ScrollBarAlwaysOff)
		self.executing = False
		self.connect(self.browser, SIGNAL("loadFinished(bool)"), lambda: self._request_finished() )
		


	def _kill_xvfb(self):
		pid = int(open(self.pidfile).read().strip())
		os.kill(pid, signal.SIGINT)

	def _request(self, url):
		'''
		Render a webpage using webkit, return the html contents
		This is the function that kicks things off
		'''
		self.url = url
		if not self.executing:
			self.executing = True
			# We can't call browser.mainFrame().load() until the event loop
			# is started - but the event loop blocks the application...
			# so to get around this hurtle we schedule an event in the event loop
			# that will call our startup code ...
			# This allows QT to get started, but also ensures our task will run
			# as soon as it get's started.
			QTimer().singleShot(0, lambda: self._execute_request() )
			self.qtapp.exec_()
		else:
			raise Exception("Request already in progress!")

	def _execute_request(self):
		#This needs to be called AFTER app.exec_()
		self.browser.mainFrame().load(QUrl(self.url))
		#Now block and wait for our response.
		while self.executing:
			#Because we've now taken over the event-loop we can still give QT
			#the ability to process it's events by calling this:
			QCoreApplication.processEvents()
			
		QCoreApplication.quit()  #Quit the QT main loop

		self.title = self.browser.mainFrame().title()
		self.ascii = self.browser.mainFrame().toPlainText().toAscii()
		self.html = self.browser.mainFrame().toHtml().toAscii()

	def _request_finished(self):
		self.executing = False

	def save_image(self, url, filename, width=1024):
		'''
		Save a screenshot of webkits rendered contents to disk
		'''
		self._request(url)
		size = self.browser.mainFrame().contentsSize()
		if width > 0:
			size.setWidth(width)
		self.browser.setViewportSize(size)
		
		# Render the virtual browsers viewport to an image.
		image = QImage(self.browser.viewportSize(), QImage.Format_ARGB32)
		paint = QPainter(image) #Have the painters target be our image object
		self.browser.mainFrame().render(paint) #Render browser window to painter
		paint.end()
		image = image.scaledToWidth(width) #ensure the image is your desired width
		extension = os.path.splitext(filename)[1][1:].upper()  #save the file as your desired image extension
		if extension not in self.image_extensions:
			raise ValueError("'filename' must be a valid extension: {0}".format(self.image_extensions))
		image.save(filename, extension)

	def get_html(self, url):
		'''
		Get HTML Source of the page (after rendering / javascript)
		'''
		self._request(url)
		if( isinstance(self.html, QByteArray) ):
			return str(self.html)

	def __del__(self):
		# Kill the frame buffer
		if(self.xvfb):
			self._kill_xvfb()
			
def main(argv=None):
	webkit = Browser()
	path = 'python.png'
	webkit.save_image('http://python.org', path, width=1280)
	print "Image Saved to", path
	del webkit
		
if __name__ == '__main__':
	sys.exit(main(sys.argv))