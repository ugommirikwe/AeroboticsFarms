import Foundation

public enum DataSourceError: ApplicationError {
    case dbAccessError(description: String)
    case noData
    case requestAlreadyInProgress
    case unknown(description: String)
}

extension DataSourceError {
    public var errorDescription: String? {
        switch self {
        case .dbAccessError(let description):
            return NSLocalizedString(description, comment: "")
            
        case .noData:
            return NSLocalizedString("No data was fetched from database", comment: "")
            
        case .requestAlreadyInProgress:
            return NSLocalizedString("A previous request is already being processed...", comment: "")
            
        case .unknown(let description):
            return NSLocalizedString(
                "An unknown error occured: \n \(description)",
                comment: ""
            )
        }
    }
}
