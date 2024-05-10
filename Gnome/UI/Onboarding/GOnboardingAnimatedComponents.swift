//
//  GOnboardingAnimatedComponents.swift
//  Gnome
//
//  Created by Joe Barbour on 5/10/24.
//

import Foundation
import SwiftUI

struct AnimationShortcutKeyView: View {
    @State var key:AppShortcutKeys
    
    @Binding var current:AppShortcutKeys
    @Binding var position:CGFloat

    var animation:Namespace.ID
    var body: some View {
        VStack(alignment: key.system ? .trailing : .center) {
            Text(key.rawValue)
                .font(.system(size: key.system ? 16 : 18).weight(.semibold))
                .foregroundColor(Color("TileTitle"))

            if let name = key.name {
                Text(name)
                    .foregroundColor(Color("TileSubtitle"))
                
            }
            
        }
        .frame(width: key.system ? 70 : 30, height: 50, alignment: key.system ? .trailing : .center)
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .background(
            ButtonSecondaryBackground(.constant(false))

        )
        .matchedGeometryEffect(id: "g_key_\(key.rawValue)", in: animation)
        .offset(x:self.key == .option ? -(self.position / 2) : self.position)
        .scaleEffect(self.key == self.current ? 1.0 : 0.4)
        .opacity(self.key == self.current ? 1.0 : 0.0)
        .rotationEffect(.degrees(self.key == self.current ? 0.0 : self.position))

    }
    
}

struct AnimationShortcutView: View {
    @State private var key:AppShortcutKeys = .leftBracket
    @State private var position:CGFloat = 70

    @Namespace var animation

    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                AnimationShortcutKeyView(key: .leftBracket, current: self.$key, position: self.$position, animation: animation).zIndex(5)
                
                AnimationShortcutKeyView(key: .option, current: .constant(.option), position: self.$position, animation: animation)
                    .zIndex(10)

                AnimationShortcutKeyView(key: .rightBracket, current: self.$key, position: self.$position, animation: animation).zIndex(5)
                    
            }

        }
        .offset(y:6)
        .onReceive(timer) { _ in
            withAnimation(.interactiveSpring(response: 0.9, dampingFraction: 0.9, blendDuration: 0.1)) {
                switch self.key {
                    case .leftBracket : self.key = .rightBracket
                    default : self.key = .leftBracket
                        
                }
             
                self.position = .leftBracket == self.key ? -70 : 70
                                        
            }
            
        }
        
    }
    
}

