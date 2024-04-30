//
//  GModifyers.swift
//  Gnome
//
//  Created by Joe Barbour on 4/22/24.
//

import Foundation
import SwiftUI

struct ViewModifyerHover: ViewModifier {
    let value: (Bool) -> Void

    func body(content: Content) -> some View {
        content.onHover(perform: { hover in
            switch hover {
                case true : NSCursor.pointingHand.push()
                default : NSCursor.pop()
                
            }
                            
            value(hover)
            
        })

    }
    
}

extension View {
    func hover(value: @escaping (Bool) -> Void = { _ in }) -> some View {
        self.modifier(ViewModifyerHover(value: value))
        
    }
    
}
