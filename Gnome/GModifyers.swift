//
//  GModifyers.swift
//  Gnome
//
//  Created by Joe Barbour on 4/22/24.
//

import Foundation
import SwiftUI

struct ViewBorder: ViewModifier {
    @Binding var animate: Bool

    @State var radius:Double
    @State var rotate:Double = 0.0

    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(.clear)
                        .stroke(Color("TileBorder"), lineWidth: 0.8)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(.clear)
                        .strokeBorder(
                            AngularGradient(gradient: Gradient(colors: [Color("TileBorder"), Color("TileBorder"), Color("TileBorder"), Color("TileBorderShine"),Color("TileBorder"), Color("TileBorder"), Color("TileBorder")]),
                                            center: .center,
                                            startAngle: .degrees(rotate), endAngle: .degrees(rotate + 360)),lineWidth: 0.8
                            
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(animate ? 1.0 : 0.0)
                    
    
                }
                
            }

        )
        .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: rotate)
        .animation(Animation.linear(duration: 0.3), value: animate)
        .onAppear {
            rotate = 360
            
        }
        
    }

}

struct ViewModifyerHover: ViewModifier {
    @State var cursor:NSCursor = NSCursor.pointingHand
    
    let value: (Bool) -> Void

    func body(content: Content) -> some View {
        content.onHover(perform: { hover in
            switch hover {
                case true : cursor.push()
                default : cursor.pop()
                // FIX: Fix Cursor Hover State
                
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
        content.overlay(
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
                let menuItem = NSMenuItem(title: "\(button.label(task))", action: #selector(menuItemClicked(_:)), keyEquivalent: "")
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
            // TODO: Position Menu from Top to Bottom instead of Center
            
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

struct ViewMask: ViewModifier {
    @State var positions:Array<AppMaskPosition>
    @State var padding:CGFloat

    func body(content: Content) -> some View {
        content.mask(
            GeometryReader { geo in
                VStack(spacing:0) {
                    LinearGradient(gradient: Gradient(colors: [
                        .black.opacity(self.positions.contains(.top) ? 0 : 1),
                        .black.opacity(1),
                    ]), startPoint: .top, endPoint: .bottom).frame(height: padding)
                    
                    if geo.size.height > padding {
                        Rectangle().fill(.black).frame(height:geo.size.height - (padding * 2))
                        
                    }
                    
                    LinearGradient(gradient: Gradient(colors: [
                        .black.opacity(1),
                        .black.opacity(self.positions.contains(.bottom) ? 0 : 1),
                    ]), startPoint: .top, endPoint: .bottom).frame(height: padding)
                    
                }
                
            }
            
        )
        
    }
    
}

extension View {
    func hover(cursor:NSCursor = NSCursor.pointingHand, value: @escaping (Bool) -> Void = { _ in }) -> some View {
        self.modifier(ViewModifyerHover(cursor:cursor, value: value))
        
    }
    
    func dropdown(_ buttons: [AppDropdownType], triggers:[AppDropdownActionType] = [.left, .right], task:TaskObject?, callback: @escaping ((AppDropdownType) -> Void)) -> some View {
        self.modifier(ComponentMenuModifier(task: task, buttons: buttons, callback: callback, triggers: triggers))
        
    }
    
    func border(_ animate: Binding<Bool>, radius:Double) -> some View {
        self.modifier(ViewBorder(animate: animate, radius: radius))
        
    }
    
    func fade(_ position:Array<AppMaskPosition> = [.top, .bottom], padding:CGFloat = 10) -> some View {
        self.modifier(ViewMask(positions: position, padding: padding))

    }
    
}
