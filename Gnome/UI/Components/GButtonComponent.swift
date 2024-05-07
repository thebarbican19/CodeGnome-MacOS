//
//  GButtonComponent.swift
//  Gnome
//
//  Created by Joe Barbour on 5/3/24.
//

import SwiftUI
import FluidGradient

struct ButtonPrimary: View {
    @State public var title: LocalizedStringKey
    @State public var icon:String? = nil

    @State private var hover:Bool = false
    
    let callback: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .foregroundColor(Color("TileTitle"))
                .font(.custom("Inter", size: 13))
                .kerning(-0.2)
                .fontWeight(.semibold)
                .animation(Animation.easeOut(duration: 0.6), value: self.title)
                .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 6)

            if let icon = icon {
                Image(icon)
                    .foregroundColor(Color("TileTitle"))
                    .font(.system(size: 12).weight(.heavy))
                    .animation(Animation.easeOut(duration: 0.6), value: self.title)
                
            }
            
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            ZStack {
                TileShadow()
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(.clear)
                    .stroke(Color("TileTitle").blendMode(.softLight), lineWidth: 1.2)
                    .background(
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [Color("GradientMagenta"), Color("GradientNeon")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .edgesIgnoringSafeArea(.all)
                            
                            Circle()
                                .fill(Color("GradientYellow"))
                                .opacity(hover ? 0.8 : 0.5)
                                .blur(radius: 6)
                                .scaleEffect(3)
                                .offset(y:hover ? -48 : -50)
                            
                        }
                        
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black)
                            .allowsHitTesting(false)
                        
                    )
                
            }
            
        )
        .hover(cursor: .pointingHand) { state in
            if state == true {
                withAnimation(Animation.easeOut(duration: 0.2)) {
                    self.hover = state

                }
                
            }
            else {
                withAnimation(Animation.easeIn(duration: 0.6).delay(0.2)) {
                    self.hover = state
                    
                }
                
            }
        }
        .onTapGesture() {
            callback()
            
        }
        
    }
    
}

struct ButtonSecondary: View {
    @State public var title: LocalizedStringKey
    @State public var icon:String? = nil
    
    @State private var rotate = 0.0
    @State private var hover:Bool = false

    let callback: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .foregroundColor(Color("TileTitle"))
                .font(.custom("Inter", size: 12))
                .kerning(-0.2)
                .fontWeight(.semibold)
                .animation(Animation.easeOut(duration: 0.6), value: self.title)

            if let icon = icon {
                Image(icon)
                    .foregroundColor(Color("TileTitle"))
                    .font(.system(size: 12).weight(.heavy))
                    .animation(Animation.easeOut(duration: 0.6), value: self.title)
                
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                TileShadow()
                
                LinearGradient(
                    gradient: Gradient(colors: [Color("BackgroundGradientTop"), Color("BackgroundGradientBottom"), ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                .mask(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black)
                        .allowsHitTesting(false)
                    
                )
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(.clear)
                    .border($hover, radius: 12)
                
            }
            
        )
        .onTapGesture() {
            callback()
            
        }
        .hover(cursor: .pointingHand) { over in
            hover = over

        }
        
    }
    
}

