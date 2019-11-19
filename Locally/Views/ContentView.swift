//
//  ContentView.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var locations = Locations()
    @ObservedObject var settings = Settings()
    
    @State private var showAddSheet = false
    @State private var showSettingsSheet = false
    @State private var type = 0
    
    func removeItems(at offsets: IndexSet) {
        locations.items.remove(atOffsets: offsets)
    }
    
    var body: some View {

        return VStack {
            if settings.showOnboardingView {
                OnboardingView()
                    .onTapGesture {
                        self.settings.showOnboardingView = false
                        self.locationManager.shouldEnableCurrentLocationButton = true
                    }
            } else {
                VStack {
                        ZStack {
                            // MARK: MapView
                            MapView(locationManager: locationManager, location: $locationManager.lastKnownLocation)
                                .frame(height: 350)

                            if locationManager.shouldEnableCurrentLocationButton {
                                VStack(spacing: 0) {
                                    Button(action: {
                                        self.showSettingsSheet = true
                                    }) {
                                        Image(systemName: "gear").font(Font.body.weight(.heavy))
                                    }
                                    .sheet(isPresented: $showSettingsSheet, content: {
                                        SettingsView(settings: self.settings) })
                                    .accentColor(Color.init("TextAccentColor"))
                                    .frame(width: 50, height: 50)
                                    .background(Color.init("ButtonColor"))

                                    Rectangle()
                                        .foregroundColor(Color.init("TextAccentColor"))
                                        .frame(width:50, height:1)
                                        .fixedSize()


                                    Button(action: {
                                        self.locationManager.startUpdating()
                                        self.locationManager.shouldEnableCurrentLocationButton = false
                                    }) {
                                        Image(systemName: "location.north.fill").font(Font.body.weight(.heavy))
                                    }
                                    .accentColor(Color.init("TextAccentColor"))
                                    .frame(width: 50, height: 50)
                                    .background(Color.init("ButtonColor"))
                                }
                                .cornerRadius(10)
                                //.shadow(radius: 6)
                                .offset(x: -150, y: -86)
                            } else {
                                SettingsButton(showSheet: $showSettingsSheet)
                                    .sheet(isPresented: $showSettingsSheet, content: {
                                        SettingsView(settings: self.settings) })
                                    //.shadow(radius: 6)
                                    .offset(x: -150, y: -110)
                            }
                            
                            
                            // MARK: Save button
                            AddButton(showSheet: $showAddSheet)
                                .sheet(isPresented: $showAddSheet, content: {
                                    AddLocation(locations: self.locations, location: self.locationManager) })
                                .shadow(radius: 6)
                                .offset(x: 120, y: 125)
                        }
                        
                        Divider()
                    
                        // If only Waze is displayed - don't display the Picker (as it's not available)
                        if (settings.isEnabledAppleMaps || settings.isEnabledGoogleMaps) {
                            Picker("Type", selection: $settings.transitType) {
                                Image(systemName: "car.fill").tag(0)
                                Image(systemName: "tram.fill").tag(1)
                                Image(systemName: "person.fill").tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .accentColor(Color.init("TextAccentColor"))
                        }
                        
                        List {
                            ForEach(self.locations.items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                            .padding(.leading, 15)
                                            .foregroundColor(Color.init("TextNameColor"))
                                        Text(item.description)
                                            .font(.caption)
                                            .foregroundColor(Color.gray)
                                            .padding(.leading, 15)
                                    }
                                    
                                    Spacer()
                                    
                                    NavigationMenu(settings: self.settings, item: item)
                                }
                                .padding(5)
                                .background(Color.init("CellColor"))
                                .cornerRadius(16)
                                .clipped()
                                .shadow(radius: 1)
    //                        .overlay(
    //                            RoundedRectangle(cornerRadius: 16)
    //                                .stroke(Color.blue, lineWidth: 0.2)
    //                        )
                                
                            }
                            .onDelete(perform: removeItems)
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                    
                    }
                    .onAppear {                        
                        self.locationManager.startUpdating()
                        
                        // To remove only extra separators below the list:
                        UITableView.appearance().tableFooterView = UIView()
                        // To remove all separators including the actual ones:
                        UITableView.appearance().separatorStyle = .none
                        //UINavigationBar.appearance().backgroundColor = UIColor(named: "TextNameColor")
                        //UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(named: "TextNameColor")]
                        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.init(named: "TextNameColor") ?? UIColor.blue]
                        
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.init(named: "TextNameColor") ?? UIColor.blue], for: .selected)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.init(named: "TextNameColor") ?? UIColor.blue], for: .normal)

                        
                        var runCount: Int = UserDefaults.standard.integer(forKey: "applicationRunsCount")
                        runCount += 1
                        UserDefaults.standard.set(runCount, forKey: "applicationRunsCount")
                        
                        let infoDictionaryKey = kCFBundleVersionKey as String
                        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
                            else { fatalError("Expected to find a bundle version in the info dictionary") }

                        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReviewKey")
                        
                        if runCount >= 5 && currentVersion != lastVersionPromptedForReview {
                            let twoSecondsFromNow = DispatchTime.now() + 2.0
                            
                            DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
                                SKStoreReviewController.requestReview()
                                UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReviewKey")
                            }
                        }
                        

                    }.edgesIgnoringSafeArea(.all)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AddButton: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        Button(action: {
            self.showSheet = true
        }) {
            HStack {
                Image(systemName: "location.circle")
                Text("Save")
            }
        }
        .accentColor(Color.init("TextAccentColor"))
        .frame(minWidth: 0, maxWidth: 80)
        .padding()
        .background(Color.init("ButtonColor"))
        .cornerRadius(10)
        .padding()
    }
}

struct SettingsButton: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        Button(action: {
            self.showSheet = true
        }) {
            Image(systemName: "gear").font(Font.body.weight(.heavy))
        }
        .accentColor(Color.init("TextAccentColor"))
        .padding()
        .background(Color.init("ButtonColor"))
        .cornerRadius(10)
        .padding()
    }
}

struct NavigationMenu: View {
    @ObservedObject var settings: Settings
    var item: LocationItem
    
    private let googleMapsTypes = ["driving", "transit", "walking"]
    private let appleMapsTypes = ["d", "r", "w"]
    private let buttonLabels = ["Go", "Google Maps", "Apple Maps", "Waze"]
    

    @ViewBuilder var body: some View {
        HStack {
            if settings.isEnabledGoogleMaps {
                NavigationButton(name: (settings.isEnabledAppleMaps || settings.isEnabledWaze) ? buttonLabels[1] : buttonLabels[0], urlString: "comgooglemaps://?daddr=\(item.latitude),\(item.longitude)&directionsmode=\(self.googleMapsTypes[self.settings.transitType])")
                
            }
            if settings.isEnabledAppleMaps {
                NavigationButton(name: (settings.isEnabledGoogleMaps || settings.isEnabledWaze) ? buttonLabels[2] : buttonLabels[0], urlString: "http://maps.apple.com/?daddr=\(item.latitude),\(item.longitude)&dirflg=\(self.appleMapsTypes[self.settings.transitType])")
            }
            if settings.isEnabledWaze {
                NavigationButton(name: (settings.isEnabledAppleMaps || settings.isEnabledGoogleMaps) ? buttonLabels[3] : buttonLabels[0], urlString: "waze://?ll=\(item.latitude),\(item.longitude)&navigate=yes&zoom=17")
            }
        }
        
    }
}

struct NavigationButton: View {
    var name: String
    var urlString: String
    
    
    var body: some View {
        Button(action: {
            UIApplication.shared.open(URL(string: self.urlString)!)
        }) {
            Text(name)
                .font(.footnote)
                .foregroundColor(Color.init("TextAccentColor"))
        }
        .multilineTextAlignment(.center)
        .frame(minWidth: 0, maxWidth: 45)
        .padding(12)
        .background(Color.init("ButtonColor"))
        .cornerRadius(10)
        .padding(5)
    }
}
