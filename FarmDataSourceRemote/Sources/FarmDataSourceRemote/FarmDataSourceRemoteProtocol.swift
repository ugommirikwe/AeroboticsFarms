import ApplicationError
import RemoteAPIManager

public protocol FarmDataSourceRemoteProtocol {
    var remoteAPIManager: RemoteAPIManagerProtocol { get }
    
    func getFarms(
        id: [Int]?,
        clientId: [Int]?,
        limit: Int?,
        offset: Int?,
        _ completion: @escaping (Result<FarmListQueryResponse, RemoteAPIAccessError>) -> Void
    )
    
    func getFarm(
        id: Int,
        _ completion: @escaping (Result<FarmDTO?, RemoteAPIAccessError>) -> Void
    )
    
    func getOrchards(
        id: [Int]?,
        clientId: [Int]?,
        farmId: [Int]?,
        limit: Int?,
        offset: Int?,
        _ completion: @escaping (Result<OrchardsListQueryResponse, RemoteAPIAccessError>) -> Void
    )
    
    func getOrchard(
        id: Int,
        _ completion: @escaping (Result<OrchardDTO?, RemoteAPIAccessError>) -> Void
    )
}

