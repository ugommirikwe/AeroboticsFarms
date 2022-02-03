import Foundation
import ApplicationError
import SettingsDataRepository

public enum EndPoint {
    case getFarm(id: Int)
    case getFarms(
        id: [Int]? = nil,
        clientId: [Int]? = nil,
        limit: Int? = 10,
        offset: Int? = 0
    )
    
    case getOrchard(id: Int)
    case getOrchards(
        id: [Int]? = nil,
        clientId: [Int]? = nil,
        farmId: [Int]? = nil,
        limit: Int? = 10,
        offset: Int? = 0
    )
}

protocol URLRequestProvidable {
    var urlRequest: URLRequest { get }
}

extension EndPoint: URLRequestProvidable {
    var settingsDataRepository: SettingsDataRepository {
        SettingsDataRepository()
    }
    
    public var urlRequest: URLRequest {
        guard let appSettings = settingsDataRepository.fetchSettings() else {
            // TODO: Add this error to the RemoteAPIAccessError enum
            fatalError("Unable to retrieve app settings.")
        }
        
        guard var urlComponents = URLComponents(string: appSettings.apiBaseURL) else {
            fatalError(RemoteAPIAccessError.invalidAPIBaseURL(url: appSettings.apiBaseURL).localizedDescription)
        }
        
        var request: URLRequest
        
        switch self {
        case .getFarm(let id):
            urlComponents.path = "farms/\(id)/"
            
        case .getFarms(let id, let clientId, let limit, let offset):
            urlComponents = buildURLComponentsForGetFarmsEndPoint(urlComponents, id, clientId, limit, offset)
            
        case .getOrchard(let id):
            urlComponents.path = "orchards/\(id)"
            
        case .getOrchards(let id, let clientId, let farmId, let limit, let offset):
            urlComponents = buildURLComponentsForGetOrchardsEndPoint(
                urlComponents,
                id,
                clientId,
                farmId,
                limit,
                offset
            )
        }
        
        guard let url = urlComponents.url else {
            fatalError(RemoteAPIAccessError.invalidAPIBaseURL(url: String(describing: urlComponents)).localizedDescription)
        }
        
        request = URLRequest(url: url)
        request.addValue(appSettings.apiToken, forHTTPHeaderField: "Authorization")
        return request
    }
    
    fileprivate func buildURLComponentsForGetFarmsEndPoint(
        _ urlComponents: URLComponents,
        _ id: [Int]?,
        _ clientId: [Int]?,
        _ limit: Int?,
        _ offset: Int?
    ) -> URLComponents {
        var _urlComponents = urlComponents
        
        _urlComponents.path += "farms/"
        
        var queryItems: [URLQueryItem] = []
        
        if let id = id, !id.isEmpty {
            let ids = id.map { String($0) }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: ids.count > 1 ? "id__in" : "id", value: ids))
        }
        
        if let clientId = clientId, !clientId.isEmpty {
            let clientIds = clientId.map { String($0) }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: clientIds.count > 1 ? "client_id__in" : "id", value: clientIds))
        }
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        if let offset = offset {
            queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        
        if !queryItems.isEmpty {
            _urlComponents.queryItems = queryItems
        }
        
        return _urlComponents
    }
    
    fileprivate func buildURLComponentsForGetOrchardsEndPoint(
        _ urlComponents: URLComponents,
        _ id: [Int]?,
        _ clientId: [Int]?,
        _ farmId: [Int]?,
        _ limit: Int?,
        _ offset: Int?
    ) -> URLComponents {
        var _urlComponents = urlComponents
        
        _urlComponents.path += "orchards/"
        
        var queryItems: [URLQueryItem] = []
        
        if let id = id, !id.isEmpty {
            let ids = id.map { String($0) }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: ids.count > 1 ? "id__in" : "id", value: ids))
        }
        
        if let clientId = clientId, !clientId.isEmpty {
            let clientIds = clientId.map { String($0) }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: clientIds.count > 1 ? "client_id__in" : "id", value: clientIds))
        }
        
        if let farmId = farmId, !farmId.isEmpty {
            let farmIds = farmId.map { String($0) }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: farmIds.count > 1 ? "farm_id__in" : "id", value: farmIds))
        }
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        if let offset = offset {
            queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        
        if !queryItems.isEmpty {
            _urlComponents.queryItems = queryItems
        }
        
        return _urlComponents
    }
}
