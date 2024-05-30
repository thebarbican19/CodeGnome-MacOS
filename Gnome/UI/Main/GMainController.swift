//
//  GNavigationController.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import SwiftUI

struct MainContainer: View {
    @EnvironmentObject var settings:SettingsManager

    let layout = [GridItem(.flexible(minimum: 30, maximum: 355))]

    var body: some View {
        LazyVGrid(columns: layout, spacing:18) {
            Spacer().frame(height: 0)
    
            MainSection(.active)

            MainSection(.todo)
            
            MainSection(.done)
            
            if settings.settingsArchive == true {
                MainSection(.archived)
                
            }
            
            if settings.sectionSnoozed == true {
                MainSection(.snoozed)

            }
            
            if settings.sectionHidden == true {
                MainSection(.hidden)
                
            }

            Spacer().frame(height: 15)

        }
        
    }
    
}

struct MainController: View {
    let persitence = PersistenceManager.container
    let screen = NSScreen.main!.visibleFrame
    
    var body: some View {
        ZStack {
            ScrollView() {
                MainContainer()

            }
            .frame(width: 380, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: screen.height)
            .fade([.bottom], padding:50)
            .background(.clear)

            // TODO: Fix Scrolling Issue!!
            
        }
        .modelContainer(persitence)
        .environmentObject(WindowManager.shared)
        .environmentObject(TaskManager.shared)
        .environmentObject(ProcessManager.shared)
        .environmentObject(OnboardingManager.shared)
        .environmentObject(LicenseManager.shared)
        .environmentObject(SettingsManager.shared)

    }
    
}
