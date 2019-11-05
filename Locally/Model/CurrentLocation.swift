//
//  CurrentLocation.swift
//  Locally
//
//  Created by Mihai Leonte on 11/1/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation
import CoreLocation

class CurrentLocation {
    var latitude: Double
    var longitude: Double
    var date: Date
    var dateString: String
    var description: String
    
    init(_ location: CLLocationCoordinate2D, date: Date, descriptionString: String ) {
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.date = date
        self.dateString = CurrentLocation.dateFormatter.string(from: date)
        self.description = descriptionString
        
        let newLocationSaved = Notification.Name("newLocationSaved")
        
        NotificationCenter.default
            .publisher(for: newLocationSaved, object: nil)
        
        NotificationCenter.default
            .post(name: newLocationSaved, object: nil, userInfo: ["location": self])
    }
    
    static let dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .medium
      return formatter
    }()
}
