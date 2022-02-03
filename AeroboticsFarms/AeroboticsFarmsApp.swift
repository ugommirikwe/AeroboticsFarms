import SwiftUI
import DependencyProviderContainer
import FarmViews

@main
struct AeroboticsFarmsApp: App {
    private let dependencyProvider: DependencyProviderContainerProtocol
    
    init() {
        dependencyProvider = DependencyProviderContainer.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView(dependencyContainer: dependencyProvider)
        }
    }
}
