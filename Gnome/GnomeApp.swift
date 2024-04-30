//
//  GnomeApp.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import SwiftUI

@main
struct GnomeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let persitence = PersistenceManager.container

    var body: some Scene {
        WindowGroup {
            EmptyView()

        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
        
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
