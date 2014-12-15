import Cocoa
import MultipeerConnectivity

func offerFromClipboard(managedObjectContext: NSManagedObjectContext) -> ClipsieOffer? {
    if let pasteboardObjects = NSPasteboard.generalPasteboard().readObjectsForClasses(
        [NSURL.self, NSString.self],
        options: nil
    ) {
        if pasteboardObjects.isEmpty { return nil }
        let pbItem: AnyObject = pasteboardObjects[0]
        
        if pbItem.isKindOfClass(NSURL.self) {
            let offer = ClipsieURLOffer.inManagedObjectContext(managedObjectContext) as ClipsieURLOffer
            offer.url = (pbItem as NSURL).absoluteString!
            return offer
        }
        
        if pbItem.isKindOfClass(NSString.self) {
            let pbString = pbItem as String
            let urlRegex = NSRegularExpression(pattern: "https?:.*", options: .CaseInsensitive, error: nil)!
            
            if urlRegex.numberOfMatchesInString(pbString, options: NSMatchingOptions(0), range: NSRange(location: 0, length: countElements(pbString))) != 0 {
                if let url = NSURL(string: pbString) {
                    let offer = ClipsieURLOffer.inManagedObjectContext(managedObjectContext) as ClipsieURLOffer
                    offer.url = pbString
                    return offer
                }
            }
            
            let offer = ClipsieTextOffer.inManagedObjectContext(managedObjectContext) as ClipsieTextOffer
            offer.string = pbString
            return offer
        }      
    }
    
    return nil
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ClipsieAdvertiserDelegate, ClipsieBrowserDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet var statusMenu: NSMenu!
    @IBOutlet var inboxArrayController: NSArrayController!
    @IBOutlet var inboxTitleMenuItem: NSMenuItem!

    let statusItem: NSStatusItem
    var inboxMenuItems = [NSMenuItem]()
    var menuItemsByDestination = [ClipsiePeer: NSMenuItem]()
    
    let peerID = MCPeerID(displayName: NSHost.currentHost().localizedName)
    let advertiser: ClipsieAdvertiser
    let browser: ClipsieBrowser
    
    // MARK: - Core Data
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as NSURL
        return appSupportURL.URLByAppendingPathComponent("com.coordinatedhackers.Clipsie")
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
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            NSManagedObjectContextWillSaveNotification,
            object: self.managedObjectContext,
            queue: nil
        ) { (notification: NSNotification!) -> () in
            let fetchRequest = self.managedObjectModel.fetchRequestTemplateForName("AllOffers")!
            var allOffers = self.managedObjectContext.executeFetchRequest(fetchRequest, error: nil)! as [NSManagedObject]
            while allOffers.count > 5 {
                self.managedObjectContext.deleteObject(allOffers.last!)
                allOffers.removeLast()
            }
        }
        
        inboxArrayController!.addObserver(self, forKeyPath: "arrangedObjects", options: NSKeyValueObservingOptions(), context: nil)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        advertiser.start()
        browser.start()
    }
    
    func sendMenuItemClicked(sender: NSMenuItem) {
        let ephemeralManagedObjectContext = NSManagedObjectContext()
        ephemeralManagedObjectContext.parentContext = managedObjectContext
        if let offer = offerFromClipboard(ephemeralManagedObjectContext) {
            (sender.representedObject as ClipsiePeer).send(offer)
        }
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        willChangeValueForKey("isInboxEmpty")
        didChangeValueForKey("isInboxEmpty")
        
        for menuItem in inboxMenuItems {
            statusMenu.removeItem(menuItem)
        }
        
        inboxMenuItems.removeAll()
        
        for offer in inboxArrayController.arrangedObjects as [ClipsieOffer] {
            let offerMenuItem = NSMenuItem()
            offerMenuItem.representedObject = offer
            offerMenuItem.title = offer.preview.truncate(20, overflow:"…")
            offerMenuItem.target = self
            offerMenuItem.action = "offerMenuItemClicked:"
            inboxMenuItems.append(offerMenuItem)
            statusMenu.insertItem(offerMenuItem, atIndex: statusMenu.indexOfItem(inboxTitleMenuItem) + 1)
        }
    }
    
    // MARK: - Actions
    
    func offerMenuItemClicked(menuItem: NSMenuItem) {
        let offer = menuItem.representedObject as ClipsieOffer
        let pb = NSPasteboard.generalPasteboard()
        
        if let offer = offer as? ClipsieTextOffer {
            if let string = offer.string {
                pb.clearContents()
                pb.writeObjects([string])
            }
        } else if let offer = offer as? ClipsieURLOffer {
            if let urlString = offer.url {
                if let url = NSURL(string: urlString) {
                    pb.clearContents()
                    pb.writeObjects([url])
                }
            }
        }
    }
    
    // MARK: - ClipsieAdvertiserDelegate
    
    func gotOffer(offer: ClipsieOffer) {
        managedObjectContext.save(nil)
    }
    
    // MARK: - ClipsieBrowserDelegate
    
    func foundPeer(peer: ClipsiePeer) {
        let menuItem = NSMenuItem()
        menuItem.representedObject = peer
        menuItem.title = peer.theirPeerID.displayName
        menuItem.target = self
        menuItem.action = "sendMenuItemClicked:"
        
        statusMenu.insertItem(menuItem, atIndex: 0)
        menuItemsByDestination[peer] = menuItem
    }
    
    func lostPeer(peer: ClipsiePeer) {
        if let menuItem = menuItemsByDestination[peer] {
            statusMenu.removeItem(menuItem)
        }
    }
}

