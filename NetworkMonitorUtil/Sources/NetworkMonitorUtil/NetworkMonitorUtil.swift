import Combine
import Network

public class NetworkMonitorUtil: ObservableObject {
    public static let shared = NetworkMonitorUtil()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private let currentConnectionStatus: NWPath.Status = .satisfied
    
    @Published public private(set) var hasConnectionStatusChanged = false
    @Published public private(set) var isConnected = true
    @Published public private(set) var isExpensiveConnection = false
    @Published public private(set) var isConstrainedConnection = false
    @Published public private(set) var connectionType = NWInterface.InterfaceType.other
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.hasConnectionStatusChanged = self.currentConnectionStatus != path.status
                self.isConnected = path.status == .satisfied
                self.isExpensiveConnection = path.isExpensive
                self.isConstrainedConnection = path.isConstrained
                let connectionTypes: [NWInterface.InterfaceType] = [.cellular, .wifi, .wiredEthernet]
                self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
            }
        }
        
        monitor.start(queue: queue)
    }
    
    public func cancel() {
        monitor.cancel()
    }
    
    deinit {
        cancel()
    }
}
