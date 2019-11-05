//
//  Locations.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

class Locations: ObservableObject {
    
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var date: Date = Date()
    @Published var dateString: String = ""
    @Published var description: String = ""
    
    @Published var items = [LocationItem]() {
        didSet {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(items) {
                UserDefaults.standard.set(data, forKey: "Items")
            }
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([LocationItem].self, from: data) {
                items = decodedData
                return
            }
        }
        items = []
    }
}

