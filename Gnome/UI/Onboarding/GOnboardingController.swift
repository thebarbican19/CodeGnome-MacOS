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
            
            Spacer()
            
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

struct OnboardingDisplay: View {
    var body: some View {
        ZStack {
            TileShadow()
            
            TileBackground(animate: true)
            
            Text("To Be Added")
                .foregroundColor(Color.white)
                .blendMode(.overlay)
                .font(.custom("Inter", size: 12))
                .kerning(-0.3)
                .fontWeight(.regular)
            
        }
        .offset(y:6)
        .frame(width: 320, height: 160)
        
    }
    
}

struct OnboardingContainer: View {
    @EnvironmentObject var onboarding:OnboardingManager
    @EnvironmentObject var license:LicenseManager
    
    @State var geo:GeometryProxy
    
    var body: some View {
        VStack {
            VStack(spacing: 14) {
                
                if onboarding.current == .license {
                    OnboardingLicense()
                    
                }
                else {
                    Spacer()

                    OnboardingDisplay()
                    
                    Spacer()
                    
                    VStack(spacing:18) {
                        Text(onboarding.title)
                            .foregroundColor(Color("TileTitle"))
                            .font(.custom("Inter", size: 25))
                            .fontWeight(.semibold)
                            .kerning(-0.4)
                        
                        Text(onboarding.subtitle)
                            .foregroundColor(Color("TileSubtitle"))
                            .font(.custom("Inter", size: 13))
                            .kerning(-0.3)
                            .fontWeight(.regular)
                            .opacity(0.8)
                            .lineSpacing(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                        
                    }
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    if let primary = onboarding.primary {
                        ButtonPrimary(title:primary) {
                            onboarding.onboardingAction(button: .primary)
                            
                        }
                        .padding(10)
                        
                    }
                    
                }
                
            }
            .offset(y:6)

            HStack {
                if let tertiary = onboarding.tertiary {
                    ButtonSecondary(title:tertiary) {
                        onboarding.onboardingAction(button: .tertiary)
                        
                    }
                    
                }
                
                Spacer()
                
                if let secondary = onboarding.secondary {
                    ButtonSecondary(title:secondary) {
                        onboarding.onboardingAction(button: .secondary)
                        
                    }
                    
                    // TODO: Redesign Primary & Secondary Button Gnome!
                    
                }
                
            }
            .padding(40)
            
        }
        
    }
    
}

struct OnboardingController: View {
    let persitence = PersistenceManager.container
    let size:WindowSize = WindowTypes.onboarding.size

    var body: some View {
        GeometryReader { geo in
            ZStack {
                OnboardingContainer(geo: geo)
                
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

            // FIX: Resize Window Bug
            
        }
        .frame(width: size.width, height: size.height)

        
    }
    
    
}
