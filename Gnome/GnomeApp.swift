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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ProcessManager.shared)
                .environmentObject(WindowManager.shared)

        }
        
    }
    
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate, ObservableObject {
    static var shared = AppDelegate()
    
    final func applicationDidFinishLaunching(_ notification: Notification) {

    }
    
}
