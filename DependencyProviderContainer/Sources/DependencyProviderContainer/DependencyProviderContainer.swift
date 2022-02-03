import RemoteAPIManager
import FarmDataSourceRemote
import FarmDataSourceLocal
import DataRepository
import FarmViews
import KeychainUtil
import SettingsDataRepository
import SettingsView
import NetworkMonitorUtil

public protocol DependencyProviderContainerProtocol: AnyObject {
    var networkMonitorUtil: NetworkMonitorUtil { get }
    var remoteAPIAccessManager: RemoteAPIManagerProtocol { get }
    var farmDataSourceRemote: FarmDataSourceRemoteProtocol { get }
    var farmDataSourceLocal: FarmDataSourceLocalProtocol { get }
    var farmDataRepository: DataRepositoryProtocol { get }
    var farmViewModel: FarmViewModel { get }
    var keychainUtil: KeychainUtil { get }
    var settingsDataRepository: SettingsDataRepository { get }
    var settingsViewModel: SettingsViewModelProtocol { get }
}

final public class DependencyProviderContainer: DependencyProviderContainerProtocol {
    public static let shared = DependencyProviderContainer()
    
    public let networkMonitorUtil: NetworkMonitorUtil
    public let remoteAPIAccessManager: RemoteAPIManagerProtocol
    public let farmDataSourceRemote: FarmDataSourceRemoteProtocol
    public let farmDataSourceLocal: FarmDataSourceLocalProtocol
    public let farmDataRepository: DataRepositoryProtocol
    public let farmViewModel: FarmViewModel
    public let keychainUtil: KeychainUtil
    public let settingsDataRepository: SettingsDataRepository
    public let settingsViewModel: SettingsViewModelProtocol
    
    private init() {
        self.networkMonitorUtil = NetworkMonitorUtil.shared
        self.remoteAPIAccessManager = RemoteAPIManager.shared
        self.farmDataSourceRemote = FarmDataSourceRemote(remoteAPIManager: remoteAPIAccessManager)
        self.farmDataSourceLocal = FarmDataSourceLocalWithCoreData.shared
        self.farmDataRepository = DataRepository(farmDataSourceRemote: farmDataSourceRemote, farmDataSourceLocal: farmDataSourceLocal)
        self.farmViewModel = FarmViewModel(dataRepository: farmDataRepository, networkMonitorUtil: networkMonitorUtil)
        self.keychainUtil = KeychainUtil.standard
        self.settingsDataRepository = SettingsDataRepository(keychainUtil: keychainUtil, userDefaults: .standard)
        self.settingsViewModel = SettingsViewModel(settingsDataRepository: settingsDataRepository)
    }
}
