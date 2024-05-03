//
//  GModifyers.swift
//  Gnome
//
//  Created by Joe Barbour on 4/22/24.
//

import Foundation
import SwiftUI

struct ViewModifyerHover: ViewModifier {
    @State var cursor:NSCursor = NSCursor.pointingHand
    
    let value: (Bool) -> Void

    func body(content: Content) -> some View {
        content.onHover(perform: { hover in
            switch hover {
                case true : cursor.push()
                default : cursor.pop()
                
            }
                            
            value(hover)
            
        })

    }
    
}

struct ComponentMenuModifier: ViewModifier {
    var task:TaskObject? = nil
    var buttons: [AppDropdownType]
    var callback: ((AppDropdownType) -> Void)?
    var triggers:[AppDropdownActionType] = [.left]

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                ViewMenuRepresentable(task: task, buttons: buttons, callback: callback, geometry: geometry, triggers: triggers)
                
            }

        )
        
    }
    
}

struct ViewMenuRepresentable: NSViewRepresentable {
    typealias NSViewType = ViewMenu

    var task:TaskObject?
    var buttons: [AppDropdownType]
    var callback: ((AppDropdownType) -> Void)?
    var geometry: GeometryProxy?
    var triggers: [AppDropdownActionType] = [.left]

    func makeNSView(context: Context) -> ViewMenu {
        let view = ViewMenu()
        view.task = self.task
        view.buttons = self.buttons
        view.callback = self.callback
        view.triggers = self.triggers
        view.geometry = self.geometry

        if self.triggers == [.right] {
            view.geometry = nil

        }

        return view
        
    }

    func updateNSView(_ nsView: ViewMenu, context: Context) {
        nsView.buttons = self.buttons
        nsView.callback = self.callback
        nsView.triggers = self.triggers
        nsView.geometry = self.geometry

        if self.triggers == [.right] {
            nsView.geometry = nil

        }
    
    }
    
}

class ViewMenu: NSView {
    var task:TaskObject?
    var buttons: [AppDropdownType] = []
    var callback: ((AppDropdownType) -> Void)?
    var geometry: GeometryProxy?
    var triggers: [AppDropdownActionType] = [.left]

    func showContextMenu() {
        let menu = NSMenu()

        for button in self.buttons {
            if button == .divider {
                menu.addItem(NSMenuItem.separator())

            }
            else {
                let menuItem = NSMenuItem(title: button.label(task), action: #selector(menuItemClicked(_:)), keyEquivalent: "")
                menuItem.target = self
                menuItem.tag = button.rawValue
                menu.addItem(menuItem)
                
            }
            
        }
        
        if let geometry = self.geometry {
            let parentFrame = geometry.frame(in: .local)
            let menuItemHeight: CGFloat = 22  // Assume a standard menu item height
            let menuHeight = menuItemHeight * CGFloat(menu.items.count)
            let menuPositionX = parentFrame.minX
            let menuPositionY = parentFrame.origin.y - parentFrame.height + (menuHeight - 12)
            
            let menuPosition = NSPoint(x: menuPositionX, y: menuPositionY)
            
            menu.popUp(positioning: nil, at: menuPosition, in: self)
            
        }
        else {
            if let event = NSApp.currentEvent {
                let location = self.convert(event.locationInWindow, from: nil)
                menu.popUp(positioning: nil, at: location, in: self)
                
            }
            
        }
        
    }


    @objc func menuItemClicked(_ sender: NSMenuItem) {
        if let action = AppDropdownType(rawValue:sender.tag) {
            self.callback?(action)

        }
        
    }
    
    override func mouseDown(with event: NSEvent) {
        if self.triggers.contains(.left) {
            if event.type == .leftMouseDown {
                showContextMenu()
                
            }
            
        }
        
    }

    override func rightMouseDown(with event: NSEvent) {
        if self.triggers.contains(.right) {
            self.showContextMenu()

        }
        
    }
    
}

extension View {
    func hover(cursor:NSCursor = NSCursor.pointingHand, value: @escaping (Bool) -> Void = { _ in }) -> some View {
        self.modifier(ViewModifyerHover(cursor:cursor, value: value))
        
    }
    
    func dropdown(_ buttons: [AppDropdownType], triggers:[AppDropdownActionType] = [.left, .right], task:TaskObject?, callback: @escaping ((AppDropdownType) -> Void)) -> some View {
        self.modifier(ComponentMenuModifier(task: task, buttons: buttons, callback: callback, triggers: triggers))
        
    }
    
}
