import Combine
import SettingsDataRepository
import UIKit

public protocol SettingsViewModelProtocol {
    var isProcessing: Bool { get }
    var errorMessage: String { get }
    var baseURLFieldValue: String { get }
    var apiTokenFieldValue: String { get }
    var isSettingsValid: Bool { get }
    func clearBaseURLFieldValue()
    func clearApiTokenFieldValue()
    func onSubmitSettings() -> Bool
}

public final class SettingsViewModel: ObservableObject, SettingsViewModelProtocol {
    @Published public var isProcessing: Bool = false
    @Published public var errorMessage: String = ""
    @Published public var baseURLFieldValue: String = ""
    @Published public var apiTokenFieldValue: String = ""
    @Published public var isSettingsValid = false
    
    private let settingsDataRepository: SettingsDataRepository
    
    private static let defaultBaseURL = "https://sherlock.aerobotics.com/developers/"
    
    public init(settingsDataRepository: SettingsDataRepository) {
        self.settingsDataRepository = settingsDataRepository
        isProcessing = true
        startObserving()
        
        if let settings = self.settingsDataRepository.fetchSettings() {
            baseURLFieldValue = settings.apiBaseURL
            apiTokenFieldValue = settings.apiToken
        } else {
            baseURLFieldValue = Self.defaultBaseURL
        }
        
        isProcessing = false
    }
    
    public func clearBaseURLFieldValue() {
        baseURLFieldValue = ""
    }
    
    public func clearApiTokenFieldValue() {
        apiTokenFieldValue = ""
    }
    
    public func onSubmitSettings() -> Bool {
        isProcessing = true
        defer {
            isProcessing = false
        }
        
        guard let error = settingsDataRepository.saveSettings((
            apiBaseURL: baseURLFieldValue,
            apiToken: apiTokenFieldValue
        )) else {
            return true
        }
        
        self.errorMessage = error.localizedDescription
        return false
    }
    
    private func startObserving() {
        settingsDataRepository.$error
            .compactMap { error in
                if let error = error {
                    return error.localizedDescription
                }
                return ""
            }
            .assign(to: &$errorMessage)
        
        $baseURLFieldValue.combineLatest($apiTokenFieldValue)
            .compactMap { [weak self] baseURL, apiToken in
                if baseURL.isEmpty || apiToken.isEmpty {
                    return false
                }
                
                return self?.isURLValid()
            }
            .assign(to: &$isSettingsValid)
    }
    
    private func isURLValid() -> Bool {
        isProcessing = true
        defer {
            isProcessing = false
        }
        
        let types: NSTextCheckingResult.CheckingType = [.link]
        guard let detector = try? NSDataDetector(types: types.rawValue),
              !baseURLFieldValue.isEmpty else {
                  return false
              }
        
        if detector.numberOfMatches(
            in: baseURLFieldValue,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, baseURLFieldValue.count)
        ) > 0 {
            return true
        }
        
        return false
    }
}

final class SettingsViewModelMock: ObservableObject, SettingsViewModelProtocol {
    @Published var isProcessing: Bool = false
    @Published public var errorMessage: String = ""
    @Published var baseURLFieldValue: String = ""
    @Published var apiTokenFieldValue: String = ""
    @Published var isSettingsValid: Bool = false
    
    func clearBaseURLFieldValue() {
        baseURLFieldValue = ""
    }
    
    func clearApiTokenFieldValue() {
        apiTokenFieldValue = ""
    }
    
    func onSubmitSettings() -> Bool {
        false
    }
}
