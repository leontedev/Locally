//
//  Settings.swift
//  Locally
//
//  Created by Mihai Leonte on 05/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

class Settings: ObservableObject {
    @Published var showOnboardingView: Bool = true {
        didSet {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(showOnboardingView) {
                UserDefaults.standard.set(data, forKey: "showOnboardingView")
            }
        }
    }
    
    @Published var isEnabledGoogleMaps: Bool = false {
        didSet {
            if isEnabledGoogleMaps {
                enabledCount += 1
            } else {
                enabledCount -= 1
            }
            
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(isEnabledGoogleMaps) {
                UserDefaults.standard.set(data, forKey: "isEnabledGoogleMaps")
            }
        }
    }
    
    @Published var isEnabledAppleMaps: Bool = false {
        didSet {
            if isEnabledAppleMaps {
                enabledCount += 1
            } else {
                enabledCount -= 1
            }
            
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(isEnabledAppleMaps) {
                UserDefaults.standard.set(data, forKey: "isEnabledAppleMaps")
            }
        }
    }
    
    @Published var isEnabledWaze: Bool = false {
        didSet {
            if isEnabledWaze {
                enabledCount += 1
            } else {
                enabledCount -= 1
            }
            
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(isEnabledWaze) {
                UserDefaults.standard.set(data, forKey: "isEnabledWaze")
            }
        }
    }
    
    @Published var isEnabledUber: Bool = false {
        didSet {
            if isEnabledUber {
                enabledCount += 1
            } else {
                enabledCount -= 1
            }
            
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(isEnabledUber) {
                UserDefaults.standard.set(data, forKey: "isEnabledUber")
            }
        }
    }
    
    @Published var isEnabledLyft: Bool = false {
        didSet {
            if isEnabledLyft {
                enabledCount += 1
            } else {
                enabledCount -= 1
            }
            
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(isEnabledLyft) {
                UserDefaults.standard.set(data, forKey: "isEnabledLyft")
            }
        }
    }
    
    @Published var enabledCount: Int = 0
    
    // 0 for car, 1 for public transport, 2 for walking
    
    @Published var transitType: Int = 0 {
        didSet {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(transitType) {
                UserDefaults.standard.set(data, forKey: "transitType")
            }
        }
    }
    
    var transitTypeGoogle: String {
        switch transitType {
            case 0:
            return "driving"
            case 1:
            return "transit"
            case 2:
            return "walking"
            default:
            return "driving"
        }
    }
    
    var transitTypeApple: String {
        switch transitType {
            case 0:
                return "d"
            case 1:
                return "r"
            case 2:
                return "w"
            default:
                return "d"
        }
    }
    
    init() {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.data(forKey: "showOnboardingView") {
            if let decodedData = try? decoder.decode(Bool.self, from: data) {
                showOnboardingView = decodedData
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "isEnabledGoogleMaps") {
            if let decodedData = try? decoder.decode(Bool.self, from: data) {
                isEnabledGoogleMaps = decodedData
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "isEnabledAppleMaps") {
            if let decodedData = try? decoder.decode(Bool.self, from: data) {
                isEnabledAppleMaps = decodedData
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "isEnabledWaze") {
            if let decodedData = try? decoder.decode(Bool.self, from: data) {
                isEnabledWaze = decodedData
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "isEnabledUber") {
            if let decodedData = try? decoder.decode(Bool.self, from: data) {
                isEnabledUber = decodedData
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "isEnabledLyft") {
            if let decodedData = try? decoder.decode(Bool.self, from: data) {
                isEnabledLyft = decodedData
            }
        }
        
        // if all are disabled, enable Apple Maps by default (first run)
        if !isEnabledGoogleMaps && !isEnabledAppleMaps && !isEnabledWaze && !isEnabledUber {
            isEnabledAppleMaps = true
        }
        
        if let data = UserDefaults.standard.data(forKey: "transitType") {
            if let decodedData = try? decoder.decode(Int.self, from: data) {
                transitType = decodedData
            }
        }
        
        var counter = 0
        if isEnabledUber { counter += 1 }
        if isEnabledWaze { counter += 1 }
        if isEnabledAppleMaps { counter += 1 }
        if isEnabledGoogleMaps { counter += 1 }
        if isEnabledLyft { counter += 1 }
        enabledCount = counter
    }
}
