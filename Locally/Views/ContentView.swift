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
    @ObservedObject var settings = Settings()
    
    //@ObservedObject var locations = Locations()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Location.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Location.date, ascending: false)]) var locations: FetchedResults<Location>
    
    @State private var showAddSheet = false
    @State private var showSettingsSheet = false
    @State private var type = 0
    
    @State private var onboardingTapsCounter = 0
    
    func removeItems(at offsets: IndexSet) {
        //locations.items.remove(atOffsets: offsets)
        for offset in offsets {
            let loc = locations[offset]
            moc.delete(loc)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }
    
    var body: some View {
        
        if self.settings.showOnboardingView {
            return AnyView(OnboardingView(taps: $onboardingTapsCounter)
                    .onTapGesture {
                        self.onboardingTapsCounter += 1
                        if self.onboardingTapsCounter > 1 {
                            self.settings.showOnboardingView = false
                            self.locationManager.shouldEnableCurrentLocationButton = false
                        }
                    })

        } else {
            return AnyView(
                GeometryReader { reader in
                    VStack {
                        ZStack {
                            // MARK: MapView
                            MapView(locationManager: self.locationManager, location: self.$locationManager.lastKnownLocation)
                                .frame(height: reader.size.height / 2)

                            if self.locationManager.shouldEnableCurrentLocationButton {
                                VStack(spacing: 0) {
                                    // MARK: Settings Button
                                    Button(action: {
                                        self.showSettingsSheet = true
                                    }) {
                                        Image(systemName: "gear").font(Font.body.weight(.heavy))
                                    }
                                    .sheet(isPresented: self.$showSettingsSheet, content: {
                                        SettingsView(settings: self.settings) })
                                    .accentColor(Color.init("TextAccentColor"))
                                    .frame(width: reader.size.height / 14, height: reader.size.height / 14)
                                    .background(Color.init("ButtonColor"))

                                    Rectangle()
                                        .foregroundColor(Color.init("TextAccentColor"))
                                        .frame(width:reader.size.height / 14, height:1)
                                        .fixedSize()
                                    
                                    // MARK: Current Location Button
                                    Button(action: {
                                        self.locationManager.startUpdating()
                                        self.locationManager.shouldEnableCurrentLocationButton = false
                                    }) {
                                        Image(systemName: "location.north.fill").font(Font.body.weight(.heavy))
                                    }
                                    .accentColor(Color.init("TextAccentColor"))
                                    .frame(width: reader.size.height / 14, height: reader.size.height / 14)
                                    .background(Color.init("ButtonColor"))
                                }//.shadow(radius: 6) // I had to comment out the shadow view modifer - as it was causing weird glitches (the tap gestures were going "through" the button down to the MapView)
                                .cornerRadius(10)
                                .offset(x: -reader.size.width / 2.6, y: -reader.size.height / 7.5)
                            } else {
                                // MARK: Settings Button
                                SettingsButton(showSheet: self.$showSettingsSheet)
                                    .sheet(isPresented: self.$showSettingsSheet, content: {
                                        SettingsView(settings: self.settings) })
                                    // FIXME: Not working
                                    .frame(width: reader.size.height)
                                    //.shadow(radius: 6)
                                    .offset(x: -reader.size.width / 2.6, y: -reader.size.height / 6)
                            }


                            // MARK: Save button
                            AddButton(showSheet: self.$showAddSheet)
                                .sheet(isPresented: self.$showAddSheet, content: {
                                    AddLocation(location: self.locationManager)
                                        .environment(\.managedObjectContext, self.moc)
                                })
                                .shadow(radius: 6)
                                .offset(x: reader.size.width / 3, y: reader.size.height / 5)
                        }

                        Divider()

                        if self.locations.isEmpty {
                            Text("No Locations Saved")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color.gray)
                                .padding(.top, 40.0)
                        }

                        // If only Waze is displayed - don't display the Picker (as it's not available)
                        if (self.settings.isEnabledAppleMaps || self.settings.isEnabledGoogleMaps) && !self.locations.isEmpty {
                            Picker("Type", selection: self.$settings.transitType) {
                                    Image(systemName: "car.fill").tag(0)
                                    Image(systemName: "tram.fill").tag(1)
                                    Image(systemName: "person.fill").tag(2)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.leading, 10)
                                .padding(.trailing, 10)
                                .accentColor(Color.init("TextAccentColor"))
                                .frame(maxWidth: reader.size.width)
                        }

                        List {
                            ForEach(self.locations, id: \.self) { location in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(location.name ?? "Unknown")
                                            .font(.headline)
                                            .padding(.leading, 15)
                                            .foregroundColor(Color.init("TextNameColor"))

                                        Text(location.address ?? "")
                                            .font(.caption)
                                            .foregroundColor(Color.gray)
                                            .padding(.leading, 15)
                                    }

                                    Spacer()

                                    NavigationMenu(settings: self.settings,
                                                   latitude: location.latitude ?? 0,
                                                   longitude: location.longitude ?? 0)
                                }
                                .padding(5)
                                .background(Color.init("CellColor"))
                                .cornerRadius(16)
                                .clipped()
                                .shadow(radius: 1)

                            }
                            .onDelete(perform: self.removeItems)
                            .buttonStyle(PlainButtonStyle())

                        }.frame(maxWidth: reader.size.width)


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

                    }
                    .frame(maxWidth: reader.size.width)
                    .edgesIgnoringSafeArea(.all)

                })
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
    var latitude: Double
    var longitude: Double
    
    private let googleMapsTypes = ["driving", "transit", "walking"]
    private let appleMapsTypes = ["d", "r", "w"]
    private let buttonLabels = ["Go", "Google Maps", "Apple Maps", "Waze"]
    

    @ViewBuilder var body: some View {
        HStack {
            if settings.isEnabledGoogleMaps {
                NavigationButton(name: (settings.isEnabledAppleMaps || settings.isEnabledWaze) ? buttonLabels[1] : buttonLabels[0], urlString: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)&travelmode=\(self.googleMapsTypes[self.settings.transitType])")
                
            }
            //"comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=\(self.googleMapsTypes[self.settings.transitType])"
            
            
            if settings.isEnabledAppleMaps {
                NavigationButton(name: (settings.isEnabledGoogleMaps || settings.isEnabledWaze) ? buttonLabels[2] : buttonLabels[0], urlString: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=\(self.appleMapsTypes[self.settings.transitType])")
            }
            if settings.isEnabledWaze {
                NavigationButton(name: (settings.isEnabledAppleMaps || settings.isEnabledGoogleMaps) ? buttonLabels[3] : buttonLabels[0], urlString: "waze://?ll=\(latitude),\(longitude)&navigate=yes&zoom=17")
            }
        }
        
    }
}


