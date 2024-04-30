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
        ZStack {
            HStack(spacing: 0) {
                //if settings.customisationPosition == .right
                Text("## TODO: To Add Preferecens Contents")
                
            }
            
        }
        .modelContainer(persitence)
        .environmentObject(WindowManager.shared)
        .environmentObject(TaskManager.shared)
        .environmentObject(ProcessManager.shared)
        .environmentObject(OnboardingManager.shared)
        .environmentObject(LicenseManager.shared)
            
    }
    
}
