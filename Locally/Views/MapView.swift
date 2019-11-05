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
    @Binding var location: CLLocation?
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
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
    }
    
}


//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
