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
            
            ButtonPrimary("Validate") {
                manager.onboardingAction(button: .primary)

            }
            .padding(10)
            
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
                    
                    VStack {
                        switch onboarding.current {
                            case .intro : EmptyView()
                            case .complete : AnimationShortcutView()
                            case nil : AnimationShortcutView()
                            default : OnboardingDisplay()
                            
                        }
                        
                    }
                    .frame(width: 400, height: 180)
                    .offset(y:6)

                    Spacer()
                    
                    VStack(spacing:14) {
                        Text(onboarding.title)
                            .foregroundColor(Color("TileTitle"))
                            .font(.custom("Inter", size: 25))
                            .fontWeight(.semibold)
                            .kerning(-0.4)
                        
                        Text(onboarding.subtitle)
                            .foregroundColor(Color("TileSubtitle"))
                            .font(.custom("Inter", size: 14))
                            .kerning(-0.3)
                            .fontWeight(.regular)
                            .opacity(0.8)
                            .lineSpacing(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                                                
                    }
                    .padding(.horizontal, 46)
                    .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    if let primary = onboarding.primary {
                        ButtonPrimary(primary) {
                            onboarding.onboardingAction(button: .primary)
                            
                        }
                        .padding(10)
                        
                    }
                    
                }
                
            }
            .animation(Animation.smooth, value: onboarding.title)
            .offset(y:6)

            HStack {
                if let tertiary = onboarding.tertiary {
                    ButtonSecondary(tertiary) {
                        onboarding.onboardingAction(button: .tertiary)
                        
                    }
                    
                }
                
                Spacer()
                
                if let secondary = onboarding.secondary {
                    ButtonSecondary(secondary) {
                        onboarding.onboardingAction(button: .secondary)
                        
                    }
                                        
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
            .background(
                ZStack {
                    WindowViewBlur()
                    
                    BackgroundContainer()

                }
                
            )
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
