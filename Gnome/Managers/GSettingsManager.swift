//
//  GSettingsManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import LaunchAtLogin
import Cocoa

class SettingsManager {
    static var shared = SettingsManager()

    // DONE: Complete Settings Manager
    // DONE: Setup UserDefaults Extension
    public var enabledArchive:Bool {
        get {
            if let value = UserDefaults.object(.enabledArchive) as? Bool {
                return value
                
            }
            
            return false
        
        }
        
        set {
            UserDefaults.save(.enabledArchive, value: newValue)
            
        }
        
    }
    
    public var enabledSoundEffects:Bool {
        get {
            if let value = UserDefaults.object(.enabledSoundEffects) as? Bool {
                return value
                
            }
            
            return true
        
        }
        
        set {
            if self.enabledSoundEffects == false && newValue == true {
                AppSoundEffects.complete.play(true)
                
            }
            
            UserDefaults.save(.enabledSoundEffects, value: newValue)
            
        }
        
    }
    
    public var enabledPinned:Bool {
        get {
            if let value = UserDefaults.object(.enabledPinned) as? Bool {
                return value
                
            }
            
            return false
                        
        }
        
        set {
            UserDefaults.save(.enabledPinned, value: newValue)
                            
        }
        
    }
    
    public var enabledAutoLaunch:SettingsStateValue {
        get {
            if UserDefaults.object(.enabledLogin) == nil {
                return .undetermined
                
            }
            
            return LaunchAtLogin.isEnabled ? .enabled : .disabled
            
        }
        
        set {
            if self.enabledAutoLaunch != .undetermined {
                LaunchAtLogin.isEnabled = newValue.enabled
                
                UserDefaults.save(.enabledLogin, value: newValue.enabled)
                
            }
                       
        }
                        
    }
    
    public var enabledAnalytics:SettingsStateValue {
        get {
            if let value = UserDefaults.object(.enabledAnalytics) as? Bool {
                switch value {
                    case true : return .enabled
                    case false : return .disabled
                    
                }
                
            }
            
            return .undetermined
    
        }
        
        set {
            UserDefaults.save(.enabledAnalytics, value: newValue.enabled)
            
        }
        
    }
    
    public var windowPosition:SettingsWindowPosition {
        get {
            if let value = UserDefaults.object(.windowPosition) as? Int {
                if let position = SettingsWindowPosition(rawValue:value) {
                    if position == .left {
                        if self.windowDockPosition == .left { return .right
                            
                        }
                        else {
                            return .left
                        }
                        
                    }
                    else {
                        if self.windowDockPosition == .right { return .left
                            
                        }
                        else {
                            return .right
                            
                        }
                        
                    }
                    
                }
                
                if self.windowDockPosition  == .left {
                    return SettingsWindowPosition.right
                    
                }
                else {
                    return SettingsWindowPosition.left
                    
                }
                
            }
            
            return .right
            
        }
        
        set {
            if windowPosition != newValue {
                WindowManager.shared.windowOpen(.main, present: .hide)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                    UserDefaults.save(.windowPosition, value: newValue.rawValue)
                                            
                    WindowManager.shared.windowOpen(.main, present: .present)
                    
                }
                
            }
                        
        }
        
    }

    private var windowDockPosition:SettingsDockPosition {
        #if os(macOS)
            if let main = NSScreen.main {
                if main.visibleFrame.origin.x != 0 {
                    if main.visibleFrame.origin.x > NSScreen.main!.visibleFrame.width {
                        return .right
                        
                    }
                    else { 
                        return .left
                        
                    }
                    
                }
                
            }
            
            return .bottom
        
        #else
            return .unsupported

        #endif

    }

}
