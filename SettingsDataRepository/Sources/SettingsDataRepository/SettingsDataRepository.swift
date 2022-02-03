import KeychainUtil
import Foundation
import Combine

public class SettingsDataRepository: ObservableObject {
    public typealias Settings = (apiBaseURL: String, apiToken: String)
    
    private let keychainUtil: KeychainUtil
    private let userDefaults: UserDefaults
    
    @Published public private(set) var error: Error? = nil
    
    public init(
        keychainUtil: KeychainUtil = .standard,
        userDefaults: UserDefaults = .standard
    ) {
        self.keychainUtil = keychainUtil
        self.userDefaults = userDefaults
    }
    
    public func saveSettings(_ settings: Settings) -> Error? {
        do {
            let apiBaseURL = settings.apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
            let apiToken = settings.apiToken.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !apiBaseURL.isEmpty,
                  !apiToken.isEmpty else {
                      throw NSError()
                  }
            try keychainUtil.save(
                settings.apiToken,
                service: "api-access-token",
                account: apiBaseURL
            )
            
            userDefaults.set(apiBaseURL, forKey: "api-base-url")
            return nil
        } catch {
            self.error = error
            return error
        }
    }
    
    public func fetchSettings() -> Settings? {
        guard let apiBaseURL = userDefaults.string(forKey: "api-base-url") else {
            return nil
        }
        
        do {
            guard let apiToken = try keychainUtil.read(service: "api-access-token", account: apiBaseURL, type: String.self) else {
                return nil
            }
            
            return (apiBaseURL: apiBaseURL, apiToken: apiToken)
        } catch {
            self.error = error
            return nil
        }
    }
    
    public func removeSettings() {
        guard let apiBaseURL = userDefaults.string(forKey: "api-base-url") else {
            return
        }
        
        userDefaults.removeObject(forKey: "api-base-url")
        
        keychainUtil.delete(service: "api-access-token", account: apiBaseURL)
    }
}
