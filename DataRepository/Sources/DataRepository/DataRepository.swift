import Combine
import DomainModel
import ApplicationError
import FarmDataSourceRemote
import FarmDataSourceLocal
import NetworkMonitorUtil

public final class DataRepository: ObservableObject, DataRepositoryProtocol {
    @Published public var farmsList = [DomainModel.Farm]()
    @Published public var orchardsList = [DomainModel.Orchard]()
    @Published public var error: ApplicationError? = nil
    @Published public var isFetching: Bool = false
    
    private let farmDataSourceRemote: FarmDataSourceRemoteProtocol
    private let farmDataSourceLocal: FarmDataSourceLocalProtocol
    private let networkMonitorUtil: NetworkMonitorUtil
    
    public init(
        farmDataSourceRemote: FarmDataSourceRemoteProtocol,
        farmDataSourceLocal: FarmDataSourceLocalProtocol,
        networkMonitorUtil: NetworkMonitorUtil = .shared
    ) {
        self.farmDataSourceRemote = farmDataSourceRemote
        self.farmDataSourceLocal = farmDataSourceLocal
        self.networkMonitorUtil = networkMonitorUtil
    }
    
    public func sendFetchFarmsQuery(
        id: [Int] = [],
        clientId: [Int] = [],
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        if isFetching {
            return
        }
        
        isFetching = true
        
        if error != nil {
            error = nil
        }
        
        let _offset = farmsList.count
        fetchFarmsFromLocalDataSource(id, clientId, limit, _offset)
        fetchFarmsFromRemoteAPI(id, clientId, limit, _offset)
    }
    
    public func fetchFarm(
        withId id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Farm?, Error>) -> Void
    ) {
        if isFetching {
            completionHandler(.failure(DataSourceError.requestAlreadyInProgress))
            return
        }
        
        isFetching = true
        
        if let farm = farmsList.first(where: { $0.id == id }) {
            completionHandler(.success(farm))
            isFetching = false
            return
        }
        
        farmDataSourceLocal.getFarm(id: id) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let farm):
                if let farm = farm {
                    completionHandler(.success(farm))
                    self.isFetching = false
                    return
                }
                
            case .failure(let error):
                // TODO: Silently log error to Crashlytics; user needn't know about it.
                print("Error occurred fetching data from local database: \n\(error.localizedDescription)")
            }
        }
        
        fetchFarmFromRemoteAPI(id: id, completionHandler)
    }
    
    public func fetchOrchard(
        withId id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Orchard?, Error>) -> Void
    ) {
        if isFetching {
            completionHandler(.failure(DataSourceError.requestAlreadyInProgress))
            return
        }
        
        isFetching = true
        
        if let orchard = orchardsList.first(where: { $0.id == id }) {
            completionHandler(.success(orchard))
            isFetching = false
            return
        }
        
        farmDataSourceLocal.getOrchard(id: id) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let orchard):
                if let orchard = orchard {
                    completionHandler(.success(orchard))
                    self.isFetching = false
                    return
                }
            case .failure(let error):
                // TODO: Silently log error to Crashlytics; user needn't know about it.
                print("Error occurred fetching data from local database: \n\(error.localizedDescription)")
                
            }
        }
        
        fetchOrchardFromRemotAPI(id: id, completionHandler)
    }
    
    public func sendFetchOrchardsQuery(
        id: [Int] = [],
        clientId: [Int] = [],
        farmId: [Int] = [],
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        if isFetching {
            return
        }
        
        self.isFetching = true
        
        if error != nil {
            error = nil
        }
        
        let _offset = orchardsList.count
        fetchOrchardsFromLocalDataSource(id, clientId, farmId, limit, _offset)
        fetchOrchardsFromRemoteAPI(id, clientId, farmId, limit, _offset)
    }
    
    fileprivate func fetchFarmsFromLocalDataSource(
        _ id: [Int],
        _ clientId: [Int],
        _ limit: Int?,
        _ offset: Int?
    ) {
        farmDataSourceLocal.getFarms(
            ids: id,
            clientIds: clientId,
            limit: limit,
            offset: offset
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let farms):
                self.farmsList = farms
                self.isFetching = false
                
            case .failure(let error):
                // TODO: Silently log error to Crashlytics; user needn't know about it.
                print("Error occurred saving data to local database: \n\(error.localizedDescription)")
            }
        }
    }
    
    fileprivate func fetchFarmsFromRemoteAPI(
        _ id: [Int],
        _ clientId: [Int],
        _ limit: Int?,
        _ offset: Int?
    ) {
        if !networkMonitorUtil.isConnected {
            isFetching = false
            return
        }
        
        self.farmDataSourceRemote.getFarms(
            id: id,
            clientId: clientId,
            limit: limit,
            offset: offset
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let queryResult):
                let farms = queryResult.results.map {
                    DomainModel.Farm(id: $0.id, name: $0.name, clientId: $0.clientId)
                }
                
                self.updateFarmsListCache(with: farms)
                
                self.farmDataSourceLocal.saveOrUpdateFarms(farms) { saveResult in
                    if case let .failure(error) = saveResult {
                        // TODO: Silently log error to Crashlytics; user needn't know about it.
                        print("Error occurred saving data to local database: \n\(error.localizedDescription)")
                    }
                }
            
            case .failure(let error):
                self.error = error as ApplicationError
                if self.isFetching {
                    self.isFetching = false
                }
            }
        }
    }
    
    fileprivate func fetchFarmFromRemoteAPI(
        id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Farm?, Error>) -> Void
    ) {
        if !networkMonitorUtil.isConnected {
            isFetching = false
            return
        }
        
        farmDataSourceRemote.getFarm(id: id) { [weak self] remoteResult in
            guard let self = self else {
                return
            }
            
            defer {
                self.isFetching = false
            }
            
            switch remoteResult {
            case .success(let farmFromRemote):
                if let farmFromRemote = farmFromRemote {
                    let farm = DomainModel.Farm(
                        id: farmFromRemote.id,
                        name: farmFromRemote.name,
                        clientId: farmFromRemote.clientId
                    )
                    
                    self.updateFarmsListCache(with: [farm])
                    
                    self.farmDataSourceLocal.saveOrUpdateFarms([farm]) { result in
                        if case let .failure(error) = result {
                            // TODO: Silently log error to Crashlytics; user needn't know about it.
                            print("Error occurred saving data to local database: \n\(error.localizedDescription)")
                        }
                    }
                }
                
            case .failure(let error as ApplicationError):
                if self.isFetching {
                    completionHandler(.failure(error))
                    self.isFetching.toggle()
                }
            }
        }
    }
    
    fileprivate func fetchOrchardsFromLocalDataSource(
        _ id: [Int],
        _ clientId: [Int],
        _ farmId: [Int],
        _ limit: Int?,
        _ offset: Int?
    ) {
        farmDataSourceLocal.getOrchards(
            ids: id,
            clientIds: clientId,
            farmIds: farmId,
            limit: limit,
            offset: offset
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let orchards):
                self.orchardsList = orchards
                self.isFetching = false
                
            case .failure(let error):
                // TODO: Silently log error to Crashlytics; user needn't know about it.
                print("Error occurred saving data to local database: \n\(error.localizedDescription)")
            }
        }
    }
    
    fileprivate func fetchOrchardsFromRemoteAPI(
        _ id: [Int],
        _ clientId: [Int],
        _ farmId: [Int],
        _ limit: Int?,
        _ offset: Int?
    ) {
        if !networkMonitorUtil.isConnected {
            isFetching = false
            return
        }
        
        self.farmDataSourceRemote.getOrchards(
            id: id,
            clientId: clientId,
            farmId: farmId,
            limit: limit,
            offset: offset
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let queryResult):
                let orchards = queryResult.results.map {
                    DomainModel.Orchard(
                        id: $0.id,
                        hectares: $0.hectares,
                        name: $0.name,
                        farmId: $0.farmId,
                        clientId: $0.clientId,
                        polygon: $0.polygon,
                        cropType: $0.cropType
                    )
                }
                
                self.updateOrchardsListCache(with: orchards)
                
                self.farmDataSourceLocal.saveOrUpdateOrchards(orchards) { saveResult in
                    if case let .failure(error) = saveResult {
                        // TODO: Silently log error to Crashlytics; user needn't know about it.
                        print("Error occurred saving data to local database: \n\(error.localizedDescription)")
                    }
                }
            
            case .failure(let error):
                if self.isFetching {
                    self.error = error as ApplicationError
                    self.isFetching = false
                }
            }
        }
    }
    
    fileprivate func fetchOrchardFromRemotAPI(
        id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Orchard?, Error>) -> Void
    ) {
        if !networkMonitorUtil.isConnected {
            isFetching = false
            return
        }
        farmDataSourceRemote.getOrchard(id: id) { [weak self] result in
            guard let self = self else {
                return
            }
            
            defer {
                self.isFetching = false
            }
            
            switch result {
            case .success(let orchard):
                if let orchard = orchard {
                    let _orchard = DomainModel.Orchard(
                        id: orchard.id,
                        hectares: orchard.hectares,
                        name: orchard.name,
                        farmId: orchard.farmId,
                        clientId: orchard.clientId,
                        polygon: orchard.polygon,
                        cropType: orchard.cropType
                    )
                    
                    self.updateOrchardsListCache(with: [_orchard])
                    
                    self.farmDataSourceLocal.saveOrUpdateOrchards([_orchard]) { _result in
                        if case let .failure(error) = result {
                            // TODO: Silently log error to Crashlytics; user needn't know about it.
                            print("Error occurred saving data to local database: \n\(error.localizedDescription)")
                        }
                    }
                }

            case .failure(let error as ApplicationError):
                if self.isFetching {
                    completionHandler(.failure(error))
                    self.isFetching.toggle()
                }
            }
        }
    }
    
    fileprivate func updateFarmsListCache(with farms: [DomainModel.Farm]) {
        farms.forEach { farm in
            if farmsList.first(where: { $0.id == farm.id }) != nil {
                farmsList = farmsList.map { $0.id == farm.id ? farm : $0 }
            } else {
                farmsList = farmsList.filter({ $0.id != farm.id }) + [farm]
            }
        }
    }
    
    fileprivate func updateOrchardsListCache(with orchards: [DomainModel.Orchard]) {
        orchards.forEach { orchard in
            if orchardsList.first(where: { $0.id == orchard.id }) != nil {
                orchardsList = orchardsList.map { $0.id == orchard.id ? orchard : $0 }
            } else {
                orchardsList = orchardsList.filter({ $0.id != orchard.id }) + [orchard]
            }
        }
    }
}
