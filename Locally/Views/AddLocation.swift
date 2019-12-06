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
    //@ObservedObject var locations: Locations
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var location: LocationManager
    var state: MapState
    
    @State private var name = ""
    @State private var showAlert = false
    
    
    var body: some View {
        NavigationView {
            Form {
                //TextField("Name", text: $name)
                AutoFocusTextField(text: $name)
                
                Text((self.state == MapState.currentLocation) ? location.lastKnownDescription ?? "" : location.lastKnownCustomDescription ?? "")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                
                Text("Lat: \((self.state == MapState.currentLocation) ? Double(location.lastKnownLocation?.coordinate.latitude ?? 0) : Double(location.lastKnownCustomLocation?.coordinate.latitude ?? 0)), Long: \((self.state == MapState.currentLocation) ? Double(location.lastKnownLocation?.coordinate.longitude ?? 0) : Double(location.lastKnownCustomLocation?.coordinate.longitude ?? 0))")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            .navigationBarTitle("Save Locally")
            .navigationBarItems(trailing: Button("Save") {
                if self.name != "" {
                    let newLocation = Location(context: self.moc)
                    newLocation.name = self.name

                    newLocation.latitude = (self.state == MapState.currentLocation) ? Double(self.location.lastKnownLocation?.coordinate.latitude ?? 0) : Double(self.location.lastKnownCustomLocation?.coordinate.latitude ?? 0)
                    
                    newLocation.longitude = (self.state == MapState.currentLocation) ? Double(self.location.lastKnownLocation?.coordinate.longitude ?? 0) : Double(self.location.lastKnownCustomLocation?.coordinate.longitude ?? 0)
                    
                    newLocation.date = Date()
                    
                    newLocation.address = (self.state == MapState.currentLocation) ? self.location.lastKnownDescription ?? "Unknown" : self.location.lastKnownCustomDescription ?? "Unknown"
                    
                    if self.moc.hasChanges {
                        try? self.moc.save()
                    }
                    self.name = ""
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.showAlert = true
                }
            }.disabled(name.isEmpty))
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
