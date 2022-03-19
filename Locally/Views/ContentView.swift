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
    @State private var selectedLocation: Location?
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
                                    //self.hapticSuccess()
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
                                    self.hapticSuccess()
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
                        }

                        if self.locations.isEmpty {
                            Text("No Locations Saved")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color.gray)
                                .padding(.top, 40.0)
                        }

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
                                            .lineLimit(1)

                                        Text(String(location.address?.components(separatedBy: "\n")[0] ?? ""))
                                            .font(.caption)
                                            .foregroundColor(Color.gray)
                                            .padding(.leading, 15)
                                            .lineLimit(2)

                                        Spacer()
                                    }

                                    Spacer()

                                    NavigationMenu(
                                        settings: self.settings,
                                        latitude: location.latitude ,
                                        longitude: location.longitude
                                    )
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
                                        self.selectedLocation = location
                                        self.showEditSheet = true
                                    }) {
                                        HStack {
                                            Text("Edit Name")
                                            Image(systemName: "pencil")
                                        }
                                    }

                                    Button(action: {
                                        UIApplication.shared.open(URL(string: "http://maps.apple.com/?daddr=\(location.latitude),\(location.longitude)&dirflg=\(self.settings.transitTypeApple)")!)
                                    }) {
                                        HStack {
                                            Text("Apple Maps")
                                            Image(systemName: "paperplane.fill")
                                        }
                                    }

                                    if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
                                        Button(action: {
                                            UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(location.latitude),\(location.longitude)&travelmode=\(self.settings.transitTypeGoogle)")!)
                                        }) {
                                            HStack {
                                                Text("Google Maps")
                                                Image(systemName: "paperplane.fill")
                                            }
                                        }
                                    }

                                    if (UIApplication.shared.canOpenURL(URL(string: "waze://")!)) {
                                        Button(action: {
                                            UIApplication.shared.open(URL(string: "waze://?ll=\(location.latitude),\(location.longitude)&navigate=yes&zoom=17")!)
                                        }) {
                                            HStack {
                                                Text("Waze")
                                                Image(systemName: "paperplane.fill")
                                            }
                                        }
                                    }
                                    
                                    if (UIApplication.shared.canOpenURL(URL(string: "uber://")!)) {
                                        Button(action: {
                                            UIApplication.shared.open(URL(string: "uber://?action=setPickup&dropoff[latitude]=\(location.latitude)&dropoff[longitude]=\(location.longitude)")!)
                                        }) {
                                            HStack {
                                                Text("Uber")
                                                Image(systemName: "paperplane.fill")
                                            }
                                        }
                                    }
                                    
                                    if (UIApplication.shared.canOpenURL(URL(string: "lyft://")!)) {
                                        Button(action: {
                                            UIApplication.shared.open(URL(string: "lyft://ridetype?id=lyft&destination[latitude]=\(location.latitude)&destination[longitude]=\(location.longitude)")!)
                                        }) {
                                            HStack {
                                                Text("Lyft")
                                                Image(systemName: "paperplane.fill")
                                            }
                                        }
                                    }
                                            
                                    Button(action: { self.removeItem(item: location) }) {
                                        HStack {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    }.foregroundColor(.red)
                                }
                                .sheet(isPresented: $showEditSheet) {
                                    EditLocation(location: $selectedLocation)
                                        .environment(\.managedObjectContext, self.moc)
                                }
                                .padding(5)
                                .onTapGesture {
                                    self.showOnMap(location: location)
                                    self.hapticSuccess()
                                }
                            }
                            .onDelete(perform: self.removeItems)
                            .buttonStyle(PlainButtonStyle())
                        }
                        .listStyle(.plain)
                    }
                    .onAppear {
                        self.locationManager.startUpdating()
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.init(named: "TextNameColor") ?? UIColor.blue], for: .selected)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.init(named: "TextNameColor") ?? UIColor.blue], for: .normal)
                    }
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
    
    func hapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
