//
//  LocationManager.swift
//  Locally
//
//  Created by Mihai Leonte on 05/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
import Contacts


class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager: CLLocationManager
    private let geoCoder = CLGeocoder()

    @Published var lastKnownLocation: CLLocation?
    @Published var lastKnownDescription: String?

    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
    }

    func startUpdating() {
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
        //print("lastKnownLocation \(lastKnownLocation)")
        
        if let location = lastKnownLocation {
            geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let place = placemarks?.first {
                    let postalAddressFormatter = CNPostalAddressFormatter()
                    postalAddressFormatter.style = .mailingAddress
                    if let postalAddress = place.postalAddress {
                        self.lastKnownDescription = postalAddressFormatter.string(from: postalAddress)
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}
