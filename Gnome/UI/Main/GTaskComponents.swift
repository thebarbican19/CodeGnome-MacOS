//
//  GTaskComponents.swift
//  Gnome
//
//  Created by Joe Barbour on 5/10/24.
//

import SwiftUI

struct TaskOverayOptions: View {
    @State var hover:Bool = false
    
    var body: some View {
        Text("...")
            .frame(width: 30, height: 30)
            .background(ButtonSecondaryBackground($hover, radius:10))
            .hover() { state in
                if state == true {
                    withAnimation(Animation.easeOut(duration: 0.2)) {
                        self.hover = state

                    }
                    
                }
                else {
                    withAnimation(Animation.easeIn(duration: 0.6).delay(0.2)) {
                        self.hover = state
                        
                    }
                    
                }
                
            }
        
    }
    
    
}

struct TaskOverlayAdd: View {
    @State var hover:Bool = false
    
    var body: some View {
        Text("+")
            .frame(width: 30, height: 30)
            .background(ButtonPrimaryBackground($hover, radius:10))
            .hover() { state in
                if state == true {
                    withAnimation(Animation.easeOut(duration: 0.2)) {
                        self.hover = state

                    }
                    
                }
                else {
                    withAnimation(Animation.easeIn(duration: 0.6).delay(0.2)) {
                        self.hover = state
                        
                    }
                    
                }
                
            }
        
    }
}

struct TaskOverlayContainer: View {
    @State var item:TaskObject
    @State var section:TaskState
    @State var hover:Bool = false
    
    init(_ item: TaskObject, section:TaskState) {
        self._item = State(initialValue: item)
        self._section = State(initialValue: section)

    }
    
    var body: some View {
        // TODO: Add option and add button icons
        HStack(spacing: 5) {
            if item.active == nil && item.state.complete == false {
                TaskOverlayAdd().onTapGesture {
                    TaskManager.shared.taskActive(item, active: true)
                    
                }
                
            }
            
            TaskOverayOptions().dropdown(section.dropdown, triggers: [.left], task: item, callback: { dropdown in
                switch dropdown {
                    case .taskActive : TaskManager.shared.taskActive(item, active: true)
                    case .taskInactive : TaskManager.shared.taskActive(item, active: false)
                    case .taskShow : TaskManager.shared.taskIgnore(item, hide: false)
                    case .taskHide : TaskManager.shared.taskIgnore(item, hide: true)
                    case .openRoot : TaskManager.shared.taskOpen(item, directory: item.project.directory)
                    case .openInline : TaskManager.shared.taskOpen(item, directory: item.directory)
                    case .snoozeTomorrow : TaskManager.shared.taskSnooze(item, action: .snoozeTomorrow)
                    case .snoozeWeek : TaskManager.shared.taskSnooze(item, action: .snoozeWeek)
                    case .snoozeRemove : TaskManager.shared.taskSnooze(item, action: .snoozeRemove)
                    case .divider : break
                    
                }
                
            })
            
        }
        .padding(14)
        
    }
}
