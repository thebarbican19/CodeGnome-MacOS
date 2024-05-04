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

    var size:WindowSize {
        switch self {
            case .main : return .init(width: 390, height: CGFloat(NSScreen.main?.frame.height ?? 0.0))
            case .preferences : return .init(width: 400, height: 480)
            case .onboarding: return .init(width: 520, height: 500)
            case .reporter: return .init(width: 920, height: 580)

        }
        
    }
    
    var overlay:Bool {
        switch self {
            case .main:return true
            case .preferences:return false
            case .onboarding:return false
            case .reporter:return false

        }
        
    }
    
    var host:NSView {
        switch self {
            case .main : return NSHostingController(rootView: MainController()).view
            case .preferences : return NSHostingController(rootView: PreferencesController()).view
            case .onboarding : return NSHostingController(rootView: OnboardingController()).view
            case .reporter : return NSHostingController(rootView: ReporterController()).view

        }
        
    }
    
    var title:String {
        switch self {
            case .main:return "Mission Control"
            case .preferences:return "Preferences"
            case .onboarding:return "Onboarding"
            case .reporter:return "Reporter"

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


