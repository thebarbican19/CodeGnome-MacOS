//
//  GBackgroundContainer.swift
//  Gnome
//
//  Created by Joe Barbour on 5/1/24.
//

import SwiftUI

struct BackgroundContainer: View {
    @State var opacity:Double
    @State var horizontal:Bool

    init(_ opacity: Double = 1.0, horizontal:Bool = false) {
        self._opacity = State(initialValue: opacity)
        self._horizontal = State(initialValue: horizontal)

        // TODO: Notification Layout!
        
    }
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color("BackgroundGradientTop").opacity(self.opacity), Color("BackgroundGradientTop").opacity(self.opacity), Color("BackgroundGradientBottom").opacity(self.opacity)]),
            startPoint: horizontal ? .leading : .top,
            endPoint: horizontal ? .trailing : .bottom
        )
        .edgesIgnoringSafeArea(.all)
        .overlay(BackgroundAnimation())
        
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
