//
//  GWindowManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation
import Combine
import Cocoa
import SwiftUI

class WindowManager: ObservableObject {
    static var shared = WindowManager()
    
    @Published var active:WindowTypes? = .main
    @Published var disableArea:Bool = true

    private var updates = Set<AnyCancellable>()

    init() {
        UserDefaults.changed.receive(on: DispatchQueue.main).sink { key in
            
        }.store(in: &updates)
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillUpdate(notification:)), name: NSWindow.willCloseNotification, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillUpdate(notification:)), name: NSWindow.didUpdateNotification, object:nil)

        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) { event in
            self.windowEvent()
            
        }
            
    }
        
    @objc private func windowWillUpdate(notification: NSNotification) {
        if let window = notification.object as? NSWindow {
            if let type = WindowTypes(rawValue: window.title) {
                if notification.name == NSWindow.willCloseNotification {
                    if self.active == type {
                        self.active = nil

                    }
        
                }
            
            }

        }
            
    }
    
    public func windowOpen(_ type:WindowTypes, present:WindowPresentMode?, force:Bool = false) {
        var type:WindowTypes = type
        
        if force == false {
            if OnboardingManager.shared.current != .complete && type == .main {
                if type.allowed == false {
                    type = .onboarding
                    
                }
                
            }
            else if OnboardingManager.shared.current == .complete && type == .onboarding {
                type = .main
                
            }
            
        }
        
        if force == false {
            if let window = self.windowExists(type) {
                if type == .onboarding {
                    window.contentView = NSHostingController(rootView: OnboardingController()).view
                    
                }
                else if type == .preferences {
                    window.contentView = NSHostingController(rootView: PreferencesController()).view
                    
                }
                else {
                    window.contentView = type.host
                    
                }
                
                DispatchQueue.main.async {
                    window.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                    
                }
                
                if type == .main {
                    if let present = present {
                        var reveal:Bool?
                        if present == .toggle {
                            if self.windowIsVisible(.main) { 
                                reveal = false
                                
                            }
                            else {
                                reveal = true
                                
                            }
                            
                        }
                        else if present == .hide {
                            reveal = false
                            
                        }
                        else if present == .present {
                            reveal = true
                            
                        }
                        
                        print("reveal")
                        
                        if let show:Bool = reveal {
                            if show {
                                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                                    DispatchQueue.main.async {
                                        if WindowTypes(rawValue: window.title) == .main {
                                            window.animator().alphaValue = 1.0;
                                            window.animator().setFrame(self.windowBounds(false), display: true, animate: true)
                                                                
                                        }
                                        else {
                                            window.animator().alphaValue = 1.0;
                                            
                                        }
                                        
                                        self.active = .main
                                        
                                    }
                                    
                                })
                                
                                window.orderFrontRegardless()
                                
                                NSApp.activate(ignoringOtherApps: true)
                                
                            }
                            else {
                                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                                    context.duration = 0.6
                                    
                                    if WindowTypes(rawValue: window.title) == .main {
                                        window.animator().alphaValue = 0.0;
                                        window.animator().setFrame(self.windowBounds(true), display: true, animate: true)
                                        
                                    }
                                    
                                    
                                }, completionHandler: nil)
                                
                                self.active = nil
                                
                                NSApp.activate(ignoringOtherApps: false)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    public func windowBounds(_ hidden:Bool) -> NSRect {
        let screen = WindowScreenSize()
        let status = NSStatusBar.system.thickness
        let dock = self.windowDockHeight
        let properties = WindowTypes.main.size
        
        var window = NSMakeRect(properties.width, status + dock, properties.width, properties.height - (status + dock))

        if SettingsManager.shared.windowPosition == .right {
            switch hidden {
                case true : window.origin.x = screen.width
                case false : window.origin.x = screen.width - properties.width

            }

        }
        else {
            switch hidden {
                case true : window.origin.x = screen.leading - properties.width
                case false : window.origin.x = screen.leading

            }

        }

        return window
        
    }
    
    public func windowIsVisible(_ type:WindowTypes) -> Bool {
        if let window = self.windowExists(type) {
            if CGFloat(window.alphaValue) > 0.5 {
                return true
                
            }
            
        }
        
        return false
        
    }
    
    private var windowDockSize:CGFloat {
        return NSScreen.main!.visibleFrame.origin.y
            
    }

    private var windowDockHidden:Bool {
        if self.windowDockSize < 25 { return true }
        else { return false }
        
    }
    
    private var windowDockHeight:CGFloat {
        if NSScreen.main!.visibleFrame.origin.x == 0 { return self.windowDockSize }
        else { return 0 }
        
    }
    
    private func windowMain() -> NSWindow? {
        let type: WindowTypes = .main
        let window = NSWindow()
        window.styleMask = [.borderless, .miniaturizable]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.title = type.rawValue
        window.isOpaque = false
        window.isMovableByWindowBackground = false
        window.hasShadow = false
        window.center()
        window.backgroundColor = NSColor.black.withAlphaComponent(0.1)
        window.setFrame(self.windowBounds(false), display: true, animate: false)
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.acceptsMouseMovedEvents = true
        window.level = .statusBar
        window.contentView = NSHostingController(rootView: MainController()).view
        window.alphaValue = 0.0
                
        return window
            
    }
    
    private func windowDefault(_ type:WindowTypes, onboarding:OnboardingSubview? = nil) -> NSWindow? {
        let bounds = WindowScreenSize()
        var window:NSWindow?
        
        window = NSWindow()
        window?.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView, .resizable]
        window?.level = .normal
        window?.contentView?.translatesAutoresizingMaskIntoConstraints = false
        window?.center()
        window?.title = type.rawValue
        window?.collectionBehavior = [.ignoresCycle]
        window?.isMovableByWindowBackground = true
        window?.backgroundColor = .clear
        window?.setFrame(NSRect(x: (bounds.width / 2) - (type.size.width / 2), y: (bounds.height / 2) - (type.size.height / 2), width: type.size.width, height: type.size.height), display: false)
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        window?.toolbarStyle = .unifiedCompact
        window?.isReleasedWhenClosed = false
        window?.alphaValue = 0.0
                     
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.2
            
            window?.animator().alphaValue = 1.0
            
        }, completionHandler: nil)
        
        return window
        
    }

    
    private func windowEvent() {
        DispatchQueue.main.async {
            if let main = self.windowMain() {
                if self.windowIsVisible(.main) {
                    if SettingsManager.shared.enabledPinned == false && self.disableArea == true {
                        if SettingsManager.shared.windowPosition == .right {
                            if NSEvent.mouseLocation.x < (main.frame.minX - 40) {
                                self.windowOpen(.main, present: .hide)
                                
                            }
                        }
                        else {
                            if NSEvent.mouseLocation.x > (main.frame.width + 40) {
                                self.windowOpen(.main, present: .hide)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
       
    private func windowExists(_ type: WindowTypes, onboarding:OnboardingSubview? = nil) -> NSWindow? {
        if let window = NSApplication.shared.windows.first(where: { WindowTypes(rawValue: $0.title) == type }) {
            return window
            
        }
        else {
            switch type {
                case .main : return self.windowMain()
                case .onboarding : return self.windowDefault(type, onboarding: onboarding)
                case .preferences : return self.windowDefault(type)
                case .reporter : return self.windowDefault(type)
                
            }
                        
        }
                        
    }
    
    public func windowClose(_ type:WindowTypes) {
        if let window = NSApplication.shared.windows.filter({$0.title == type.rawValue}).first {
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = 1.0
                
                window.animator().alphaValue = 0.0;

                
            }) {
                window.close()
 
            }
            
        }

    }
    
    
}
