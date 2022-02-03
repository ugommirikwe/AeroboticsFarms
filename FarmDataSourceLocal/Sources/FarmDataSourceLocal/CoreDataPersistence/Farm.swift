import Foundation
import CoreData

@objc(Farm)
class Farm: NSManagedObject {
    @nonobjc public class func farmFetchRequest() -> NSFetchRequest<Farm> {
        NSFetchRequest(entityName: "Farm")
    }
    
    @NSManaged public var id: Int
    @NSManaged public var name: String
    @NSManaged public var clientId: Int
}
