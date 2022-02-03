
public struct FarmDTO {
    public let id: Int
    public let name: String
    public let clientId: Int
}

extension FarmDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case clientId = "client_id"
    }
}

public struct FarmListQueryResponse {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let results: [FarmDTO]
}

extension FarmListQueryResponse: Decodable {}
