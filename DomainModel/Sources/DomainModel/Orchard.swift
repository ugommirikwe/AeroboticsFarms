import Foundation

public extension DomainModel {
    struct Orchard {
        public let id: Int
        public let hectares: Double
        public let name: String
        public let farmId: Int
        public let clientId: Int
        public let polygon: String
        public let cropType: String
        
        public init(
            id: Int,
            hectares: Double,
            name: String,
            farmId: Int,
            clientId: Int,
            polygon: String,
            cropType: String
        ) {
            self.id = id
            self.hectares = hectares
            self.name = name
            self.farmId = farmId
            self.clientId = clientId
            self.polygon = polygon
            self.cropType = cropType
        }
    }
}
