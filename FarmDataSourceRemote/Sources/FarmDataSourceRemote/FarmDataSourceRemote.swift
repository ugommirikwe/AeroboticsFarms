import ApplicationError
import RemoteAPIManager

public struct FarmDataSourceRemote: FarmDataSourceRemoteProtocol {
    public let remoteAPIManager: RemoteAPIManagerProtocol
    
    public init(remoteAPIManager: RemoteAPIManagerProtocol) {
        self.remoteAPIManager = remoteAPIManager
    }
    
    public func getFarms(
        id: [Int]? = nil,
        clientId: [Int]? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        _ completion: @escaping (Result<FarmListQueryResponse, RemoteAPIAccessError>) -> Void
    ) {
        remoteAPIManager.call(
            .getFarms(
                id: id,
                clientId: clientId,
                limit: limit,
                offset: offset
            ),
            completion: completion
        )
    }
    
    public func getFarm(
        id: Int,
        _ completion: @escaping (Result<FarmDTO?, RemoteAPIAccessError>) -> Void
    ) {
        remoteAPIManager.call(.getFarm(id: id), completion: completion)
    }
    
    public func getOrchards(
        id: [Int]? = nil,
        clientId: [Int]? = nil,
        farmId: [Int]? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        _ completion: @escaping (Result<OrchardsListQueryResponse, RemoteAPIAccessError>) -> Void
    ) {
        remoteAPIManager.call(
            .getOrchards(
                id: id,
                clientId: clientId,
                farmId: farmId,
                limit: limit,
                offset: offset
            ),
            completion: completion
        )
    }
    
    public func getOrchard(
        id: Int,
        _ completion: @escaping (Result<OrchardDTO?, RemoteAPIAccessError>) -> Void
    ) {
        remoteAPIManager.call(.getOrchard(id: id), completion: completion)
    }
}
