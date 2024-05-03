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
                
                if WindowManager.shared.animating == false {
                    WindowManager.shared.windowOpen(.main, present: .toggle)

                }
                
            }
            
        }
        
        KeyboardShortcuts.onKeyUp(for: .shortcutRight) {
            DispatchQueue.main.async {
                SettingsManager.shared.enabledPinned = false
                SettingsManager.shared.windowPosition = .right

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

    var body: some Commands {
        CommandGroup(replacing: .pasteboard) {
            EmptyView()
            
        }
        
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
                    Button("GeneralActionWindowRightLabel") {
                        SettingsManager.shared.windowPosition = .right
                        SettingsManager.shared.enabledPinned = false
                        
                    }
                    .keyboardShortcut("]", modifiers: .option)
                    
                }
                else {
                    Button("GeneralActionWindowLeftLabel") {
                        SettingsManager.shared.windowPosition = .left
                        SettingsManager.shared.enabledPinned = false
                        
                    }
                    .keyboardShortcut("[", modifiers: .option)
                    
                }
                
                Divider()
                
                if settings.enabledPinned {
                    Button("GeneralActionUnpinLabel") {
                        SettingsManager.shared.enabledPinned = false
                        
                    }
                    .keyboardShortcut("p", modifiers: .option)
                    
                }
                else {
                    Button("GeneralActionPinLabel") {
                        SettingsManager.shared.enabledPinned = true
                        
                    }
                    .keyboardShortcut("p", modifiers: .option)
                    
                }
                
            }
            
        }
        
        CommandGroup(before: CommandGroupPlacement.appInfo) {
            Button("SettingsMenuTitle") {
                WindowManager.shared.windowOpen(.preferences, present: .present)
                
            }
            .keyboardShortcut("0", modifiers: .option)
            
            Divider()
            
            if update.state == .checking {
                Text("Checking for Updates...")
                
            }
            else {
                Button("Check for Updates") {
                    UpdateManager.shared.updateCheck(false)
                    
                }
                
            }
            
            if let build = Bundle.env("CFBundleShortVersionString") {
                Text("Version \(build)")
                
            }
            
            Divider()
            
            Menu("SettingsMenuLicenseLabel") {
                Text("LICENSE")

                Button("LicenseActionPurchaseLabel") {
//                    WindowManager.shared.windowOpenWebsite(.custom, view: .preferences, redirect:URL.retrieve(.purchase))

                }
                
            }
            
            Divider()
            
            Menu("GeneralActionDebugLabel") {
                VStack {
                    Button("GeneralActionInteraceInstallLabel") {
                        ProcessManager.shared.processInstallHelper()
                        
                    }
                    
                    Button("Purge") {
                        UserDefaults.purge()
                        
                    }
                    
                    Button("Deep Search") {
                        ProcessManager.shared.processDeepSearch()
                        
                    }
                    
                    Divider()

                    if let build = Bundle.env("CFBundleVersion") {
                        Text("GeneralSummaryBuildLabel \(build)")
                        
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
