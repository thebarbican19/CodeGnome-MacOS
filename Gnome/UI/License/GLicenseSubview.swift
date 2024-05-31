//
//  GLicenseSubview.swift
//  Gnome
//
//  Created by Joe Barbour on 5/29/24.
//

import SwiftUI

struct LicenseActions: View {
    @EnvironmentObject var license:LicenseManager
    
    @State var type:AppButtonType = .standard
    
    @Binding var input:String

    var body: some View {
        HStack {
            if license.state.state == .valid {
                ButtonSecondary(.init(self.type , value:  self.type == .processing ? "Deactivating..." : "Deactivate Device")) {
                    LicenseManager.shared.licenseRevoke()
                    
                    self.input = ""
                    self.type = .processing
                    
                }
                                
            }
            else {
                ButtonPrimary(.init(self.type , value: self.type == .processing ? "Validating..." : "Validate")) {
                    LicenseManager.licenseKey = input
                    LicenseManager.shared.licenseValidate(true)
                    
                    self.type = .processing
                    
                }
                
            }
            
        }
        .padding(10)
        .onChange(of: license.state.state, { oldValue, newValue in
            if oldValue == .updating && newValue != .updating {
                self.type = .standard

            }
            
        })
        
    }
    
}

struct LicenseEntry: View {
    @EnvironmentObject var license:LicenseManager

    @State var input:String
    @State var window:WindowTypes
    
    init(_ window: WindowTypes, input:String) {
        self._input = State(initialValue: input)
        self._window = State(initialValue: window)
        
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                if let error = license.error {
                    Text(error.description)
                        .foregroundStyle(error.colour)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(error.colour.opacity(0.12))
                                .stroke(error.colour.opacity(0.9), lineWidth: 1.2)
                            
                        )
                        .padding(.bottom, 10)

                }
                
                Text(window == .license ? "License Manager" : "Enter your License")
                    .foregroundColor(Color("TileTitle"))
                    .font(.custom("Inter", size: 25))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .kerning(-0.4)
                            
                TextField("Your License Key", text: $input)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .font(.custom("Inter", size: 12))
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .kerning(0.8)
                    .background(TileBackground(animate: false))
                    .paste(text: $input) { _ in
                        LicenseManager.licenseKey = input
                        LicenseManager.shared.licenseValidate(true)
                        
                    } updated: { value in
                        LicenseManager.licenseKey = value

                    }
            
                
            }
          
            Spacer()
          
            LicenseActions(input: $input)
            
        }
        .onChange(of: license.error) { oldValue, newValue in
            
        }
        
    }
    
}

struct LicenseDetails: View {
    @EnvironmentObject var license:LicenseManager

    var body: some View {
        HStack(spacing: 16) {
            ButtonSecondary(.init(.standard, value: "Purchase License")) {
                AppLinks.stripe.launch()
                
            }
            
            Spacer()
            
            if license.state.type == .trial {
                if let expiry = license.details?.expiry {
                    if expiry > Date() {
                        Text("Trial Expires on \(expiry.display()) (\(expiry.days) days)")
                        
                    }
                    else {
                        Text("Trial Expired on \(expiry.display())")

                    }

                }
                                
            }
            else {
                if let expiry = license.details?.expiry {
                    if expiry > Date() {
                        Text("\(expiry.display()) (\(expiry.days) days)")

                    }
                    else {
                        Text("Expired on \(expiry.display())")
                        
                    }
                    
                }
                
            }
            
            Spacer()

            ButtonSecondary(.init(.standard, value: "Need Help?")) {
                AppLinks.github.launch()
                
            }
            
                        
        } 
        .foregroundStyle(Color("TileBorderShine"))
        .font(.system(size: 12, weight: .semibold))
        .padding(40)
        
    }
    
}

struct LicenseContainer: View {
    @EnvironmentObject var onboarding:OnboardingManager
    @EnvironmentObject var license:LicenseManager
    
    @State var geo:GeometryProxy
    
    var body: some View {
        VStack {
            LicenseEntry(.license, input:LicenseManager.licenseKey ?? "")
            
            LicenseDetails()
            
        }
        .overlay(
            ZStack {
                if let usage = license.details?.usage {
                    Text("\(usage.used)/\(usage.total) Devices Used")
                        .foregroundStyle(Color("TileBorderShine"))
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)

                }
                else {
                    EmptyView()
                    
                }
                
            }, alignment: .topTrailing
            
        )
        .offset(y:6)
        
    }
}

struct LicenseController: View {
    let persitence = PersistenceManager.container

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LicenseContainer(geo: geo)
                
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
            .environmentObject(OnboardingManager.shared)
            .environmentObject(LicenseManager.shared)
            
        }
        
    }
    
    
}


