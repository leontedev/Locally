//
//  ContentView.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI
import StoreKit
import CoreLocation


struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var settings = Settings()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Location.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Location.date, ascending: false)]) var locations: FetchedResults<Location>
    
    @State private var showAddSheet = false
    @State private var showSettingsSheet = false
    @State private var showEditSheet = false
    @State private var type = 0
    
    @State private var onboardingTapsCounter = 0
    @State private var mapState: MapState = .currentLocation
    
    
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
                            MapView(locationManager: self.locationManager,
                                    location: self.$locationManager.lastKnownLocation,
                                    mapState: self.$mapState)
                                .frame(height: reader.size.height / 2)
                            
                            
                            VStack(spacing: 0) {
                                
                                // MARK: Settings Button
                                Button(action: {
                                    self.showSettingsSheet = true
                                }) {
                                    Image(systemName: "gear").font(Font.body.weight(.heavy))
                                        .accentColor(Color.init("TextAccentColor"))
                                        .frame(width: reader.size.height / 14, height: reader.size.height / 14)
                                        .background(Color.init("ButtonColor"))
                                }
                                .sheet(isPresented: self.$showSettingsSheet, content: {
                                    SettingsView(settings: self.settings, locationManager: self.locationManager) })
                                .accessibility(label: Text("Settings"))
                                

                                Rectangle()
                                    .foregroundColor(Color.init("TextAccentColor"))
                                    .frame(width:reader.size.height / 14, height:1)
                                    .fixedSize()
                                
                                // MARK: Current Location Button
                                Button(action: {
                                    self.mapState = .currentLocation
                                    self.locationManager.preciseLocationUpdateBurst()
                                }) {
                                    Image(systemName: "location.north.fill").font(Font.body.weight(.heavy))
                                        .accentColor(Color.init("TextAccentColor"))
                                        .frame(width: reader.size.height / 14, height: reader.size.height / 14)
                                        .background(Color.init("ButtonColor"))
                                }
                                .accessibility(label: Text("Place Marker on Current Location"))
                            }
                            .cornerRadius(10)
                            .offset(x: -reader.size.width / 2.6, y: -reader.size.height / 7.5)


                            // MARK: Save button
                            AddButton(showSheet: self.$showAddSheet)
                                .sheet(isPresented: self.$showAddSheet, content: {
                                    AddLocation(location: self.locationManager, state: self.mapState)
                                        .environment(\.managedObjectContext, self.moc)
                                })
                                .shadow(radius: 6)
                                .offset(x: reader.size.width / 3, y: reader.size.height / 5)
                                
                            
                            // MARK: Detail Location View
//                            RoundedRectangle(cornerRadius: 15, style: .continuous)
//                                .fill(Color.init("CellColor"))
//                                .frame(width: reader.size.width / 2, height: reader.size.width / 1.5)
//                                .offset(x: reader.size.width / 5)
                        }

                        Divider()

                        if self.locations.isEmpty {
                            Text("No Locations Saved")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color.gray)
                                .padding(.top, 40.0)
                        }

                        // Transit parameters are available just for Google Maps and Apple Maps (don't display the Picker for the rest)
                        // FIXME: Accessibility for the Picker control
                        if (self.settings.isEnabledAppleMaps || self.settings.isEnabledGoogleMaps) && !self.locations.isEmpty {
                            Picker(selection: self.$settings.transitType, label: Text("Select Navigation Type")) {
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
                                .onTapGesture {
                                    self.showOnMap(location: location)
                                }
                                .contextMenu {
                                    Button(action: {
                                        self.showOnMap(location: location)
                                    }) {
                                        HStack {
                                            Text("Show on Map")
                                            Image(systemName: "mappin.and.ellipse")
                                        }
                                    }
                                    
                                    Button(action: {
                                        self.showEditSheet = true
                                    }) {
                                        HStack {
                                            Text("Edit Name")
                                            Image(systemName: "pencil")
                                        }
                                    }.sheet(isPresented: self.$showEditSheet) {
                                        EditLocation(location: location)
                                            .environment(\.managedObjectContext, self.moc)
                                    }
                                    
                                    Button(action: {
                                        self.removeItem(item: location)
                                    }) {
                                        HStack {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    }.foregroundColor(.red)
                                }
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
    
    func removeItem(item: Location) {
        moc.delete(item)
        
        if moc.hasChanges {
            try? moc.save()
        }
    }
    
    func showOnMap(location: Location) {
        self.mapState = .savedLocation(location)
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
            .accentColor(Color.init("TextAccentColor"))
            .frame(minWidth: 0, maxWidth: 80)
            .padding()
            .background(Color.init("ButtonColor"))
            .cornerRadius(10)
            .padding()
        }.accessibility(label: Text("Save Marker's Location"))
        
    }
}

struct SettingsButton: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        Button(action: {
            self.showSheet = true
        }) {
            Image(systemName: "gear").font(Font.body.weight(.heavy))
                .accentColor(Color.init("TextAccentColor"))
                .padding()
                .background(Color.init("ButtonColor"))
                .cornerRadius(10)
                .padding()
        }
        
    }
}

struct NavigationMenu: View {
    @ObservedObject var settings: Settings
    var latitude: Double
    var longitude: Double
    
    private let googleMapsTypes = ["driving", "transit", "walking"]
    private let appleMapsTypes = ["d", "r", "w"]
    private let buttonLabels = ["Go", "Google Maps", " Maps", "Waze", "Uber", "Lyft"]
    

    @ViewBuilder var body: some View {
        HStack {
            if settings.isEnabledGoogleMaps {
                NavigationButton(name: settings.enabledCount > 1 ? buttonLabels[1] : buttonLabels[0], urlString: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)&travelmode=\(self.googleMapsTypes[self.settings.transitType])")
                
            }
            //"comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=\(self.googleMapsTypes[self.settings.transitType])"
            
            
            if settings.isEnabledAppleMaps {
                NavigationButton(name: settings.enabledCount > 1 ? buttonLabels[2] : buttonLabels[0], urlString: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=\(self.appleMapsTypes[self.settings.transitType])")
            }
            
            if settings.isEnabledWaze {
                NavigationButton(name: settings.enabledCount > 1 ? buttonLabels[3] : buttonLabels[0], urlString: "waze://?ll=\(latitude),\(longitude)&navigate=yes&zoom=17")
            }
            
            if settings.isEnabledUber {
                NavigationButton(name: settings.enabledCount > 1 ? buttonLabels[4] : buttonLabels[0], urlString: "uber://?action=setPickup&dropoff[latitude]=\(latitude)&dropoff[longitude]=\(longitude)")
            }
            
            if settings.isEnabledLyft {
                NavigationButton(name: settings.enabledCount > 1 ? buttonLabels[5] : buttonLabels[0], urlString: "lyft://ridetype?id=lyft&destination[latitude]=\(latitude)&destination[longitude]=\(longitude)")
            }
        }
        
    }
}


