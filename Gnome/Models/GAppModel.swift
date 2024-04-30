//
//  GAppModel.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import Cocoa

public enum AppSoundEffects:String {
    case reveal = "reveal"
    case complete = "complete"
    case added = "added"

    public func play(_ force:Bool = false) {
        if SettingsManager.shared.enabledSoundEffects == true || force == true {
            NSSound(named: self.rawValue)?.play()

        }
                
    }
        
}

enum AppDefaultsKeys: String {
    case userEmail = "g_user_email"
    case userInstalled = "g_user_installed"
        
    case enabledAnalytics = "g_settings_analytics"
    case enabledLogin = "g_settings_login"
    case enabledSoundEffects = "g_settings_sfx"
    case enabledArchive = "g_settings_archive"
    case enabledPinned = "g_settings_pinned"
    
    case windowPosition = "g_settings_position"
    case windowTheme = "g_settings_theme"
    case windowLastInteraction = "g_settings_interaction"

    case onboardingStep = "g_onboarding_step"
    case onboardingComplete = "g_onboarding_updated"

    case licenseTrial = "g_license_trial"
    case licenseKey = "g_license_key"

    var purgable:Bool {
        switch self {
            case .userInstalled : return false
            case .userEmail : return false
            default : return true

        }
        
    }
    
}
