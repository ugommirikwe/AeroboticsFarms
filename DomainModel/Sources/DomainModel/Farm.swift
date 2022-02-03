import Foundation

public extension DomainModel {
    struct Farm {
        public let id: Int
        public let name: String
        public let clientId: Int
        
        public init(id: Int, name: String, clientId: Int) {
            self.id = id
            self.name = name
            self.clientId = clientId
        }
    }
}
