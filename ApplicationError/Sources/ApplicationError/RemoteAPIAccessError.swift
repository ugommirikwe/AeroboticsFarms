import Foundation

public enum RemoteAPIAccessError: ApplicationError {
    case invalidAPIBaseURL(url: String)
    case unauthorizedAccess
    case notFound
    case invalidMimeType
    case generalServerError(description: String)
    case noData
    case noNetworkConnection
}

extension RemoteAPIAccessError {
    public var errorDescription: String? {
        switch self {
        case .invalidAPIBaseURL(let url):
            return NSLocalizedString(
                "Invalid API base URL: \(url)",
                comment: ""
            )
            
        case .unauthorizedAccess:
            return NSLocalizedString(
                "Invalid authorization token",
                comment: ""
            )
            
        case .notFound:
            return NSLocalizedString(
                "404 Not found",
                comment: ""
            )
            
        case .invalidMimeType:
            return NSLocalizedString(
                "Data received isn't 'application/json'",
                comment: ""
            )
            
        case .generalServerError(let description):
            return NSLocalizedString(
                "An error occurred fetching data from the remote server: \(description)",
                comment: ""
            )
            
        case .noData:
            return NSLocalizedString(
                "No error was received but we also don't have data.",
                comment: ""
            )
            
        case .noNetworkConnection:
            return NSLocalizedString(
                "Your device does not seem to have Internet connection at the moment",
                comment: ""
            )
        }
    }
}
