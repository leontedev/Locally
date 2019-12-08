//
//  EditLocation.swift
//  Locally
//
//  Created by Mihai Leonte on 08/12/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct EditLocation: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var showAlert = false
    var location: Location
    
    var body: some View {
        NavigationView {
            Form {
                AutoFocusTextField(text: $name, placeholder: location.name!)
            }
            .navigationBarTitle("Edit Name")
            .navigationBarItems(trailing: Button("Save") {
                self.location.name = self.name
                if self.moc.hasChanges {
                    try? self.moc.save()
                }
                self.presentationMode.wrappedValue.dismiss()
            }.disabled(name.isEmpty))
        }
    }
}
