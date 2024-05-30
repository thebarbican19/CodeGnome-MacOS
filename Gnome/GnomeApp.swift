//
//  GnomeApp.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import SwiftUI
import KeyboardShortcuts

@main
struct GnomeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let persitence = PersistenceManager.container

    var body: some Scene {
        WindowGroup {
            EmptyView()

        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
        .commands {
            AppMenuBar()
            
        }
        
    }
    
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate, ObservableObject {
    static var shared = AppDelegate()
    
    final func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.filter({ WindowTypes(rawValue: $0.title) == nil}).first {
            window.close()

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {            
            NSApp.activate(ignoringOtherApps: true)

            UserDefaults.setup()

        }
        
        NSApp.appearance = NSAppearance(named: .darkAqua)
        
        KeyboardShortcuts.onKeyUp(for: .shortcutLeft) {
            DispatchQueue.main.async {
                SettingsManager.shared.enabledPinned = false
                SettingsManager.shared.windowPosition = .left
                
                if OnboardingManager.shared.current == .complete {
                    OnboardingManager.shared.onboardingAction(button: .primary)
                    
                }
                
                if WindowManager.shared.animating == false {
                    WindowManager.shared.windowOpen(.main, present: .toggle)

                }
                
            }
            
        }
        
        KeyboardShortcuts.onKeyUp(for: .shortcutRight) {
            DispatchQueue.main.async {
                SettingsManager.shared.enabledPinned = false
                SettingsManager.shared.windowPosition = .right
                
                if OnboardingManager.shared.current == .complete {
                    OnboardingManager.shared.onboardingAction(button: .primary)
                    
                }
                
                if WindowManager.shared.animating == false {
                    WindowManager.shared.windowOpen(.main, present: .toggle)

                }
                
            }

        }
        
        KeyboardShortcuts.onKeyUp(for: .shortcutPin) {
            DispatchQueue.main.async {
                SettingsManager.shared.enabledPinned.toggle()
                
                WindowManager.shared.windowOpen(.main, present: SettingsManager.shared.enabledPinned ? .present : .hide)
                
            }

        }
        
        _ = ProcessManager.shared
        _ = OnboardingManager.shared
        _ = LicenseManager.shared
        
    }
    
    @objc func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        WindowManager.shared.windowOpen(.main, present: .toggle)
            
        return false
        
    }
    
    @objc func applicationStausItemClicked(sender: NSStatusItem?) {
        WindowManager.shared.windowOpen(.main, present: .toggle)
        
    }
    
}

struct AppMenuBar: Commands {
    @StateObject var settings = SettingsManager.shared
    @StateObject var update = UpdateManager.shared
    @StateObject var license = LicenseManager.shared
    @StateObject var process = ProcessManager.shared

    var body: some Commands {
        CommandGroup(replacing: .undoRedo) {
            EmptyView()
            
        }
        
        CommandGroup(replacing: .newItem) {
            EmptyView()
            
        }
        
        CommandGroup(replacing: .appInfo) {
            EmptyView()
            
        }
        
        CommandGroup(after: CommandGroupPlacement.singleWindowList) {
            VStack {
                if SettingsManager.shared.windowPosition == .left {
                    Button("Open from Right") {
                        SettingsManager.shared.windowPosition = .right
                        SettingsManager.shared.enabledPinned = false
                        
                    }
                    .keyboardShortcut("]", modifiers: .option)
                    
                }
                else {
                    Button("Open from Left") {
                        SettingsManager.shared.windowPosition = .left
                        SettingsManager.shared.enabledPinned = false
                        
                    }
                    .keyboardShortcut("[", modifiers: .option)
                    
                }
                
                Divider()
                
                if settings.enabledPinned {
                    Button("Unpin from Screen") {
                        SettingsManager.shared.enabledPinned = false
                        
                    }
                    .keyboardShortcut("p", modifiers: .option)
                    
                }
                else {
                    Button("Pin to Screen") {
                        SettingsManager.shared.enabledPinned = true
                        
                    }
                    .keyboardShortcut("p", modifiers: .option)
                    
                }
                
            }
            
        }
        
        CommandGroup(before: CommandGroupPlacement.appInfo) {
            Button("Preferences") {
                WindowManager.shared.windowOpen(.preferences, present: .present)
                
            }
            .keyboardShortcut("0", modifiers: .option)
            
            Divider()
            
            if update.state == .checking {
                Text("Checking for Updates...")
                
            }
            else {
                Button("Check for Updates") {
                    update.updateCheck(false)
                    
                }
                
            }
            
            if let build = Bundle.env("CFBundleShortVersionString") {
                Text("Version \(build)")
                
            }
            
            Divider()
            
            Menu("License") {
                if license.state.state == .valid {
                    if let license = LicenseManager.licenseKey {
                        Text(license)

                    }
                    
                    if let expiry = license.expiry {
                        Text("Expires: \(expiry.formatted())")

                    }
                    
                    Button("Deactivate Seat") {
                        LicenseManager.shared.licenseRevoke { state in
                            if state == true {
                                LicenseManager.licenseKey = nil
                                
                            }
                            
                        }
                        
                    }
                    
                    Divider()
 
                }
                else {
                    Text(license.state.state.name)

                    Button("Purchase License") {
                        AppLinks.stripe.launch()

                    }
                    
                }
                
                Button("Open License Manager") {
                    WindowManager.shared.windowOpen(.license, present: .present)
                    
                }
                
            }
            
            Divider()
            
            Menu("Debug") {
                VStack {
                    if process.helper != .allowed {
                        Text(process.helper.title)
                        
                    }
                    
                    Button("Install Helper") {
                        process.processInstallHelper()
                        
                    }
                    
                    Divider()
                    
                    Button("Purge Local Data") {
                        UserDefaults.purge()
                        
                        WindowManager.shared.windowOpen(.main, present: .hide)
                        WindowManager.shared.windowOpen(.onboarding, present: .toggle)


                    }
                
                    Divider()
                    
                    Button("Deep Search") {
                        process.processDeepSearch()
                        
                    }
                    
                    Divider()
                    
                    if let build = Bundle.env("CFBundleVersion") {
                        Text("Build #\(build)")
                        
                    }
                    
                    if let version = Bundle.env("CFBundleShortVersionString") {
                        Text("Version \(version)")
                        
                    }
                    
                }
                
            }
            
        }
        
        CommandGroup(after: CommandGroupPlacement.toolbar) {
            VStack {
                if settings.settingsHidden == true {
                    Button("Disable Hidden Section") {
                        SettingsManager.shared.sectionHidden = false
                        
                    }
                    
                }
                else {
                    Button("Enable Hidden Section") {
                        SettingsManager.shared.sectionHidden = true
                        
                    }
                    
                }
                
                if settings.settingsSnoozed == true {
                    Button("Disable Snoozed Section") {
                        SettingsManager.shared.sectionSnoozed = false
                        
                    }
                    
                }
                else {
                    Button("Enable Snoozed Section") {
                        SettingsManager.shared.sectionSnoozed = true
                        
                    }
                    
                }
                
                Divider()

                if settings.settingsArchive == true {
                    Button("Disable Archive on Removal") {
                        SettingsManager.shared.enabledArchive = false
                        
                    }
                    
                }
                else {
                    Button("Enable Archive on Removal") {
                        SettingsManager.shared.enabledArchive = true
                        
                    }
                    
                }
            
                Divider()
                
            }
            
        }
        
    }
    
}
