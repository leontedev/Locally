//
//  ContentView.swift
//  Locally
//
//  Created by Mihai Leonte on 10/31/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var locations = Locations()
    @State private var showAddSheet = false
    
    func removeItems(at offsets: IndexSet) {
        locations.items.remove(atOffsets: offsets)
    }
    
    var body: some View {
        

            VStack {
                ZStack {
                    MapView()
                        .frame(height: 350)
                    VStack {
                        Spacer().frame(height: 260)

                        HStack {
                            Spacer()
                            AddButton(showSheet: $showAddSheet)
                        }
                    }
                }
                
                List {
                    ForEach(self.locations.items) { item in
                        
                        HStack {
                            
                            VStack {
                                Text(item.name)
                                    .font(.headline)
                                    .padding(.leading, 15)
                                Text(item.description)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                UIApplication.shared.openURL(URL(string: "comgooglemaps://?q=&center=\(item.latitude),\(item.longitude)&zoom=15&views=transit")!)
                            }) {
                                Text("Google Maps").font(.footnote)
                            }
                            .accentColor(.white)
                            .frame(minWidth: 0, maxWidth: 50)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(5)
                        }.overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: 0.2)
                        )
                        
                    }
                    .onDelete(perform: removeItems)
                    .buttonStyle(PlainButtonStyle())
                    
                }
            }
            .sheet(isPresented: $showAddSheet, content: {
                AddLocation(locations: self.locations)
                
            })
            .onAppear {
                // To remove only extra separators below the list:
                UITableView.appearance().tableFooterView = UIView()

                // To remove all separators including the actual ones:
                UITableView.appearance().separatorStyle = .none
                
                let observer = NotificationCenter.default.addObserver(
                    forName: Notification.Name("newLocationSaved"),
                    object: nil,
                    queue: nil) { notification in
                        if let location = notification.userInfo?["location"] as? CurrentLocation {
                            self.locations.latitude = location.latitude
                            self.locations.longitude = location.longitude
                            self.locations.date = location.date
                            self.locations.dateString = location.dateString
                            self.locations.description = location.description.components(separatedBy: "@")[0]
                        }
                    }
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
        .accentColor(.white)
        .frame(minWidth: 0, maxWidth: 100)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
        .padding()
    }
}


