import Security
import Foundation

public class KeychainUtil {
    public static let standard = KeychainUtil()
    
    public enum Error: LocalizedError {
        case saveError(String)
        
        var errorDescription: String {
            switch self {
            case .saveError(let details):
                return details
            }
        }
    }
    
    private init() {}
    
    public func save<T: Codable>(_ data: T, service: String, account: String) throws {
        do {
            let _data = try JSONEncoder().encode(data)
            
            let query = [
                kSecValueData: _data,
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
            ] as CFDictionary
            
            let status = SecItemAdd(query, nil)
            
            if status != errSecSuccess {
                if status == errSecDuplicateItem {
                    let updateQuery = [
                        kSecAttrService: service,
                        kSecAttrAccount: account,
                        kSecClass: kSecClassGenericPassword,
                    ] as CFDictionary
                    
                    let attributesToUpdate = [kSecValueData: _data] as CFDictionary
                    SecItemUpdate(updateQuery, attributesToUpdate)
                    
                    return
                }
                
                throw KeychainUtil.Error.saveError("Error saving \(service) to KeyChain:\n\(String(describing: status))")
            }
        } catch {
            throw error
        }
    }
    
    public func read<T: Codable>(service: String, account: String, type: T.Type) throws -> T? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let result = result as? Data else {
            return nil
        }

        do {
            let data = try JSONDecoder().decode(type, from: result)
            return data
        } catch {
            throw error
        }
    }
    
    public func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
