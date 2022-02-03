import Foundation
import DomainModel
import ApplicationError
import MapKit

public protocol FarmViewModelProtocol {
    var farmsList: [DomainModel.Farm] { get }
    var orchardsList: [DomainModel.Orchard] { get }
    var orchardsListViewCountTitle: String { get }
    var isFetching: Bool { get }
    var appError: String { get }
    var hasError: Bool { get }
    var shouldShowNetworkStatusView: Bool { get }
    var farmSelected: DomainModel.Farm? { get }
    var orchardSelected: DomainModel.Orchard? { get }
    var selectedFarmOrchardsPolygonPoints: [MKPolygon] { get }
    
    func onFarmSelected(_ farm: DomainModel.Farm)
    func sendFarmsFetchQuery()
    func fetchFarm(withId id: Int)
    func sendOrchardsFetchQuery()
    func fetchOrchard(withId id: Int)
    
    func makeMapPolygonsFromOrchards(_ orchards: [DomainModel.Orchard]) -> [MKPolygon]
}

extension FarmViewModelProtocol {
    
    public var orchardsListViewCountTitle: String {
        if orchardsList.isEmpty {
            return ""
        }
        
        if orchardsList.count == 1 {
            return "1 Orchard"
        }
        
        return "\(orchardsList.count) Orchards"
    }
    
    public func makeMapPolygonsFromOrchards(_ orchards: [DomainModel.Orchard]) -> [MKPolygon] {
        return orchards.compactMap { orchard in
            let coordinates = parseOrchardsCoordinates(orchard.polygon)
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            polygon.title = orchard.name
            polygon.subtitle = orchard.cropType
            return polygon
        }
    }
    
    private func parseOrchardsCoordinates(_ param: String) -> [CLLocationCoordinate2D] {
        // Parse the string into an array of tuples containing the lat/lng values (converted to Double type)
        let stringToTupleArray = param.components(separatedBy: ",")
            .compactMap { $0.components(separatedBy: " ") }
            .reduce(into: [(Double, Double?)]()) { newTupleArray, currentItem in
                // If the parsed entry is a complete pair of values,
                if currentItem.count == 2,
                   let firstValueAsDouble = Double(currentItem[0]),
                   let secondValueAsDouble = Double(currentItem[1]) {
                    newTupleArray.append((firstValueAsDouble, secondValueAsDouble))
                }
                
                // If the current item isn't a pair of values
                if currentItem.count == 1 {
                    if let itemAsDouble = Double(currentItem[0]) {
                        newTupleArray.append((itemAsDouble, nil))
                    }
                }
            }
        
        // Check if there are exactly two tuple items with nil second values.
        // Those are the leading and trailing items in the original polygon string.
        // These leading and trailing values represent longitude and latitude values.
        guard !stringToTupleArray.isEmpty,
              let first = stringToTupleArray.first,
              let last = stringToTupleArray.last,
              first.1 == nil,
              last.1 == nil else {
                  
                  // If there aren't incomplete tuples, then convert and return this
                  // tuple array as an array of proper geocoordinates.
                  return stringToTupleArray.map { CLLocationCoordinate2DMake($0.0, $0.1!) }
              }
        
        // Otherwise pair-up the values of the incomplete tuples into one proper geocoordinate
        // and prepend (maybe it should be appended??) to the rest of the parsed array and return.
        let arrayOfGeoCoordinates = stringToTupleArray
            .filter { $0.1 != nil }
            .map { CLLocationCoordinate2DMake($0.0, $0.1!) } +
        [CLLocationCoordinate2DMake(last.0, first.0)]
        
        return arrayOfGeoCoordinates
    }
    
}
