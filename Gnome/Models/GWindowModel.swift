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

    var size:WindowSize {
        switch self {
            case .main : return .init(width: 490, height: CGFloat(NSScreen.main?.frame.height ?? 0.0))
            case .preferences : return .init(width: 800, height: 480)
            case .onboarding: return .init(width: 920, height: 580)
            default : return .init(width: 800, height: 500)
            
        }
        
    }
    
    var overlay:Bool {
        switch self {
            case .main:return true
            case .preferences:return false
            case .onboarding:return false

        }
        
    }
    
    var host:NSView {
        switch self {
            case .main : return NSHostingController(rootView: NavigationController()).view
            case .preferences : return NSHostingController(rootView: PreferencesController()).view
            case .onboarding : return NSHostingController(rootView: OnboardingController()).view

        }
        
    }
    
    var title:String {
        switch self {
            case .main:return "Mission Control"
            case .preferences:return "Preferences"
            case .onboarding:return "Onboarding"

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

