//
//  OReporterController.swift
//  Gnome
//
//  Created by Joe Barbour on 4/29/24.
//

import Foundation
import SwiftUI

struct ReporterController: View {
    let persitence = PersistenceManager.container

    var body: some View {
        ZStack {
            Text("// TODO: Reporter View")

        }
        .modelContainer(persitence)
        .environmentObject(WindowManager.shared)
        .environmentObject(TaskManager.shared)
        .environmentObject(ProcessManager.shared)
        .environmentObject(OnboardingManager.shared)
        .environmentObject(LicenseManager.shared)
        
    }
    
    
}
