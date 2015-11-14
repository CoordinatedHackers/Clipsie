import Cocoa
import ClipsieKit

@NSApplicationMain
class AppDelegate:
    NSObject, NSApplicationDelegate, NSMenuDelegate, NSUserNotificationCenterDelegate,
    ClipsieKit.AdvertiserDelegate, ClipsieKit.BrowserDelegate
{
    
    @IBOutlet var statusMenu: NSMenu!
    
    weak var helpWindow: HelpWindowController? = nil

    var clipboardString: String? = nil
    var statusItem: NSStatusItem? = nil
    var menuItemsByDestination = [PeerID: NSMenuItem]()
    
    var showStatusItem: Bool = false {
        didSet {
            if showStatusItem {
                if self.statusItem != nil { return }
                let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(24)
                self.statusItem = statusItem
                statusItem.menu = self.statusMenu
                let image = NSImage(named: "StatusMenu")!
                image.template = true
                statusItem.button!.image = image
            } else {
                statusItem = nil
            }
        }
    }
    
    let uuid: String = {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let uuid = defaults.stringForKey("UUID") {
            return uuid
        }
        let uuid = NSUUID().UUIDString
        defaults.setObject(uuid, forKey: "UUID")
        defaults.synchronize()
        return uuid
    }()
    let peerID = ClipsieKit.PeerID()
    let advertiser: ClipsieKit.Advertiser
    let browser: ClipsieKit.Browser
    
    // MARK: - Core Data
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.URLByAppendingPathComponent(NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as! String)
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle(identifier: "com.coordinatedhackers.ClipsieKit")!.URLForResource("Clipsie", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil)
        
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Clipsie.storedata")
        try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: -
    
    override init() {
        advertiser = ClipsieKit.Advertiser(peerID)
        browser = ClipsieKit.Browser(peerID)
        super.init()
        advertiser.delegate = self
        browser.delegate = self
    }
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        pruneOffers()
        
        advertiser.start()
        browser.start()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey(HasShownFirstLaunchHelpKey) == false {
            showHelp()
        }
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showHelp()
        return true
    }
    
    func acceptOffer(offer: ClipsieKit.Offer) {
        switch offer {
        case .Text(let string):
            // For convenience, open http(s) URLs instead of copying them
            if let url = string.asURL {
                NSWorkspace.sharedWorkspace().openURL(url)
                return
            }
            
            let pb = NSPasteboard.generalPasteboard()
            pb.clearContents()
            pb.writeObjects([string])
            Toast("Copied").present(0.5, 0.5)
        }
    }
    
    // Only keep offers which exist as notifications, and only keep notifications which exist as offers
    func pruneOffers() {
        var leftoverNotificationsByObjectID = [NSManagedObjectID: NSUserNotification]()
        let userNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        
        for notification in userNotificationCenter.deliveredNotifications {
            if let idString = notification.userInfo?["id"] as? String {
                if let idURL = NSURL(string: idString) {
                    if let id = persistentStoreCoordinator.managedObjectIDForURIRepresentation(idURL) {
                        leftoverNotificationsByObjectID[id] = notification
                    }
                }
            }
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Offer")
        fetchRequest.includesPropertyValues = false
        if let offers = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
            for offer in offers {
                if leftoverNotificationsByObjectID.removeValueForKey(offer.objectID) == nil {
                    managedObjectContext.deleteObject(offer)
                }
            }
            try! managedObjectContext.save()
        }
        
        for (_, leftoverNotification) in leftoverNotificationsByObjectID {
            userNotificationCenter.removeDeliveredNotification(leftoverNotification)
        }
        
    }
    
    // MARK: - Actions
    
    func sendMenuItemClicked(sender: NSMenuItem) {
        if let peerID = sender.representedObject as? ClipsieKit.PeerID {
            if let clipboardString = clipboardString {
                if let session = ClipsieKit.OutboundSession.with(peerID) {
                    session.offerText(clipboardString)
                        .catchError { print("Failed to send an offer: \($0)") }
                }
            }
        }
    }
    
    func menuWillOpen(menu: NSMenu) {
        clipboardString = NSPasteboard.generalPasteboard().stringForType(NSPasteboardTypeString)
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        return menuItem.representedObject == nil || clipboardString != nil
    }
    
    func menuDidClose(menu: NSMenu) {
        // Let the action fire
        dispatch_after(0, dispatch_get_main_queue()) {
            self.clipboardString = nil
        }
    }
    
    func showHelp() {
        if let helpWindow = helpWindow {
            helpWindow.focus()
            return
        }
        helpWindow = (NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("help_window") as! HelpWindowController)
        helpWindow!.focus()
    }
    
    @IBAction func showHelp(sender: AnyObject?) {
        showHelp()
    }
    
    // MARK: - ClipsieAdvertiserDelegate
    
    func gotOffer(offer: ClipsieKit.Offer) {
        let storedOffer = offer.toStored(managedObjectContext)!
        try! managedObjectContext.save()
        
        let notification = NSUserNotification()
        notification.title = "Click to copy"
        switch offer {
        case .Text(let string):
            let preview = string.truncate(20, overflow: "…")
            notification.informativeText = "\"\(preview)\""
        }
        notification.userInfo = ["id": storedOffer.objectID.URIRepresentation().absoluteString]
        
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        pruneOffers()
    }
    
    // MARK: - ClipsieBrowserDelegate
    
    func foundPeer(peer: ClipsieKit.PeerID) {
        let menuItem = NSMenuItem()
        menuItem.representedObject = peer
        menuItem.title = peer.displayName
        menuItem.target = self
        menuItem.action = "sendMenuItemClicked:"
        
        menuItemsByDestination[peer] = menuItem
        
        statusMenu.insertItem(menuItem, atIndex: 0)
        showStatusItem = true
    }
    
    func lostPeer(peer: ClipsieKit.PeerID) {
        if let menuItem = menuItemsByDestination.removeValueForKey(peer) {
            statusMenu.removeItem(menuItem)
        }
        if menuItemsByDestination.count == 0 {
            showStatusItem = false
        }
    }
    
    // MARK: - NSUserNotificationCenterDelegate
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        acceptOffer((managedObjectContext.objectWithID(
            persistentStoreCoordinator.managedObjectIDForURIRepresentation(
                NSURL(string: notification.userInfo!["id"] as! String)!
            )!
        ) as! ClipsieKit.StoredOffer).getOffer()!)
    }
}

