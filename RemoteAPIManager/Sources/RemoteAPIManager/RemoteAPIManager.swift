import Foundation
import RemoteEndPoints
import ApplicationError

public protocol RemoteAPIManagerProtocol {
    func call<T: Decodable>(
        _ endpoint: EndPoint,
        completion: @escaping (Result<T, RemoteAPIAccessError>) -> Void
    )
}

public struct RemoteAPIManager: RemoteAPIManagerProtocol {
    public static let shared = RemoteAPIManager()
    private init() {}
    
    public func call<T: Decodable>(
        _ endpoint: EndPoint,
        completion: @escaping (Result<T, RemoteAPIAccessError>) -> Void
    ) {
        URLSession.shared.dataTask(with: endpoint.urlRequest) { data, response, error in
            do {
                if let error = error {
                    throw error
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw RemoteAPIAccessError.generalServerError(description: "No HTTPResponse returned.")
                }
                
                guard httpResponse.statusCode != 403 else {
                    throw RemoteAPIAccessError.unauthorizedAccess
                }
                
                guard httpResponse.statusCode != 404 else {
                    throw RemoteAPIAccessError.notFound
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw RemoteAPIAccessError.generalServerError(description: "Server response code: \(httpResponse.statusCode)")
                }
                
                // TODO: Check for other response codes and throw more semantic custom errors
                                
                guard let mimeType = httpResponse.mimeType,
                      mimeType == "application/json" else {
                          throw RemoteAPIAccessError.invalidMimeType
                      }
                
                guard let data = data else {
                    throw RemoteAPIAccessError.noData
                }
                
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.generalServerError(description: error.localizedDescription)))
            }
        }.resume()
    }
}
