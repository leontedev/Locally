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
                
                Section {
                    Button(action: {
                        self.settings.showOnboardingView = true
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")//"arrow.up.right.diamond")
                                .font(.largeTitle)
                                .frame(width: 50)
                            
                            VStack(alignment: .leading) {
                                Text("Tutorial").font(.headline)
                                Text("Go through the onboarding screens again.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding()
                    
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
                            
                            VStack(alignment: .leading) {
                                Text("Twitter").font(.headline)
                                Text("Follow me on Twitter @leonte_dev")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding()
                    
                    Button(action: {
//                        rateApp(appId: "id959379869") { success in
//                            print("RateApp \(success)")
//                        }
                    }) {
                        HStack {
                            Image(systemName: "heart.circle.fill")
                                .font(.largeTitle)
                                .frame(width: 50)
                            
                            VStack(alignment: .leading) {
                                Text("App Store").font(.headline)
                                Text("Please rate Locally. It really helps!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding()
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Close") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // MARK: Rate app functions
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }
    
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settings: Settings())
    }
}
