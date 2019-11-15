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
var showedCurrentLocationOnce = false

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @Binding var location: CLLocation?
    
    func makeUIView(context: Context) -> MKMapView {
        print("makeUIView")
        let mapView = MKMapView(frame: .zero)
        
//        let gRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.triggerTouchAction(gestureReconizer:)))
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.triggerTouchAction(gestureReconizer:)))
        longPressRecognizer.minimumPressDuration = 0.51
        longPressRecognizer.numberOfTouchesRequired = 1
        
        mapView.addGestureRecognizer(longPressRecognizer)
        mapView.delegate = context.coordinator
        
        myMapView = mapView
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // 1: don't add Current Location marker if Custom Location marker was added
        // 2: only update the Current Location marker once
        if !locationManager.shouldEnableCurrentLocationButton && !showedCurrentLocationOnce {
            
            guard let newLocation = location else { return }
            
            // remove previous markers (if any)
            let allAnnotations = view.annotations
            view.removeAnnotations(allAnnotations)
            
            // convert CLLocation to CLLocationCoordinate2D
            let coordinate = newLocation.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            view.setRegion(region, animated: true)
            
            // Drop a pin at the current location
            let myAnnotation = MKPointAnnotation()
            myAnnotation.coordinate = newLocation.coordinate
            myAnnotation.title = "Current location"
            
            LocationManager.retrievePostalAddress(from: newLocation) { postalAddress in
                myAnnotation.subtitle = postalAddress
            }

            print("Adding current location annotation")
            view.addAnnotation(myAnnotation)
            view.selectAnnotation(myAnnotation, animated: false)
            
            showedCurrentLocationOnce.toggle()
        }

    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(self) //self
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var mapView: MapView

        init(_ mapView: MapView) {
            self.mapView = mapView
        }

        func updateLocationButton(withStatus: Bool) {
            mapView.locationManager.shouldEnableCurrentLocationButton = withStatus
            showedCurrentLocationOnce = false
            print("updateLocationButton with \(withStatus)")
        }
        
        

        @objc func triggerTouchAction(gestureReconizer: UITapGestureRecognizer) {
            if gestureReconizer.state == .began {
                myMapView?.becomeFirstResponder()
                
                updateLocationButton(withStatus: true)

                guard let mapView = myMapView else { return }

                let allAnnotations = mapView.annotations
                mapView.removeAnnotations(allAnnotations)

                let point = gestureReconizer.location(in: mapView)
                let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

                //Now use this coordinate to add annotation on map.
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "Custom Location"

                // Update Location Manager
                self.mapView.locationManager.lastKnownCustomLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.mapView.locationManager.lastKnownCustomDescription = ""

                //Set subtitle with address
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                LocationManager.retrievePostalAddress(from: location) { postalAddress in
                    annotation.subtitle = postalAddress
                    self.mapView.locationManager.lastKnownCustomDescription = postalAddress
                }

                mapView.addAnnotation(annotation)
                mapView.selectAnnotation(annotation, animated: true)
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

            let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            markerView.markerTintColor = UIColor.init(named: "ButtonColor")
            markerView.isDraggable = true

            return markerView
        }

        // Recreate the annotation when the Marker is dragged to a new location
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
                
                // Update Location Manager
                self.mapView.locationManager.lastKnownCustomLocation = CLLocation(latitude: droppedAt.latitude, longitude: droppedAt.longitude)
                self.mapView.locationManager.lastKnownCustomDescription = ""

                //Set subtitle with address
                let location = CLLocation(latitude: droppedAt.latitude, longitude: droppedAt.longitude)
                LocationManager.retrievePostalAddress(from: location) { postalAddress in
                    annotation.subtitle = postalAddress
                    self.mapView.locationManager.lastKnownCustomDescription = postalAddress
                }

                mapView.addAnnotation(annotation)
                mapView.selectAnnotation(annotation, animated: true)

                updateLocationButton(withStatus: true)

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
