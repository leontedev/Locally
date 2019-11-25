//
//  SplashScreen.swift
//  Locally
//
//  Created by Mihai Leonte on 08/11/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        //to have a pointy lower shape instead of a Curve
        //path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY/1.4))
        //path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY), control: CGPoint(x: rect.midX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX ,y: rect.minY))
        
        //path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct FieldOfView: Shape {
    var inset: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let value = CGFloat(inset)
        
        path.move(to: CGPoint(x: rect.minX+value, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX-value, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX+value, y: rect.maxY))
        
        return path
    }
}

struct OnboardingView: View {
    static var shouldAnimate = true
    @State var size: CGFloat = 1
    
    var body: some View {
        
        GeometryReader { reader in
            ZStack {
                    FieldOfView(inset: 100)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.clear]), startPoint: .bottom, endPoint: .top))
                    
                        //.stroke(Color.blue, lineWidth: 5)
                        .frame(width: 400, height: 400)
                        .offset(y: -220)

                    Circle()
                        //.stroke(Color.blue, lineWidth: 10)
                        .fill(Color.white)
                        .shadow(radius: 10)
                        .frame(width: 270)
                    Circle()
                        .fill(Color.blue)
                        .shadow(radius: 5)
                        .frame(width: 180)
                        .scaleEffect(self.size)
                        .onAppear() {
                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever()) {
                                self.size = 1.2 }
                            }
                    Arrow()
                        //.stroke(Color.red, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .fill(Color.blue)
                        .frame(width: 140, height: 90)
                        .shadow(radius: 2)
                        .offset(y: -140)
                    
                    Text("Locally")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: -300)
                    
                    VStack(alignment: .center, spacing: 70) {
                        Text("Save your favorite destinations and navigate to them quickly.")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 300)
                        Text("Tap to continue")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    }.offset(y: 250)
                }
                .background(Color.green.saturation(0.3))
                .edgesIgnoringSafeArea(.all)
                //.frame(width: reader.size.width, height: reader.size.height)
                .aspectRatio(CGFloat(reader.size.width / reader.size.height) , contentMode: .fit)
        }
            
        }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
