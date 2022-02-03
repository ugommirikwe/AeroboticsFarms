import SwiftUI
import MapKit
import NetworkMonitorUtil
import NetworkMonitorUtilView

public struct FarmsListView: View {
    @ObservedObject private var viewModel: FarmViewModel
    
    @State private var mapRegion = MKCoordinateRegion(
        center: .defaultCoordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    public init(farmsViewModel: FarmViewModelProtocol, hasFetchedSettings: Bool) {
        self.viewModel = farmsViewModel as! FarmViewModel
        
        if hasFetchedSettings {
            self.viewModel.sendFarmsFetchQuery()
        }
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $mapRegion)
                .edgesIgnoringSafeArea(.all)
            
            List {
                ForEach(viewModel.farmsList, id: \.id) { farm in
                    NavigationLink(
                        farm.name,
                        destination: FarmMapView(farmSelected: farm, viewModel: viewModel)
                    )
                        .padding(.vertical)
                }
            }
            .listRowBackground(Color.clear)
            .background(.ultraThinMaterial)
            .overlay {
                if viewModel.isFetching {
                    ProgressView("Fetching data, please wait...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                }
            }
            .animation(.default, value: viewModel.farmsList.count)
            .refreshable {
                viewModel.sendFarmsFetchQuery()
            }
            .alert(viewModel.appError, isPresented: $viewModel.hasError) {
                Button("OK", role: .cancel) {}
            }
            
            NetworkMonitorStateView(showView: $viewModel.shouldShowNetworkStatusView)
                .transition(NetworkMonitorStateView.slideInOut)
        }
    }
}

struct FarmsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FarmsListView(farmsViewModel: FarmViewModelMock(), hasFetchedSettings: false)
                .navigationTitle("Farms")
        }
    }
}
