//
//  GNavigationController.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import SwiftUI

struct MainController: View {
    let persitence = PersistenceManager.container
    let screen = NSScreen.main!.visibleFrame

    var body: some View {
        ZStack {
            VStack() {
                MainSection(.todo)
                
                MainSection(.done)

                MainSection(.archived)

            }
            .frame(width: 240, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: screen.height)
            .background(
                ZStack {
                    WindowGradientView()
                    
                }
                
            )
            
        }
        .modelContainer(persitence)
        .environmentObject(ProcessManager.shared)
        .environmentObject(WindowManager.shared)
            
    }
    
}
