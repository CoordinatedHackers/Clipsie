import CoreData

class ClipsieOffer: NSManagedObject {
    @NSManaged var received: NSDate
    @NSManaged var senderName: NSString
    var preview: String { get { return received.description } }
    var data: NSData { get { return NSData() } }
    class var entityName: String { get { return "Offer" } }
    
    // I want to return an instance of Self but Swift doesn't support "... as Self" in the body
    // rdar://19244072
    class func inManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ClipsieOffer {
        return NSEntityDescription.insertNewObjectForEntityForName(
            self.entityName, inManagedObjectContext: managedObjectContext
        ) as ClipsieOffer
    }
    
    class func fromData(data: NSData, _ managedObjectContext: NSManagedObjectContext) -> ClipsieOffer? {
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? [String:AnyObject] {
            if let type = json["type"] as? String {
                switch type {
                case "text":
                    if let string = json["text"] as? String {
                        let offer = ClipsieTextOffer.inManagedObjectContext(managedObjectContext) as ClipsieTextOffer
                        offer.text = string
                        return offer
                    }
                default:
                    break
                }
            }
        }
        return nil
    }
}

class ClipsieTextOffer: ClipsieOffer {
    @NSManaged var text: NSString?
    override var preview: String { get { return text != nil ? text! : "" } }
    override var data: NSData { get { return NSJSONSerialization.dataWithJSONObject(
        [
            "type": "text",
            "text": text != nil ? text! : ""
        ], options: NSJSONWritingOptions(0), error: nil
    )! } }
    override class var entityName: String { get { return "TextOffer" } }
}