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
            ContentView()
                .modelContainer(persitence)
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
