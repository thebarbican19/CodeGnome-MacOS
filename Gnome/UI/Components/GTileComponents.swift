//
//  GTileComponents.swift
//  Gnome
//
//  Created by Joe Barbour on 5/3/24.
//

import SwiftUI

struct TileHeader: View {
    @State var header:LocalizedStringKey
    
    var body: some View {
        EmptyView()
        
    }
    
}

struct TileShadow: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(LinearGradient(gradient: Gradient(colors: [Color("TileBackground").opacity(0.0), Color("TileBackground").opacity(0.9)]), startPoint: .top, endPoint: .bottom))
            .offset(y:5)
            .blur(radius: 15)
        
    }
}

struct TileBackground: View {
    @State private var animate:Bool
    @State private var rotate = 0.0
    
    init(animate: Bool) {
        self._animate = State(initialValue: animate)
        self.rotate = rotate
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color("TileBackground"))
            .strokeBorder(
                AngularGradient(gradient: Gradient(colors: [Color("TileBorder"), Color("TileBorderShine"), Color("TileBorder"), Color("TileBorder"), Color("TileBorder"), Color("TileBorder")]),
                                center: .center,
                                startAngle: .degrees(rotate),
                                endAngle: .degrees(rotate + 360)),lineWidth: 1
            )
            .animation(Animation.linear(duration: 12).repeatForever(autoreverses: false), value: rotate)
            .onAppear {
                if animate == true {
                    rotate = 360

                }
                
            }
            
    }
}

struct TileSection: View {    
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color("TileBackground"))
            .strokeBorder(Color("TileBorder"),lineWidth: 1)
            .background(
                ZStack {
                    WindowViewBlur()
                                        
                }
                .mask(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)

                )
                
            )

            
    }
    
}


