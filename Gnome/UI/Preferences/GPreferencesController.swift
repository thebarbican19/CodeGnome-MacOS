//
//  GPreferencesController.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import SwiftUI

struct PreferencesController: View {
    let persitence = PersistenceManager.container

    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack(spacing: 0) {
                    //if settings.customisationPosition == .right
                    Text("// TODO: To Add Preferecens Contents")
                    
                }
                
            }
            .ignoresSafeArea(.all, edges: .all)
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height + 60)
            .background(BackgroundContainer())
            .edgesIgnoringSafeArea(.all)
            .modelContainer(persitence)
            .environmentObject(WindowManager.shared)
            .environmentObject(TaskManager.shared)
            .environmentObject(ProcessManager.shared)
            .environmentObject(OnboardingManager.shared)
            .environmentObject(LicenseManager.shared)
            
        }
            
    }
    
}
