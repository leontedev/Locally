//
//  ContentView.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var locations = Locations()
    
    @State private var showAddSheet = false
    @State private var showSettingsSheet = false
    @State private var type = 0
    private let googleMapsTypes = ["driving", "transit", "walking"]
    private let appleMapsTypes = ["d", "r", "w"]
    
    func removeItems(at offsets: IndexSet) {
        locations.items.remove(atOffsets: offsets)
    }
    
    var body: some View {
            VStack {
                ZStack {
                    MapView(location: $locationManager.lastKnownLocation)
                        .frame(height: 350)
                    VStack {
                        Spacer().frame(height: 20)
                        
                        HStack {
                            SettingsButton(showSheet: $showSettingsSheet)
                                .sheet(isPresented: $showSettingsSheet, content: {
                                    SettingsView() })
                            
                            Spacer()
                        }
                        
                        Spacer().frame(height: 160)

                        HStack {
                            Spacer()
                            AddButton(showSheet: $showAddSheet)
                                .sheet(isPresented: $showAddSheet, content: {
                                    AddLocation(locations: self.locations, location: self.locationManager) })
                        }
                    }
                }
                
                Divider()
                
                Picker("Type", selection: $type) {
                    Image(systemName: "car.fill").tag(0)
                    Image(systemName: "tram.fill").tag(1)
                    Image(systemName: "person.fill").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .accentColor(Color.init("TextAccentColor"))
                
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

                            NavigationButton(name: "Google Maps",
                                             urlString: "comgooglemaps://?daddr=\(item.latitude),\(item.longitude)&directionsmode=\(self.googleMapsTypes[self.type])")
                            
                            NavigationButton(name: "Apple Maps",
                                             urlString: "http://maps.apple.com/?daddr=\(item.latitude),\(item.longitude)&dirflg=\(self.appleMapsTypes[self.type])")
                            
                        }
                        .padding(5)
                        .background(Color.init("CellColor"))
                        .cornerRadius(16)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: 0.2)
                        )
                        
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
            }.edgesIgnoringSafeArea(.all)
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
