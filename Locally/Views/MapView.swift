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

struct MapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        
        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("newLocationSaved"),
            object: nil,
            queue: nil) { notification in
                if let location = notification.userInfo?["location"] as? CurrentLocation {
                    
                    // Zoom in on the current location
                    let coordinate = CLLocationCoordinate2D(latitude: location.latitude,
                                                            longitude: location.longitude)
                    let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    view.setRegion(region, animated: true)
                    
                    // Drop a pin at the current location
                    let myAnnotation = MKPointAnnotation()
                    myAnnotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                    myAnnotation.title = "Current location"
                    view.addAnnotation(myAnnotation)
                }
        }
    }
    
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
