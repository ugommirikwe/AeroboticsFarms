import Foundation
import MapKit
import DomainModel
import ApplicationError

final class FarmViewModelMock: ObservableObject, FarmViewModelProtocol {
    var farmsList: [DomainModel.Farm] {
        [DomainModel.Farm(id: 8919, name: "Dev Farm", clientId: 10479)]
    }
    
    var orchardsList: [DomainModel.Orchard] {
        [
            DomainModel.Orchard(
                id: 216269,
                hectares: 2.2419824367885,
                name: "03 Olinda valencia",
                farmId: 8919,
                clientId: 10479,
                polygon: "18.825688993836707,-32.32741477565738 18.82707301368839,-32.32771395090236 18.82696840753681,-32.32805392157161 18.826920127774542,-32.32810831676022 18.82668945779926,-32.328899309768175 18.82535103550083,-32.32913728625483 18.825165963078803,-32.32913048693532 18.825688993836707,-32.32741477565738",
                cropType: "Orange"
            ),
            DomainModel.Orchard(
                id: 216269,
                hectares: 2.2419824367885,
                name: "04 Olinda valencia",
                farmId: 8919,
                clientId: 10479,
                polygon: "18.925688993836707,-32.32741477565738 18.92707301368839,-32.32771395090236 18.92696840753681,-32.32805392157161 18.926920127774542,-32.32810831676022 18.92668945779926,-32.328899309768175 18.92535103550083,-32.32913728625483 18.925165963078803,-32.32913048693532 18.925688993836707,-32.32741477565738",
                cropType: "Orange"
            )
        ]
    }
    
    var isFetching: Bool = false
    var appError: String = ""
    var hasError: Bool = false
    var shouldShowNetworkStatusView: Bool = false
    var farmSelected: DomainModel.Farm? = nil
    var orchardSelected: DomainModel.Orchard? = nil
    var selectedFarmOrchardsPolygonPoints: [MKPolygon] {
        makeMapPolygonsFromOrchards(orchardsList)
    }
    
    func onFarmSelected(_ farm: DomainModel.Farm) {
        farmSelected = farm
    }
    
    func sendFarmsFetchQuery() {
        
    }
    
    func fetchFarm(withId id: Int) {
        
    }
    
    func sendOrchardsFetchQuery() {
        
    }
    
    func fetchOrchard(withId id: Int) {
        
    }
}
