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
    
    // Binding for region or camera position
    @Binding var region: MKCoordinateRegion
    @Binding var selectedMeetup: Meetup?
    
    @Binding var tappedLocation: CLLocationCoordinate2D?
    var onClusterTap: (MKClusterAnnotation) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // Enable clustering
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: NSStringFromClass(MKMarkerAnnotationView.self)
        )
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: NSStringFromClass(MKClusterAnnotation.self)
        )
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        mapView.setRegion(region, animated: false)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update the region if needed
        uiView.setRegion(region, animated: true)
        
        // Remove old annotations and add new ones
        uiView.removeAnnotations(uiView.annotations)
        
        let annotations = meetups.map { meetup -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = meetup.location
            annotation.title = meetup.title
            return annotation
        }
        
        uiView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: ClusterMapViewRepresentable
        
        init(_ parent: ClusterMapViewRepresentable) {
            self.parent = parent
        }
        
        // Return an annotation view for each annotation, including clusters.
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            
            if let cluster = annotation as? MKClusterAnnotation {
                // 1) A cluster was tapped
                parent.onClusterTap(cluster)
            }
            else if let pin = annotation as? MKPointAnnotation {
                // 2) A single pin was tapped
                //    We need to figure out which meetup that was (based on its title/coordinate)
                if let meetup = parent.meetups.first(where: {
                    $0.title == pin.title && $0.location.latitude == pin.coordinate.latitude && $0.location.longitude == pin.coordinate.longitude
                }) {
                    // Found the matching Meetup
                    parent.selectedMeetup = meetup
                }
            }
        }

        
        
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
                        
                        // Control cluster separation
                        clusterView?.displayPriority = .defaultHigh
                        clusterView?.clusteringIdentifier = "meetup"
                        return clusterView
                    }
                    
                    // Else, it's a normal annotation
                    let identifier = NSStringFromClass(MKMarkerAnnotationView.self)
                    let markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as? MKMarkerAnnotationView
                    markerView?.canShowCallout = false  // We'll handle selection ourselves
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
