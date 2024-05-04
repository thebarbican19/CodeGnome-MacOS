//
//  GTileComponents.swift
//  Gnome
//
//  Created by Joe Barbour on 5/3/24.
//

import SwiftUI

struct TileShadow: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(LinearGradient(gradient: Gradient(colors: [Color("TileBackground").opacity(0.0), Color("TileBackground").opacity(0.9)]), startPoint: .top, endPoint: .bottom))
            .offset(y:5)
            .blur(radius: 15)
        
    }
}

struct TileBackground: View {
    @State private var gradientRotate = 0.0

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color("TileBackground"))
            .strokeBorder(
                AngularGradient(gradient: Gradient(colors: [Color("TileBorder"), Color("TileBorder"), Color("TileBorderShine"), Color("TileBorder"), Color("TileBorder"), Color("TileBorder"), Color("TileBorder"), Color("TileBorder")]),
                                center: .center,
                                startAngle: .degrees(gradientRotate),
                                endAngle: .degrees(gradientRotate + 360)),
                lineWidth: 1
            )
            .animation(Animation.linear(duration: 12).repeatForever(autoreverses: false), value: gradientRotate)
            .onAppear {
                gradientRotate = 360
                
            }
            
    }
}

struct TileSection: View {
    @State var geo:GeometryProxy
    
    var body: some View {
        ZStack {
            TileShadow()
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TileBackground"))
                .strokeBorder(Color("TileBorder"),lineWidth: 1)
            
        }
        .frame(width: geo.size.width - 12, height: 400 - 6)
        .padding(12)
            
    }
    
}


