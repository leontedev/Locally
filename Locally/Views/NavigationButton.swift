//
//  NavigationButton.swift
//  Locally
//
//  Created by Mihai Leonte on 19/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct NavigationButton: View {
    var name: String
    var urlString: String
    
    var body: some View {
        Button(action: {
            UIApplication.shared.open(URL(string: self.urlString)!)
        }) {
            Text(name)
                .font(name.count > 2 ? .caption : .callout)
                .fontWeight(name.count > 2 ? Font.Weight.regular : .heavy)
                .foregroundColor(Color.init("TextAccentColor"))
        }
        .multilineTextAlignment(.center)
        .frame(minWidth: 60, maxWidth:60, minHeight: 50, maxHeight: 50)
        .padding(5)
        .background(Color.init("ButtonColor"))
        .cornerRadius(10)
        .padding(5) // spaceing from outter elements
    }
}

struct NavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NavigationButton(name: "GO", urlString: "")
            
            NavigationButton(name: "Google Maps", urlString: "")
            
            NavigationButton(name: "Apple Maps", urlString: "")
            
            NavigationButton(name: "Waze", urlString: "")
        }
    }
}
