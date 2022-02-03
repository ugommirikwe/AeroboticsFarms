
public struct OrchardDTO {
    public let id: Int
    public let hectares: Double
    public let name: String
    public let farmId: Int
    public let clientId: Int
    public let polygon: String
    public let cropType: String
}

extension OrchardDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case hectares
        case name
        case farmId = "farm_id"
        case clientId = "client_id"
        case polygon
        case cropType = "crop_type"
    }
}

public struct OrchardsListQueryResponse {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let results: [OrchardDTO]
}

extension OrchardsListQueryResponse: Decodable {}
