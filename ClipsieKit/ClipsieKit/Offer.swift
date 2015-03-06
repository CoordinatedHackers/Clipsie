import CoreData

public enum Offer {
    case Text(String)
}

public class StoredOffer: NSManagedObject {
    @NSManaged var received: NSDate
    @NSManaged var senderName: NSString
    
    class var entityName: String { get { return "Offer" } }

    // I want to return an instance of Self but Swift doesn't support "... as! Self" in the body
    // rdar://19244072
    class func inManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> StoredOffer {
        return NSEntityDescription.insertNewObjectForEntityForName(
            self.entityName, inManagedObjectContext: managedObjectContext
        ) as! StoredOffer
    }
    
    public func getOffer() -> Offer? {
        return nil
    }
    
}

public class StoredTextOffer: StoredOffer {
    @NSManaged var text: NSString?
    
    override class var entityName: String { get { return "TextOffer" } }
    
    override public func getOffer() -> Offer? {
        if let text = text {
            return Offer.Text(text as String)
        }
        return nil
    }
}

extension Offer {
    public func toStored(managedObjectContext: NSManagedObjectContext) -> StoredOffer? {
        var offer: StoredOffer? = nil
        switch self {
        case .Text(let text):
            offer = StoredTextOffer.inManagedObjectContext(managedObjectContext)
            if let offer = offer as? StoredTextOffer {
                offer.text = text
            }
        }
        if let offer = offer {
            offer.received = NSDate()
        }
        return offer
    }
}