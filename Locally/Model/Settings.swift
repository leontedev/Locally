//
//  Settings.swift
//  Locally
//
//  Created by Mihai Leonte on 05/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

class Settings: ObservableObject {
    @Published var isEnabledGoogleMaps: Bool = false {
        didSet {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(isEnabledGoogleMaps) {
                UserDefaults.standard.set(data, forKey: "isEnabledGoogleMaps")
            }
        }
    }
    
    @Published var isEnabledAppleMaps: Bool = false {
        didSet {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(isEnabledAppleMaps) {
                UserDefaults.standard.set(data, forKey: "isEnabledAppleMaps")
            }
        }
    }
    
    @Published var isEnabledWaze: Bool = false {
        didSet {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(isEnabledWaze) {
                UserDefaults.standard.set(data, forKey: "isEnabledWaze")
            }
        }
    }
    
    // 0 for car, 1 for public transport, 2 for walking
    
    @Published var transitType: Int = 0 {
        didSet {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(transitType) {
                UserDefaults.standard.set(data, forKey: "transitType")
            }
        }
    }
    
    
    init() {
        let decoder = JSONDecoder()
        
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
        
        // if all are disabled, enable Apple Maps by default (first run)
        if !isEnabledGoogleMaps && !isEnabledAppleMaps && !isEnabledWaze {
            isEnabledAppleMaps = true
        }
        
        if let data = UserDefaults.standard.data(forKey: "transitType") {
            if let decodedData = try? decoder.decode(Int.self, from: data) {
                transitType = decodedData
            }
        }
        
    }
}
