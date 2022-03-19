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
                .font(name.count > 2 ? .caption : .body)
                .fontWeight(name.count > 2 ? Font.Weight.bold : .black)
                .foregroundColor(Color.init("TextNameColor"))
                .multilineTextAlignment(.center)
                .frame(minWidth: 60, maxWidth: 60, minHeight: 50, maxHeight: 50)
                .padding(5)
                .border(Color.init("ButtonColor"), width: 2)
                .cornerRadius(10)
                .padding(5)
        }
        
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
