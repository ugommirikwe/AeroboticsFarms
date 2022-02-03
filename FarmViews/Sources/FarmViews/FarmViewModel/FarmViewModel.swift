import Foundation
import Combine
import CoreLocation
import MapKit
import DomainModel
import DataRepository
import ApplicationError
import NetworkMonitorUtil

public class FarmViewModel: ObservableObject, FarmViewModelProtocol {
    private let dataRepository: DataRepositoryProtocol
    private let networkMonitorUtil: NetworkMonitorUtil
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published public private(set) var farmsList = [DomainModel.Farm]()
    @Published public private(set) var orchardsList = [DomainModel.Orchard]()
    @Published public private(set) var isFetching = false
    @Published public private(set) var appError: String = ""
    @Published public var hasError: Bool = false
    @Published public var shouldShowNetworkStatusView: Bool = false {
        didSet {
            print("changed to \(shouldShowNetworkStatusView)")
        }
    }
    @Published public private(set) var farmSelected: DomainModel.Farm? = nil
    @Published public private(set) var orchardSelected: DomainModel.Orchard? = nil
    @Published public private(set) var selectedFarmOrchardsPolygonPoints = [MKPolygon]()
    
    public init(dataRepository: DataRepositoryProtocol, networkMonitorUtil: NetworkMonitorUtil = .shared) {
        self.dataRepository = dataRepository
        self.networkMonitorUtil = networkMonitorUtil
        startObserving()
    }
    
    public func sendFarmsFetchQuery() {
        (dataRepository as? DataRepository)?.sendFetchFarmsQuery()
    }
    
    public func fetchFarm(withId id: Int) {
        dataRepository.fetchFarm(withId: id) { [weak self] result in
            switch result {
            case .success(let farm):
                self?.farmSelected = farm
            case .failure(let error):
                self?.appError = (error as? ApplicationError)?.localizedDescription ?? ""
            }
        }
    }
    
    public func onFarmSelected(_ farm: DomainModel.Farm) {
        farmSelected = farm
        (dataRepository as? DataRepository)?.sendFetchOrchardsQuery(farmId: [farm.id])
    }
    
    public func sendOrchardsFetchQuery() {
        (dataRepository as? DataRepository)?.sendFetchOrchardsQuery()
    }
    
    public func fetchOrchard(withId id: Int) {
        dataRepository.fetchOrchard(withId: id) { [weak self] result in
            switch result {
            case .success(let orchard):
                self?.orchardSelected = orchard
            case .failure(let error):
                self?.appError = (error as? ApplicationError)?.localizedDescription ?? ""
            }
        }
    }
    
    private func startObserving() {
        networkMonitorUtil.$hasConnectionStatusChanged
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: &$shouldShowNetworkStatusView)
        
        (dataRepository as? DataRepository)?.$error
            .receive(on: DispatchQueue.main)
            .map { [weak self] error in
                self?.hasError = error != nil
                return error?.localizedDescription ?? ""
            }
            .assign(to: &$appError)
        
        (dataRepository as? DataRepository)?.$isFetching
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFetching)
        
        (dataRepository as? DataRepository)?.$farmsList
            .receive(on: DispatchQueue.main)
            .filter { $0.count > 0 }
            .assign(to: &$farmsList)
        
        (dataRepository as? DataRepository)?.$orchardsList
            .receive(on: DispatchQueue.main)
            .filter { $0.count > 0 }
            .compactMap { [weak self] list in
                self?.orchardsList = list
                return self?.makeMapPolygonsFromOrchards(list)
            }
            .assign(to: &$selectedFarmOrchardsPolygonPoints)
    }
}
