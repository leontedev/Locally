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
    @ObservedObject var locationManager: LocationManager
    @Binding var location: CLLocation?
    @Binding var mapState: MapState

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
        let gRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.triggerTouchAction(gestureReconizer:)))
        mapView.addGestureRecognizer(gRecognizer)
        mapView.delegate = context.coordinator
        myMapView = mapView
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        switch mapState {
        case .currentLocation:
            var shouldRedrawCurrentLocationAnnotation = true
            guard let newLocation = location else { return }
            let firstAnnotation = view.annotations.first
            if firstAnnotation?.title == "Current Location" {
                if let exisitingAnnotationLatitude = firstAnnotation?.coordinate.latitude {
                    if let exisitingAnnotationLongitude = firstAnnotation?.coordinate.longitude {
                        if abs(exisitingAnnotationLatitude - newLocation.coordinate.latitude) < 0.00009 && abs(exisitingAnnotationLongitude - newLocation.coordinate.longitude) < 0.00009 {
                            shouldRedrawCurrentLocationAnnotation = false
                            //print("OUTPUT ignoring redraw: \(abs(exisitingAnnotationLatitude - newLocation.coordinate.latitude)) & \(abs(exisitingAnnotationLongitude - newLocation.coordinate.longitude))")
                        } else {
                            //print("OUTPUT shouldRedrawCurrentLocationAnnotation: \(abs(exisitingAnnotationLatitude - newLocation.coordinate.latitude)) & \(abs(exisitingAnnotationLongitude - newLocation.coordinate.longitude))")
                        }
                    }
                }
            }
            
            if shouldRedrawCurrentLocationAnnotation {
                // remove previous markers (if any)
                let allAnnotations = view.annotations
                view.removeAnnotations(allAnnotations)
                
                // convert CLLocation to CLLocationCoordinate2D
                let coordinate = newLocation.coordinate
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                view.setRegion(region, animated: true)
                
                // Drop a pin at the current location
                let annotation = MKPointAnnotation()
                annotation.coordinate = newLocation.coordinate
                annotation.title = "Current Location"
                
                LocationManager.retrievePostalAddress(from: newLocation) { postalAddress in
                    annotation.subtitle = postalAddress
                }

                view.addAnnotation(annotation)
                view.selectAnnotation(annotation, animated: false)
            }
            
        case .customLocation(let coordinate, let postalAddress):
            // remove previous markers (if any)
            let allAnnotations = view.annotations
            view.removeAnnotations(allAnnotations)

            //Now use this coordinate to add annotation on map.
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Custom Location"
            annotation.subtitle = postalAddress

            view.addAnnotation(annotation)
            //view.selectAnnotation(annotation, animated: false)
            
        case .savedLocation(let location):
            // remove previous markers (if any)
            let allAnnotations = view.annotations
            view.removeAnnotations(allAnnotations)
            
            // convert CLLocation to CLLocationCoordinate2D
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            view.setRegion(region, animated: true)
            
            // Drop a pin at the current location
            let myAnnotation = MKPointAnnotation()
            myAnnotation.coordinate = coordinate
            myAnnotation.title = location.name
            myAnnotation.subtitle = location.address
            
            view.addAnnotation(myAnnotation)
            view.selectAnnotation(myAnnotation, animated: false)
        }
        
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var mapView: MapView

        init(_ mapView: MapView) {
            self.mapView = mapView
        }
        
        func updateMapState(to state: MapState) {
            mapView.mapState = state
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            markerView.markerTintColor = UIColor.init(named: "ButtonColor")
            markerView.isDraggable = true
            markerView.isSelected = true

            return markerView
        }

        @objc func triggerTouchAction(gestureReconizer: UITapGestureRecognizer) {
            guard let myMapView = myMapView else { return }
            let point = gestureReconizer.location(in: myMapView)
            let coordinate = myMapView.convert(point, toCoordinateFrom: myMapView)
            
            // Update Location Manager
            mapView.locationManager.lastKnownCustomLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            mapView.locationManager.lastKnownCustomDescription = ""
            
            self.updateMapState(to: .customLocation(coordinate, nil))
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            LocationManager.retrievePostalAddress(from: location) { postalAddress in
                self.mapView.locationManager.lastKnownCustomDescription = postalAddress
                self.updateMapState(to: .customLocation(coordinate, postalAddress))
            }
        }

        // Recreate the annotation when the Marker is dragged to a new location
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            if newState == .ending {
                //removeCustomLocationAnnotation()
                guard let coordinate = view.annotation?.coordinate else { return }
                view.setDragState(.none, animated: true)

                // Update Location Manager
                self.mapView.locationManager.lastKnownCustomLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.mapView.locationManager.lastKnownCustomDescription = ""
                
                self.updateMapState(to: .customLocation(coordinate, nil))
                
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                LocationManager.retrievePostalAddress(from: location) { postalAddress in
                    self.mapView.locationManager.lastKnownCustomDescription = postalAddress
                    self.updateMapState(to: .customLocation(coordinate, postalAddress))
                }
            } else if (newState == .canceling) {
                view.setDragState(.none, animated: true)
            }
        }
    }
    
}


//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView(locationManager: LocationManager(), location: )
//    }
//}
