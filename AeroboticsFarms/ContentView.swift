import SwiftUI
import CoreData
import Combine
import DependencyProviderContainer
import FarmViews
import SettingsView
import NetworkMonitorUtilView

struct ContentView: View {
    let dependencyContainer: DependencyProviderContainerProtocol
    
    @State private var showSettingsSheet: Bool = false
    @State private var showNetworkStateView = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                farmsListView
                NetworkMonitorStateView(showView: $showNetworkStateView)
                    .transition(NetworkMonitorStateView.slideInOut)
            }
            .animation(.spring(), value: showNetworkStateView)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(viewModel: dependencyContainer.settingsViewModel)
        }
        .navigationViewStyle(.stack)
        .navigationBarTitleTextColor(.accentColor)
        .onAppear {
            guard hasFetchedSettings() else {
                showSettingsSheet = true
                return
            }
        }
        .onReceive(dependencyContainer.networkMonitorUtil.$hasConnectionStatusChanged) { newValue in
            showNetworkStateView = newValue
        }
    }
    
    @ViewBuilder var farmsListView: some View {
        if !showSettingsSheet, hasFetchedSettings() {
            FarmsListView(
                farmsViewModel: dependencyContainer.farmViewModel,
                hasFetchedSettings: true
            )
                .navigationTitle("Farms")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettingsSheet = true
                        }) {
                            HStack {
                                Text("Settings")
                                Image(systemName: "gearshape.fill")
                            }
                        }
                    }
                }
        }
    }
    
    private func hasFetchedSettings() -> Bool {
        if let settings = dependencyContainer.settingsDataRepository.fetchSettings(),
           !settings.apiBaseURL.isEmpty,
           !settings.apiToken.isEmpty {
            return true
        }
        
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dependencyContainer: DependencyProviderContainer.shared)
    }
}
