//
//  GBackgroundContainer.swift
//  Gnome
//
//  Created by Joe Barbour on 5/1/24.
//

import SwiftUI

struct BackgroundContainer: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color("BackgroundGradientTop"), Color("BackgroundGradientBottom")]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
        .overlay(BackgroundAnimation())
        .background(WindowViewBlur())
        
    }
    
}

struct BackgroundAnimation: View {
    let columns = Array(repeating: GridItem(.fixed(10), spacing: 0), count: 20)
        
    var body: some View {
        ScrollView {
//            LazyVGrid(columns: columns, spacing: 0) {
//                ForEach(0..<400, id: \.self) { _ in
//                    BackgroundSprite()
//                    
//                }
//                
//            }
            
            // TODO: Finish Background Pulsating Animation
            
        }
        
    }
        
}

struct BackgroundSprite: View {
    @State private var pulsate = false
    
    let timer = Timer.publish(every: Double.random(in: 0.5...2.0), on: .main, in: .common).autoconnect()
    
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 10, height: 10)
            .padding(10)
            .scaleEffect(pulsate ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: pulsate)
            .onReceive(timer) { _ in
                pulsate.toggle()
                
            }
    }
    
}
