//
//  AddLocation.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct AddLocation: View {
    @ObservedObject var locations: Locations
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                //TextField("Name", text: $name)
                AutoFocusTextField(text: $name)
                
                Text("\(locations.description)")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    
                
                //Text("Lat: \(locations.latitude), Long: \(locations.longitude)")
            }
            .navigationBarTitle("Add Locally")
            .navigationBarItems(trailing: Button("Save") {
                if self.name != "" {
                    let item = LocationItem(name: self.name,
                                            latitude: self.locations.latitude,
                                            longitude: self.locations.longitude,
                                            date: self.locations.date,
                                            dateString: self.locations.dateString,
                                            description: self.locations.description)
                    self.locations.items.append(item)
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
