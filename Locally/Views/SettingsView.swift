//
//  SettingsView.swift
//  Locally
//
//  Created by Mihai Leonte on 05/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enable only the Navigation apps you plan to use (max 2).")) {
                    if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
                        Toggle(isOn: $settings.isEnabledGoogleMaps) {
                            Text("Google Maps")
                                .foregroundColor(Color.init("TextNameColor"))
                        }
                        .padding(4.0)
                        .disabled(settings.isEnabledWaze && settings.isEnabledAppleMaps)
                    }
                    
                    Toggle(isOn: $settings.isEnabledAppleMaps) {
                        Text("Apple Maps")
                            .foregroundColor(Color.init("TextNameColor"))
                        }
                    .padding(4.0)
                    .foregroundColor(Color.init("ButtonColor"))
                    .disabled(settings.isEnabledGoogleMaps && settings.isEnabledWaze)
                    
                    if (UIApplication.shared.canOpenURL(URL(string: "waze://")!)) {
                        Toggle(isOn: $settings.isEnabledWaze) {
                            Text("Waze")
                                .foregroundColor(Color.init("TextNameColor"))
                        }
                        .padding(4.0)
                        .disabled(settings.isEnabledGoogleMaps && settings.isEnabledAppleMaps)
                    }
                }
                
                Section {
                    Button(action: {
                        self.settings.showOnboardingView = true
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")//"arrow.up.right.diamond")
                                .font(.largeTitle)
                                .frame(width: 50)
                                .foregroundColor(Color.init("ButtonColor"))
                            
                            VStack(alignment: .leading) {
                                Text("Tutorial")
                                    .font(.headline)
                                    .foregroundColor(Color.init("ButtonColor"))
                                
                                Text("Go through the onboarding screens again.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding(.vertical)
                    
                    Button(action: {
                        if UIApplication.shared.canOpenURL(URL(string: "twitter://")!) {
                            UIApplication.shared.open(URL(string: "twitter://user?screen_name=leonte_dev")!)
                        } else {
                            UIApplication.shared.open(URL(string: "https://twitter.com/leonte_dev")!)
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.right.square.fill")
                                .font(.largeTitle)
                                .frame(width: 50)
                                .foregroundColor(Color.init("ButtonColor"))
                            
                            VStack(alignment: .leading) {
                                Text("Twitter")
                                    .font(.headline)
                                    .foregroundColor(Color.init("ButtonColor"))
                                Text("Follow me on Twitter @leonte_dev")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding(.vertical)
                    
                    Button(action: {
                        guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/idXXXXXXXXXX?action=write-review")
                            else { fatalError("Expected a valid URL") }
                        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                    }) {
                        HStack {
                            Image(systemName: "heart.circle.fill")
                                .font(.largeTitle)
                                .frame(width: 50)
                                .foregroundColor(Color.init("ButtonColor"))
                            
                            VStack(alignment: .leading) {
                                Text("App Store")
                                    .font(.headline)
                                    .foregroundColor(Color.init("ButtonColor"))
                                
                                Text("Please rate Locally. It really helps!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding(.vertical)
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
        SettingsView(settings: Settings())
    }
}
