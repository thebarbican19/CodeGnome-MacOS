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
    let layout = [GridItem(.flexible(minimum: 30, maximum: 340))]
    
    var body: some View {
        ZStack {
            ScrollView() {
                LazyVGrid(columns: layout, spacing:30) {
                    Spacer().frame(height: 30)
                    
                    MainSection(.todo)
                    
                    MainSection(.done)
                    
                    MainSection(.archived)
                    
                }

            }
            .frame(width: 340, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: screen.height)
            .background(
                ZStack {
                    WindowGradientView()
                    
                }
                
            )
            
        }
        .modelContainer(persitence)
        .environmentObject(WindowManager.shared)
        .environmentObject(TaskManager.shared)
        .environmentObject(ProcessManager.shared)
        .environmentObject(OnboardingManager.shared)
        .environmentObject(LicenseManager.shared)

    }
    
}
