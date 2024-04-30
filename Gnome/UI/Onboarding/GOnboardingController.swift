//
//  GOnboardingController.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import SwiftUI

struct OnboardingLicense: View {
    @EnvironmentObject var license:LicenseManager
    @EnvironmentObject var manager:OnboardingManager

    var body: some View {
        VStack {
            Text("License \(license.state.state.rawValue)")
            
            Button("Start") {
                manager.onboardingAction(button: .primary)

            }
            
        }
        
    }
    
}

struct OnboardingTutorial: View {
    @EnvironmentObject var onboarding:OnboardingManager

    var body: some View {
        VStack {
            Text("Import \(onboarding.tutorial.rawValue)")
            
        }
        
    }
    
}

struct OnboardingContainer: View {
    @EnvironmentObject var manager:OnboardingManager

    @State var geo:GeometryProxy

    var body: some View {
        if manager.current == .tutorial {
            OnboardingTutorial()
            
        }
        else if manager.current == .license {
            OnboardingLicense()
            
        }
        else {
            VStack {
                Text("Current: \(manager.current.rawValue)").padding(30)
                // TODO: Finish this View
                Button("Next") {
                    manager.onboardingAction(button: .primary)
                    
                }
                
            }
            
        }

    }
    
}

struct OnboardingController: View {
    let persitence = PersistenceManager.container

    var body: some View {
        GeometryReader { geo in
            ZStack {
                OnboardingContainer(geo: geo)
                
            }
            .ignoresSafeArea(.all, edges: .all)
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height + 60)
            .background(WindowViewBlur())
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
