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
                case "string":
                    if let string = json["string"] as? String {
                        let offer = ClipsieTextOffer.inManagedObjectContext(managedObjectContext) as ClipsieTextOffer
                        offer.string = string
                        return offer
                    }
                case "url":
                    if let url = json["url"] as? String {
                        let offer = ClipsieURLOffer.inManagedObjectContext(managedObjectContext) as ClipsieURLOffer
                        offer.url = url
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
    @NSManaged var string: NSString?
    override var preview: String { get { return string != nil ? string! : "" } }
    override var data: NSData { get { return NSJSONSerialization.dataWithJSONObject(
        [
            "type": "string",
            "string": string != nil ? string! : ""
        ], options: NSJSONWritingOptions(0), error: nil
    )! } }
    override class var entityName: String { get { return "TextOffer" } }
}

class ClipsieURLOffer: ClipsieOffer {
    @NSManaged var url: NSString?
    override var preview: String { get { return url != nil ? url! : "" } }
    override var data: NSData { get { return NSJSONSerialization.dataWithJSONObject(
        [
            "type": "url",
            "url": url != nil ? url! : ""
        ], options: NSJSONWritingOptions(0), error: nil
        )! } }
    override class var entityName: String { get { return "URLOffer" } }
}