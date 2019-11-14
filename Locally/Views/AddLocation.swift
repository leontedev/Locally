//
//  AddLocation.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI
import CoreLocation

struct AddLocation: View {
    @ObservedObject var locations: Locations
    @ObservedObject var location: LocationManager
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                //TextField("Name", text: $name)
                AutoFocusTextField(text: $name)
                
                Text(location.shouldEnableCurrentLocationButton ? location.lastKnownCustomDescription ?? "" : location.lastKnownDescription ?? "")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                
                Text("Lat: \(location.shouldEnableCurrentLocationButton ? Double(location.lastKnownCustomLocation?.coordinate.latitude ?? 0) : Double(location.lastKnownLocation?.coordinate.latitude ?? 0)), Long: \(location.shouldEnableCurrentLocationButton ? Double(location.lastKnownCustomLocation?.coordinate.longitude ?? 0) : Double(location.lastKnownLocation?.coordinate.longitude ?? 0))")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            .navigationBarTitle("Save Locally")
            .navigationBarItems(trailing: Button("Save") {
                if self.name != "" {
                    
                    if self.location.shouldEnableCurrentLocationButton {
                        let item = LocationItem(name: self.name,
                                                latitude: Double(self.location.lastKnownCustomLocation?.coordinate.latitude ?? 0),
                                                longitude: Double(self.location.lastKnownCustomLocation?.coordinate.longitude ?? 0),
                                                date: Date(),
                                                description: self.location.lastKnownCustomDescription ?? "Unknown")
                        self.locations.items.append(item)
                    } else {
                        let item = LocationItem(name: self.name,
                                                latitude: Double(self.location.lastKnownLocation?.coordinate.latitude ?? 0),
                                                longitude: Double(self.location.lastKnownLocation?.coordinate.longitude ?? 0),
                                                date: Date(),
                                                description: self.location.lastKnownDescription ?? "Unknown")
                        self.locations.items.append(item)
                    }
                    
                    self.name = ""
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.showAlert = true
                }
            })
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Enter a name"), message: Text("Name field cannot be empty."))
        }
        
    }
}

//struct AddLocation_Previews: PreviewProvider {
//    static var previews: some View {
//        AddLocation(locations: Locations(), currentLocation: nil)
//    }
//}
