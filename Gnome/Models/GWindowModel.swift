//
//  GWindowModel.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import Cocoa
import AppKit
import SwiftUI

struct WindowScreenSize {
    var top:CGFloat = CGFloat(NSScreen.main?.frame.origin.y ?? 0.0)
    var leading:CGFloat = CGFloat(NSScreen.main?.frame.origin.x ?? 0.0)
    var width:CGFloat = CGFloat(NSScreen.main?.frame.width ?? 0.0)
    var height:CGFloat = CGFloat(NSScreen.main?.frame.height ?? 0.0)
    
}

struct WindowSize {
    var width:CGFloat
    var height:CGFloat
    
}

enum WindowTypes:String,CaseIterable {
    case main = "Main_Window"
    case preferences = "Preferences_Window"
    case onboarding = "Onboarding_Window"
    case reporter = "Reporter_Window"
    case license = "License_Window" // TODO: Add License Window
    case notification = "Notification_Modal"

    var size:WindowSize {
        switch self {
            case .main : return .init(width: 390, height: CGFloat(NSScreen.main?.frame.height ?? 0.0))
            case .preferences : return .init(width: 400, height: 480)
            case .onboarding: return .init(width: 520, height: 540)
            case .license: return .init(width: 570, height: 420)
            case .reporter: return .init(width: 920, height: 580)
            case .notification: return .init(width: 360, height: 60)

        }
        
    }
    
    var overlay:Bool {
        switch self {
            case .main:return true
            case .preferences:return false
            case .onboarding:return false
            case .reporter:return false
            case .license:return false
            case .notification:return true

        }
        
    }
    
    var host:NSView {
        switch self {
            case .main : return NSHostingController(rootView: MainController()).view
            case .preferences : return NSHostingController(rootView: PreferencesController()).view
            case .onboarding : return NSHostingController(rootView: OnboardingController()).view
            case .reporter : return NSHostingController(rootView: ReporterController()).view
            case .license : return NSHostingController(rootView: LicenseController()).view
            case .notification : return NSHostingController(rootView: NotificationController()).view

        }
        
    }
    
    var title:String {
        switch self {
            case .main:return "Mission Control"
            case .preferences:return "Preferences"
            case .onboarding:return "Onboarding"
            case .reporter:return "Reporter"
            case .license:return "License Manager"
            case .notification:return "Notification"

        }
        
    }
    
    var main:Bool {
        switch self {
            case .main : return true
            default : return false
            
        }
        
    }
    
    var allowed:Bool {
        switch self {
            case .preferences : return true
            case .onboarding : return true
            default : return false
            
        }
        
    }
    
}

enum WindowPresentMode {
    case toggle
    case present
    case hide

}

struct WindowViewBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()

        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .underWindowBackground

        return view
        
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        
    }
    
}

struct WindowGradientView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                SettingsManager.shared.windowPosition == .left ? .gray : Color.gray.opacity(0),
                SettingsManager.shared.windowPosition == .left ? Color.gray.opacity(0) : .gray
                
            ]),
            startPoint: .leading,
            endPoint: .trailing
            
        )
        .edgesIgnoringSafeArea(.all)
        
    }
    
}


