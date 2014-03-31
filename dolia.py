from Foundation import NSNetService, NSNetServiceBrowser, NSObject
from PyObjCTools import AppHelper

class BrowserDelegate(NSObject):

	def init(self):
		self = super(BrowserDelegate, self).init()

		self.services = set()

		return self

	def netServiceBrowser_didFindService_moreComing_(
		self, browser, aNetService, moreComing
	):
		self.services.add(aNetService)
		if not moreComing and hasattr(self, 'found_cb'):
			self.found_cb(self.services)

	def netServiceBrowser_didRemoveService_moreComing_(
		self, browser, aNetService, moreComing
	):
		self.services.remove(aNetService)
	

def gogogo():
	def onSearched(services):
		for service in services:
			print NSNetService.dictionaryFromTXTRecordData_(service.TXTRecordData())


	browserDelegate = BrowserDelegate.new()
	browserDelegate.found_cb = onSearched
	browser = NSNetServiceBrowser.new()
	browser._.delegate = browserDelegate
	browser.searchForServicesOfType_inDomain_("_dolia._tcp", "local.")


	AppHelper.runConsoleEventLoop(installInterrupt=True)

if __name__ == "__main__":
    gogogo()
