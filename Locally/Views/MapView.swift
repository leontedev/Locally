//
//  MapView.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

var myMapView: MKMapView?

struct MapView: UIViewRepresentable {
    @Binding var location: CLLocation?
    
    
    
    class Coordinator: NSObject, MKMapViewDelegate {
        @objc func triggerTouchAction(gestureReconizer: UITapGestureRecognizer) {
            
            if gestureReconizer.state == .ended {
                guard let mapView = myMapView else { return }
                
                let allAnnotations = mapView.annotations
                mapView.removeAnnotations(allAnnotations)
                
                let point = gestureReconizer.location(in: mapView)
                let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                
                //Now use this coordinate to add annotation on map.
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "Custom Location"
                
                //Set subtitle with address
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                LocationManager.retrievePostalAddress(from: location) { postalAddress in
                    annotation.subtitle = postalAddress
                }
                
                mapView.addAnnotation(annotation)
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

            let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            markerView.markerTintColor = .blue
            markerView.isDraggable = true

            return markerView
        }
        
        // Recreate the annotation when it is dragged
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            if newState == .ending {
                guard let droppedAt = view.annotation?.coordinate else { return }
                view.setDragState(.none, animated: true)
                
                let allAnnotations = mapView.annotations
                mapView.removeAnnotations(allAnnotations)
                
                //Now use this coordinate to add annotation on map.
                let annotation = MKPointAnnotation()
                annotation.coordinate = droppedAt
                annotation.title = "Custom Location"
                
                //Set subtitle with address
                let location = CLLocation(latitude: droppedAt.latitude, longitude: droppedAt.longitude)
                LocationManager.retrievePostalAddress(from: location) { postalAddress in
                    annotation.subtitle = postalAddress
                }
                
                mapView.addAnnotation(annotation)
                mapView.selectAnnotation(annotation, animated: true)
                
            } else if (newState == .canceling) {
                view.setDragState(.none, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        
        //let gRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.triggerTouchAction(gestureReconizer:)))
        let longPressRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.triggerTouchAction(gestureReconizer:)))
        longPressRecognizer.minimumPressDuration = 0.4
        mapView.addGestureRecognizer(longPressRecognizer)
        mapView.delegate = context.coordinator
        
        myMapView = mapView
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        //guard let newLocation = location.lastKnownLocation else { return }
        guard let newLocation = location else { return }
        
        // convert CLLocation to CLLocationCoordinate2D
        let coordinate = newLocation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
        
        // Drop a pin at the current location
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = newLocation.coordinate
        myAnnotation.title = "Current location"
        view.addAnnotation(myAnnotation)
        view.selectAnnotation(myAnnotation, animated: true)
    }
    
}


//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
