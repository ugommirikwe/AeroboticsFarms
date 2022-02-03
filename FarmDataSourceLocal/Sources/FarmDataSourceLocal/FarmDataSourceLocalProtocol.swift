import Foundation
import DomainModel
import ApplicationError

public protocol FarmDataSourceLocalProtocol {
    func getFarm(
        id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Farm?, DataSourceError>) -> Void
    )
    
    func getFarms(
        ids: [Int],
        clientIds: [Int],
        limit: Int?,
        offset: Int?,
        _ completionHandler: @escaping (Result<[DomainModel.Farm], DataSourceError>) -> Void
    )
    
    func saveOrUpdateFarms(
        _ farms: [DomainModel.Farm],
        _ completionHandler: @escaping (Result<Void, DataSourceError>) -> Void
    )
    
    func getOrchard(
        id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Orchard?, DataSourceError>) -> Void
    )
    
    func getOrchards(
        ids: [Int],
        clientIds: [Int],
        farmIds: [Int],
        limit: Int?,
        offset: Int?,
        _ completionHandler: @escaping (Result<[DomainModel.Orchard], DataSourceError>) -> Void
    )
    
    func saveOrUpdateOrchards(
        _ orchards: [DomainModel.Orchard],
        _ completionHandler: @escaping (Result<Void, DataSourceError>) -> Void
    )
}
