//
//  GSettingsManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import LaunchAtLogin
import Cocoa
import Combine

class SettingsManager:ObservableObject {
    static var shared = SettingsManager()

    @Published var settingsSnoozed:Bool = true
    @Published var settingsHidden:Bool = false
    @Published var settingsPined:Bool = false
    @Published var settingsArchive:Bool = false

    private var updates = Set<AnyCancellable>()
    
    init() {
        UserDefaults.changed.receive(on: DispatchQueue.main).sink { key in
            switch key {
                case .sectionSnoozed : self.settingsSnoozed = self.sectionSnoozed
                case .sectionHidden : self.settingsHidden = self.sectionHidden
                case .enabledPinned : self.settingsPined = self.enabledPinned
                case .enabledArchive : self.settingsArchive = self.enabledArchive
                default : break
                
            }
            
        }.store(in: &updates)

        self.settingsSnoozed = self.sectionSnoozed
        self.settingsHidden = self.sectionHidden
        self.settingsPined = self.enabledPinned
        
    }
    
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
    
    public var enabledDockIcon:Bool {
        get {
            if let boolean = UserDefaults.object(.enabledDockIcon) as? Bool {
              DispatchQueue.main.async {
                  NSApp.setActivationPolicy(boolean ? .regular : .accessory)
                  
              }
              
              return boolean
              
            }
            else {
              DispatchQueue.main.async {
                  NSApp.setActivationPolicy(.regular)
                  
              }
              
              return true
              
            }
              
        }
          
        set {
            if newValue != self.enabledDockIcon {
                UserDefaults.save(.enabledDockIcon, value: newValue)

            }

            DispatchQueue.main.async {
                NSApp.setActivationPolicy(newValue ? .regular : .accessory)
              
            }
                         
        }
        
    }
    
    public var sectionSnoozed:Bool {
        get {
            if let value = UserDefaults.object(.sectionSnoozed) as? Bool {
                return value
                
            }
            
            return true
                        
        }
        
        set {
            UserDefaults.save(.sectionSnoozed, value: newValue)
                            
        }
        
    }
    
    public var sectionHidden:Bool {
        get {
            if let value = UserDefaults.object(.sectionHidden) as? Bool {
                return value
                
            }
            
            return true
                        
        }
        
        set {
            UserDefaults.save(.sectionHidden, value: newValue)
                            
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    UserDefaults.save(.windowPosition, value: newValue.rawValue)
                    
                    WindowManager.shared.windowOpen(.main, present: .hide, animate: false)
                    WindowManager.shared.windowOpen(.main, present: .present, animate: true)

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
