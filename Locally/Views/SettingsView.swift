//
//  SettingsView.swift
//  Locally
//
//  Created by Mihai Leonte on 05/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enable only the Navigation apps you plan to use.")) {
                    if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
                        Toggle(isOn: $settings.isEnabledGoogleMaps) {
                            Text("Google Maps")
                        }.padding()
                    }
                    
                    Toggle(isOn: $settings.isEnabledAppleMaps) {
                        Text("Apple Maps")
                    }.padding()
                    
                    if (UIApplication.shared.canOpenURL(URL(string: "waze://")!)) {
                        Toggle(isOn: $settings.isEnabledWaze) {
                            Text("Waze")
                        }.padding()
                    }
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Close") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
