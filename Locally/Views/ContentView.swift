//
//  ContentView.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    @State var showOnboardingView = true
    
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
            if showOnboardingView {
                OnboardingView()
                    .onTapGesture {
                        self.showOnboardingView = false
                    }
            } else {
                VStack {
                        ZStack {
                            MapView(location: $locationManager.lastKnownLocation)
                                .frame(height: 350)
                                //.gesture(longPress)
                                //.simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                //.onEnded { print("Changed \($0.location)") })
                            
                            SettingsButton(showSheet: $showSettingsSheet)
                                .sheet(isPresented: $showSettingsSheet, content: {
                                    SettingsView(settings: self.settings) })
                                .offset(x: -148, y: -115)
                                .shadow(radius: 6)

                            
                            AddButton(showSheet: $showAddSheet)
                                .sheet(isPresented: $showAddSheet, content: {
                                    AddLocation(locations: self.locations, location: self.locationManager) })
                                .offset(x: 110, y: 125)
                                .shadow(radius: 6)
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
                        print("settings.isEnabledGoogleMaps \(self.settings.isEnabledGoogleMaps)")
                        print("settings.isEnabledAppleMaps \(self.settings.isEnabledAppleMaps)")
                        print("settings.isEnabledWaze \(self.settings.isEnabledWaze)")
                        
                        self.locationManager.startUpdating()
                        // To remove only extra separators below the list:
                        UITableView.appearance().tableFooterView = UIView()
                        // To remove all separators including the actual ones:
                        UITableView.appearance().separatorStyle = .none
                        //UINavigationBar.appearance().backgroundColor = UIColor(named: "TextNameColor")
                        //UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(named: "TextNameColor")]
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
        .frame(minWidth: 0, maxWidth: 100)
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
