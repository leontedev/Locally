//
//  PlayGroundView.swift
//  Locally
//
//  Created by Mihai Leonte on 12/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct PlayGroundView: View {
    var body: some View {
        VStack(spacing: 0.0) {
            Button(action: {
                
            }) {
                Image(systemName: "gear").font(Font.body.weight(.heavy))
            }
            .accentColor(Color.init("TextAccentColor"))
            .frame(width: 50, height: 50)
            .background(Color.init("ButtonColor"))
            
                
                Rectangle()
                    .foregroundColor(Color.init("TextAccentColor"))
                    .frame(width:50, height:2)
                    .fixedSize()
            
            Button(action: {
                
            }) {
                Image(systemName: "location.north.fill").font(Font.body.weight(.heavy))
            }
            .accentColor(Color.init("TextAccentColor"))
            .frame(width: 50, height: 50)
            .background(Color.init("ButtonColor"))
        }
        .cornerRadius(10)
        .offset(x: -164, y: -88)
        .shadow(radius: 6)
    }
}

struct PlayGroundView_Previews: PreviewProvider {
    static var previews: some View {
        PlayGroundView()
    }
}
