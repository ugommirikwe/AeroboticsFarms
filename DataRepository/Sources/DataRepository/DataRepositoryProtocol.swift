import FarmDataSourceLocal
import FarmDataSourceRemote
import DomainModel
import ApplicationError
import NetworkMonitorUtil

public protocol DataRepositoryProtocol {
    var farmsList: [DomainModel.Farm] { get }
    var orchardsList: [DomainModel.Orchard] { get }
    var error: ApplicationError? { get }
    var isFetching: Bool { get }
    
    init(
        farmDataSourceRemote: FarmDataSourceRemoteProtocol,
        farmDataSourceLocal: FarmDataSourceLocalProtocol,
        networkMonitorUtil: NetworkMonitorUtil
    )
    
    func sendFetchFarmsQuery(
        id: [Int],
        clientId: [Int],
        limit: Int?,
        offset: Int?
    )
    
    func fetchFarm(
        withId id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Farm?, Error>) -> Void
    )
    
    func sendFetchOrchardsQuery(
        id: [Int],
        clientId: [Int],
        farmId: [Int],
        limit: Int?,
        offset: Int?
    )
    
    func fetchOrchard(
        withId id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Orchard?, Error>) -> Void
    )
}
