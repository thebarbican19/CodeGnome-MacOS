//
//  GModifyers.swift
//  Gnome
//
//  Created by Joe Barbour on 4/22/24.
//

import Foundation
import SwiftUI

struct ViewModifyerHover: ViewModifier {
    @State var cursor:NSCursor = NSCursor.pointingHand
    
    let value: (Bool) -> Void

    func body(content: Content) -> some View {
        content.onHover(perform: { hover in
            switch hover {
                case true : cursor.push()
                default : cursor.pop()
                
            }
                            
            value(hover)
            
        })

    }
    
}

extension View {
    func hover(cursor:NSCursor = NSCursor.pointingHand, value: @escaping (Bool) -> Void = { _ in }) -> some View {
        self.modifier(ViewModifyerHover(cursor:cursor, value: value))
        
    }
    
}
