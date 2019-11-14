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
    
    // Current GPS Location
    @Published var lastKnownLocation: CLLocation?
    @Published var lastKnownDescription: String?
    
    // When the user pans the map OR long presses to add a "Custom Location" Marker the Current Location button is enabled
    @Published var shouldEnableCurrentLocationButton = false
    
    // (when the above is true) Custom Location selected on the map will be used
    @Published var lastKnownCustomLocation: CLLocation?
    @Published var lastKnownCustomDescription: String?

    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
    }

    func startUpdating() {
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
        print("startUpdating")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
        print("didUpdateLocations \(lastKnownLocation)")
        
        if let location = lastKnownLocation {
            LocationManager.retrievePostalAddress(from: location) { postalAddress in
                self.lastKnownDescription = postalAddress
            }
        }
        
        self.manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}

extension LocationManager {
    static func retrievePostalAddress(from location: CLLocation, completionHandler: @escaping (_ postalAddress: String) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                let postalAddressFormatter = CNPostalAddressFormatter()
                postalAddressFormatter.style = .mailingAddress
                if let postalAddress = place.postalAddress {
                    let stringAddress = postalAddressFormatter.string(from: postalAddress)
                    completionHandler(stringAddress)
                }
            } else {
                completionHandler("")
            }
        }
    }
}
