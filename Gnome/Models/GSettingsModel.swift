//
//  GSettingsModel.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation

enum SettingsWindowPosition:Int {
    case right
    case left
    case unsupported

}

enum SettingsDockPosition: Int {
    case bottom = 0
    case left = 1
    case right = 2
    case unsupported = 3
    
}

enum SettingsTheme:Int {
    case system
    case light
    case dark
    
    var string:String {
        switch self {
            case .light : return "light"
            case .dark : return "dark"
            default : return "system"
            
        }
        
    }
    
}

enum SettingsStateValue:String {
    case enabled
    case disabled
    case undetermined
    case restricted
    
    var enabled:Bool {
        switch self {
            case .disabled : return false
            default : return true
            
        }
        
    }
    
    var boolean:Bool {
        switch self {
            case .enabled : return true
            default : return false
            
        }
        
    }
    
    var title:String {
        switch self {
            case .enabled : return "Enabled"
            case .disabled : return "Disabled"
            case .undetermined : return "Not Set"
            case .restricted : return "Restricted"

        }
        
    }
    
}
