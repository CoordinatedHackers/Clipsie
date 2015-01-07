import Cocoa
import MultipeerConnectivity

let URLRegex = NSRegularExpression(pattern: "^https?://[^\\s]+$", options: .CaseInsensitive, error: nil)!

func offerFromClipboard(managedObjectContext: NSManagedObjectContext) -> ClipsieOffer? {
    if let pasteboardString = NSPasteboard.generalPasteboard().stringForType(NSPasteboardTypeString) {
        let offer = ClipsieTextOffer.inManagedObjectContext(managedObjectContext) as ClipsieTextOffer
        offer.text = pasteboardString
        return offer
    }
    return nil
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ClipsieAdvertiserDelegate, ClipsieBrowserDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet var statusMenu: NSMenu!
    @IBOutlet var nearbyMenuItem: NSMenuItem!

    let statusItem: NSStatusItem
    var menuItemsByDestination = [ClipsiePeer: NSMenuItem]()
    
    let peerID = MCPeerID(displayName: NSHost.currentHost().localizedName)
    let advertiser: ClipsieAdvertiser
    let browser: ClipsieBrowser
    
    // MARK: - Core Data
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as NSURL
        return appSupportURL.URLByAppendingPathComponent(NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as String)
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Clipsie", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let fileManager = NSFileManager.defaultManager()
        fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: nil)
        
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Clipsie.storedata")
        coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: nil)
        
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
        advertiser = ClipsieAdvertiser(peerID)
        browser = ClipsieBrowser(peerID)
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(24)
        super.init()
        advertiser.delegate = self
        browser.delegate = self
    }
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        statusItem.menu = self.statusMenu
        let menuImage = NSImage(named: "StatusMenu")
        menuImage!.size = NSSize(width: menuImage!.size.width / menuImage!.size.height * 18, height: 18)
        statusItem.button!.image = menuImage
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        pruneOffers()
        
        advertiser.start()
        browser.start()
    }
    
    func acceptOffer(offer: ClipsieOffer) {
        
        if let offer = offer as? ClipsieTextOffer {
            if let string = offer.text as? String {
                // For convenience, open http(s) URLs instead of copying them
                if URLRegex.numberOfMatchesInString(string, options: NSMatchingOptions(0), range: NSRange(location: 0, length: countElements(string))) == 1 {
                    if let url = NSURL(string: string) {
                        NSWorkspace.sharedWorkspace().openURL(url)
                        return
                    }
                }

                let pb = NSPasteboard.generalPasteboard()
                pb.clearContents()
                pb.writeObjects([string])
                Toast("Copied").present(0.5, 0.5)
            }
        }
    }
    
    // Only keep offers which exist as notifications, and only keep notifications which exist as offers
    func pruneOffers() {
        var leftoverNotificationsByObjectID = [NSManagedObjectID: NSUserNotification]()
        let userNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        
        for notification in userNotificationCenter.deliveredNotifications as [NSUserNotification] {
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
        if let offers = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) {
            for offer in offers as [ClipsieOffer] {
                if leftoverNotificationsByObjectID.removeValueForKey(offer.objectID) == nil {
                    managedObjectContext.deleteObject(offer)
                }
            }
            managedObjectContext.save(nil)
        }
        
        for (id, leftoverNotification) in leftoverNotificationsByObjectID {
            userNotificationCenter.removeDeliveredNotification(leftoverNotification)
        }
        
    }
    
    // MARK: - Actions
    
    func sendMenuItemClicked(sender: NSMenuItem) {
        let ephemeralManagedObjectContext = NSManagedObjectContext()
        ephemeralManagedObjectContext.parentContext = managedObjectContext
        if let offer = offerFromClipboard(ephemeralManagedObjectContext) {
            (sender.representedObject as ClipsiePeer).send(offer)
        }
    }
    
    // MARK: - ClipsieAdvertiserDelegate
    
    func gotOffer(offer: ClipsieOffer) {
        managedObjectContext.save(nil)
        
        let notification = NSUserNotification()
        notification.title = "From \(offer.senderName)"
        let preview = offer.preview.truncate(20, overflow: "…")
        notification.informativeText = "Clipboard: \"\(preview)\""
        notification.userInfo = ["id": offer.objectID.URIRepresentation().absoluteString!]
        
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        pruneOffers()
    }
    
    // MARK: - ClipsieBrowserDelegate
    
    func foundPeer(peer: ClipsiePeer) {
        let menuItem = NSMenuItem()
        menuItem.representedObject = peer
        menuItem.title = peer.theirPeerID.displayName
        menuItem.target = self
        menuItem.action = "sendMenuItemClicked:"
        
        menuItemsByDestination[peer] = menuItem
        
        statusMenu.insertItem(menuItem, atIndex: statusMenu.indexOfItem(nearbyMenuItem) + 1)
        nearbyMenuItem.hidden = false
    }
    
    func lostPeer(peer: ClipsiePeer) {
        if let menuItem = menuItemsByDestination.removeValueForKey(peer) {
            statusMenu.removeItem(menuItem)
            nearbyMenuItem.hidden = menuItemsByDestination.isEmpty
        }
    }
    
    // MARK: - NSUserNotificationCenterDelegate
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        acceptOffer(managedObjectContext.objectWithID(
            persistentStoreCoordinator.managedObjectIDForURIRepresentation(
                NSURL(string: notification.userInfo!["id"] as String)!
            )!
        ) as ClipsieOffer)
    }
}

