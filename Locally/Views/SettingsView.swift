//
//  SettingsView.swift
//  Locally
//
//  Created by Mihai Leonte on 05/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State private var isEnabledGoogleMaps = true
    @State private var isEnabledAppleMaps = true
    @State private var isEnabledWaze = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enable only the Navigation apps you plan to use.")) {
                    Toggle(isOn: $isEnabledGoogleMaps) {
                        Text("Google Maps")
                    }.padding()
                    
                    Toggle(isOn: $isEnabledAppleMaps) {
                        Text("Apple Maps")
                    }.padding()
                    
                    Toggle(isOn: $isEnabledWaze) {
                        Text("Waze")
                    }.padding()
                }
                
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Close") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
