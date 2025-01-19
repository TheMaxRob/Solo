//
//  ClusterMapViewRepresentable.swift
//  SoloTravel
//
//  Created by Max Roberts on 1/15/25.
//

import SwiftUI
import MapKit

struct ClusterMapViewRepresentable: UIViewRepresentable {
    let meetups: [Meetup]
    @Binding var region: MKCoordinateRegion
    @Binding var selectedMeetup: Meetup?
    @Binding var tappedLocation: CLLocationCoordinate2D?
    var onClusterTap: (MKClusterAnnotation) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // 1) Register annotation views for normal pins and clusters
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: NSStringFromClass(MKMarkerAnnotationView.self)
        )
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: NSStringFromClass(MKClusterAnnotation.self)
        )
        
        // gesture recognizer to detect taps on empty space
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        // Initial region
        mapView.setRegion(region, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // If region changed, update the map
        context.coordinator.parent = self
        uiView.setRegion(region, animated: true)
        
        // Remove old annotations
        uiView.removeAnnotations(uiView.annotations)
        
        // Add new ones from our meetups array
        let annotations = meetups.map { meetup -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = meetup.location
            annotation.title = meetup.title
            return annotation
        }
        uiView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusterMapViewRepresentable
        
        init(parent: ClusterMapViewRepresentable) {
            self.parent = parent
        }
        
        // MARK: - Tap on annotation
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            
            if let cluster = annotation as? MKClusterAnnotation {
                // 1) A cluster was tapped
                print("cluster tap")
                parent.onClusterTap(cluster)
            }
            else if let pin = annotation as? MKPointAnnotation {
                print("individual annotation tapped")
                // 2) A single pin was tapped
                //    We need to figure out which meetup that was (based on its title/coordinate)
                print("parent.meetups: \(parent.meetups)")
                if let meetup = parent.meetups.first(where: {
                    $0.title == pin.title 
                }) {
                    print("meetup found")
                    // Found the matching Meetup
                    parent.selectedMeetup = meetup
                }
            }
        }
        
        // MARK: - View for annotation (normal vs cluster)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Ignore user location
            if annotation is MKUserLocation {
                return nil
            }
            
            // If it's a cluster
            if let cluster = annotation as? MKClusterAnnotation {
                let identifier = NSStringFromClass(MKClusterAnnotation.self)
                let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: cluster) as? MKMarkerAnnotationView
                // Customize cluster color, glyph, etc.
                clusterView?.markerTintColor = .systemOrange
                clusterView?.glyphText = "\(cluster.memberAnnotations.count)"
                return clusterView
            }
            
            // Else, it's a normal annotation
            let identifier = NSStringFromClass(MKMarkerAnnotationView.self)
            let markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as? MKMarkerAnnotationView
            markerView?.canShowCallout = false
            markerView?.markerTintColor = .systemBlue
            return markerView
        }
        
        // MARK: - Tap on empty space
        @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            
            // 1) Check if tapped on an existing annotation view
            //    If so, let didSelect handle it.  If you rely on `didSelect` alone,
            //    you can skip this check and rely on the "annotation tapped" path.
            //    But it's common to do a quick hitTest:
            let tappedView = mapView.hitTest(point, with: nil)
            // If tappedView is an annotation view (or cluster), do nothing here
            if tappedView is MKAnnotationView {
                return
            }
            
            // 2) Convert point to coordinate
            let coord = mapView.convert(point, toCoordinateFrom: mapView)
            
            // 3) This is a tap on empty space
            parent.tappedLocation = coord
        }
    }
}
