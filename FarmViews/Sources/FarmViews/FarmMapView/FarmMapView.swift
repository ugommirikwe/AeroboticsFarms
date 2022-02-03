import SwiftUI
import MapKit
import Combine
import DomainModel
import NetworkMonitorUtilView

public struct FarmMapView: View {
    @ObservedObject private var viewModel: FarmViewModel
    private let farmSelected: DomainModel.Farm
    
    public init(farmSelected: DomainModel.Farm, viewModel: FarmViewModelProtocol) {
        self.viewModel = viewModel as! FarmViewModel
        self.farmSelected = farmSelected
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                mapView
                NetworkMonitorStateView(showView: $viewModel.shouldShowNetworkStatusView)
                    .transition(NetworkMonitorStateView.slideInOut)
            }
            
            VStack(spacing: 20) {
                
                orchardsListView
                buttonToggleOrchardsListView
                mapTypePicker
            }
            .padding()
            .padding(.bottom, 20)
            .animation(.spring(), value: showOrchardsList)
            .alert(viewModel.appError, isPresented: $viewModel.hasError) {
                Button("OK", role: .cancel) {}
            }
            
        }
        .navigationTitle(viewModel.farmSelected?.name ?? "")
    }
    
    // MARK: - Private Properties
    
    private typealias PickerValue = (mapType: MKMapType, description: String)
    
    @State private var centerCoordinate: CLLocationCoordinate2D = .defaultCoordinate
    @State private var action: MapViewComponent.Action = .idle
    
    @State private var mapPickerSelection: Int = 1
    private let pickerValues: [PickerValue] = [
        (mapType: .standard, description: "Standard"),
        (mapType: .hybrid, description: "Hybrid"),
        (mapType: .satellite, description: "Satellite"),
    ]
    private var mapTypeSelectionBinding: Binding<Int> {
        .init { mapPickerSelection }
        set: { newValue in
            action = .changeType(mapType: pickerValues[newValue].mapType)
            mapPickerSelection = newValue
        }
    }
    
    @Namespace private var nspace
    private let matchedGeometryEffectId = "geoeffect1"
    
    @State private var showOrchardsList: Bool = true
    @State private var selectedOrchard: DomainModel.Orchard? = nil
    
    private var mapView: some View {
        MapViewComponent(
            orchardsOverlays: viewModel.selectedFarmOrchardsPolygonPoints,
            centerCoordinate: $centerCoordinate,
            mapTypeSelected: pickerValues[mapPickerSelection].mapType,
            action: $action
        )
            .edgesIgnoringSafeArea(.all)
            .onReceive(viewModel.$selectedFarmOrchardsPolygonPoints) { newValue in
                action = .updateOverlayPolygons(polygons: newValue)
            }
            .onAppear {
                viewModel.onFarmSelected(farmSelected)
            }
    }
    
    @ViewBuilder private var orchardsListView: some View {
        if showOrchardsList {
            OrchardsListView(
                viewModel: viewModel,
                isVisible: $showOrchardsList,
                selectedOrchard: $selectedOrchard
            )
                .matchedGeometryEffect(id: matchedGeometryEffectId, in: nspace)
                .transition(.scale)
                .onReceive(Just(selectedOrchard)) { newValue in
                    guard let selectedOrchard = newValue else {
                        return
                    }
                    
                    let polygon = viewModel.makeMapPolygonsFromOrchards([selectedOrchard])
                    if let orchardPolygon = polygon.first{
                        action = .polygonSelected(
                            orchardPolygon,
                            metaData: (
                                title: selectedOrchard.name,
                                subtitle: "\(String(format: "%.3f", selectedOrchard.hectares)) hectares"
                            )
                        )
                        
                        self.selectedOrchard = nil
                    }
                }
        }
    }
    
    @ViewBuilder private var buttonToggleOrchardsListView: some View {
        if !showOrchardsList {
            Button(action: {
                showOrchardsList = true
            }) {
                Image(systemName: "list.bullet.below.rectangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .background(.ultraThinMaterial)
                    .matchedGeometryEffect(id: matchedGeometryEffectId, in: nspace)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .foregroundColor(.secondary)
            .shadow(color: .gray, radius: 10, x: 0, y: 5)
            .transition(.scale)
        }
    }
    
    private var mapTypePicker: some View {
        Picker(selection: mapTypeSelectionBinding, label: Text("Map type")) {
            ForEach(pickerValues.indices) { index in
                Text(pickerValues[index].description).tag(index)
                    .foregroundColor(.red)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .segmentedPickerForegroundColors(normal: .white, selected: .secondary)
        .disabled(viewModel.isFetching)
    }
}

// MARK: - Preview

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FarmMapView(
                farmSelected: .init(id: 8919, name: "Ugo's Farm", clientId: 7890),
                viewModel: FarmViewModelMock()
            ).environmentObject(FarmViewModelMock())
        }
    }
}
