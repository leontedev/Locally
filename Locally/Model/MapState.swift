//
//  MapState.swift
//  Locally
//
//  Created by Mihai Leonte on 06/12/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import CoreLocation

enum MapState {
    case currentLocation
    case customLocation(CLLocationCoordinate2D, String?)
    case savedLocation(Location)
}

extension MapState: Equatable {
    
    public static func ==(lhs: MapState, rhs: MapState) -> Bool {
        
        switch lhs {
            
        case .currentLocation:
            switch rhs {
            case .currentLocation:
                return true
            case .customLocation:
                return false
            case .savedLocation:
                return false
            }
            
        case .customLocation(let leftCoordinate, let leftDescription):
            switch rhs {
            case .currentLocation:
                return false
            case .customLocation(let rightCoordinate, let rightDescription):
                return leftCoordinate.latitude == rightCoordinate.latitude && leftCoordinate.longitude == rightCoordinate.longitude && leftDescription == rightDescription
            case .savedLocation:
                return false
            }
        
        case .savedLocation(let leftLocation):
            switch rhs {
            case .currentLocation:
                return false
            case .customLocation:
                return false
            case .savedLocation(let rightLocation):
                return leftLocation.latitude == rightLocation.latitude && leftLocation.longitude == rightLocation.longitude
            }
            
            
        }
    }
}
