import Foundation
import CoreData

@objc(Orchard)
class Orchard: NSManagedObject {
    @nonobjc public class func orchardFetchRequest() -> NSFetchRequest<Orchard> {
        NSFetchRequest(entityName: "Orchard")
    }
    
    @NSManaged public var id: Int
    @NSManaged public var name: String
    @NSManaged public var hectares: Double
    @NSManaged public var farmId: Int
    @NSManaged public var clientId: Int
    @NSManaged public var polygon: String
    @NSManaged public var cropType: String
}
