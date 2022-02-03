import SwiftUI
import MapKit

struct MapViewComponent: UIViewRepresentable {
    typealias PolygonAnnotationMetadata = (title: String, subtitle: String)
    
    enum Action {
        case idle
        case reset(coordinate: CLLocationCoordinate2D)
        case changeType(mapType: MKMapType)
        case updateOverlayPolygons(polygons: [MKPolygon])
        case polygonSelected(_ this: MKPolygon, metaData: PolygonAnnotationMetadata)
    }

    @State var orchardsOverlays: [MKPolygon] = []
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    var mapTypeSelected: MKMapType
    @Binding var action: Action
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.centerCoordinate = orchardsOverlays.first?.coordinate ?? self.centerCoordinate
        mapView.mapType = mapTypeSelected
        mapView.addOverlays(orchardsOverlays)
        updateOverlay(with: orchardsOverlays, mapView: mapView)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        switch action {
        case .idle:
            break
        
        case .reset(let newCoordinate):
            onResetMapViewCenter(uiView, newCoordinate, context)
        
        case .changeType(let mapType):
            uiView.mapType = mapType
            
        case .updateOverlayPolygons(polygons: let polygons):
            onUpdateOverlayPolygons(uiView, polygons)
            
        case .polygonSelected(let polygon, let metaData):
            onPolygonSelected(polygon, metaData: metaData, mapView: uiView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateOverlay(with polygons: [MKPolygon], mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        
        if polygons.isEmpty {
            return
        }
        
        mapView.addOverlay(MKMultiPolygon(polygons))
    }
    
    private func onResetMapViewCenter(_ uiView: MKMapView, _ newCoordinate: CLLocationCoordinate2D, _ context: MapViewComponent.Context) {
        uiView.delegate = nil
        uiView.centerCoordinate = newCoordinate
        DispatchQueue.main.async {
            self.centerCoordinate = newCoordinate
            self.action = .idle
            uiView.delegate = context.coordinator
        }
    }
    
    private func onUpdateOverlayPolygons(_ mapView: MKMapView, _ polygons: [MKPolygon]) {
        DispatchQueue.main.async {
            self.orchardsOverlays = polygons
            self.action = .idle
        }
        
        updateOverlay(with: polygons, mapView: mapView)
        
        if let firstPolygon = polygons.first?.boundingMapRect {
            let mapRect = mapView.overlays
                .dropFirst()
                .reduce(firstPolygon) { $0.union($1.boundingMapRect) }
            
            centerMapOnSelectedPolygon(mapView, mapRect)
        }
    }
    
    private func onPolygonSelected(
        _ polygon: MKPolygon,
        metaData: PolygonAnnotationMetadata,
        mapView: MKMapView
    ) {
        centerMapOnSelectedPolygon(mapView, polygon.boundingMapRect, withAnimation: true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let polygonAnnotation = MKPointAnnotation()
        polygonAnnotation.coordinate = polygon.coordinate
        polygonAnnotation.title = metaData.title
        polygonAnnotation.subtitle = metaData.subtitle
        mapView.addAnnotation(polygonAnnotation)
        
        DispatchQueue.main.async {
            action = .idle
        }
    }
    
    private func centerMapOnSelectedPolygon(_ mapView: MKMapView, _ mapRect: MKMapRect, withAnimation: Bool = false) {
        let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        mapView.setVisibleMapRect(
            mapRect,
            edgePadding: insets,
            animated: withAnimation
        )
    }
}

extension MapViewComponent {
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewComponent
        
        init(_ parent: MapViewComponent) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            DispatchQueue.main.async {
                self.parent.centerCoordinate = mapView.centerCoordinate
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKMultiPolygon {
                let renderer = MKMultiPolygonRenderer(overlay: polygon)
                let color = UIColor.systemOrange
                renderer.fillColor = color.withAlphaComponent(0.2)
                renderer.strokeColor = color.withAlphaComponent(0.7)
                renderer.lineWidth = 1.0
                return renderer
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else {
                return nil
            }
            
            let identifier = "OrchardAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}
