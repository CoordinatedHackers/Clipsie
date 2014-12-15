import UIKit
import CoreData

extension ClipsieOffer {
    class func offerWithClipboard(managedObjectContext: NSManagedObjectContext) -> ClipsieOffer? {
        let pasteboard = UIPasteboard.generalPasteboard()
        if let url = pasteboard.URL {
            let offer = ClipsieURLOffer.inManagedObjectContext(managedObjectContext) as ClipsieURLOffer
            offer.url = url.absoluteString
            return offer
        } else if let string = pasteboard.string {
            let offer = ClipsieTextOffer.inManagedObjectContext(managedObjectContext) as ClipsieTextOffer
            offer.string = string
            return offer
        }
        return nil
    }
}