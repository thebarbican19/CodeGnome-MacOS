//
//  GTaskSubviews.swift
//  Gnome
//
//  Created by Joe Barbour on 4/22/24.
//

import SwiftUI

struct TaskCell: View {
    @State var item:TaskObject
    @State var hover:Bool = false
    @State var section:TaskState

    init(_ item: TaskObject, section:TaskState) {
        self._item = State(initialValue: item)
        self._section = State(initialValue: section)

    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // TODO: Import Fonts & Import Colours
            // TODO: Options Button to Add with Hide and Open Functionality
            Text("Option:").dropdown(section.dropdown, triggers: [.left], task: item, callback: { dropdown in
                switch dropdown {
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
            
            TaskHirachy(item)
            
            Text(item.task)
                .foregroundColor(Color("TileTitle"))
                .lineLimit(3)

            Spacer().frame(height: 10)
            
            TaskTags(item)
            
            TaskSnoozed(item)
            
        }
        .padding(18)
        .background(TileBackground(animate: false))
        .hover(cursor: NSCursor.pointingHand, value: { state in
            if hover == true {
                withAnimation(Animation.easeOut(duration: 0.2)) {
                    self.hover = state

                }
                
            }
            else {
                withAnimation(Animation.easeIn(duration: 0.6).delay(0.2)) {
                    self.hover = state
                    
                }
                
            }
            
        })
        .onDrag {NSItemProvider(object: item.id.uuidString as NSString)}
        .padding(0)
        
    }
    
}

struct TaskHirachy: View {
    @State var item:TaskObject
    @State var action:TaskHirachyAction? = nil
    
    init(_ item: TaskObject) {
        self._item = State(initialValue: item)
        
    }
    
    var body: some View {
        HStack(alignment: .center) {
            TaskHirachyItem(item, action: .root)
            
            TaskHirachyItem(item, action: .host)

            Spacer()
            
        }
        
    }
    
}

struct TaskHirachyItem: View {
    @State var item:TaskObject
    @State var action:TaskHirachyAction?
    @State var hover:Bool = false

    init(_ item: TaskObject, action:TaskHirachyAction) {
        self._item = State(initialValue: item)
        self._action = State(initialValue: action)
        
    }
    var body: some View {
        HStack() {
            if action == .root {
                Text(item.project.name.lowercased())

            }
            else {
                Text(item.directory.filename().lowercased())

                Text("#\(item.line)")

            }
            
        }
        .foregroundColor(self.hover ? Color("TileBorderShine") : Color("TileSubtitle"))
        .hover() { hover in
            if hover == true {
                withAnimation(Animation.easeOut(duration: 0.2)) {
                    self.hover = hover

                }
                
            }
            else {
                withAnimation(Animation.easeIn(duration: 0.6).delay(0.2)) {
                    self.hover = hover
                    
                }
                
            }
            
        }
        .onTapGesture {
            switch action {
                case .root:TaskManager.shared.taskOpen(item, directory: item.project.directory)
                case .host:TaskManager.shared.taskOpen(item, directory: item.directory)
                case nil:break
                
            }
            
        }
    
        
    }
    
}

struct TaskTags: View {
    @State var item:TaskObject
    
    init(_ item: TaskObject) {
        self._item = State(initialValue: item)
        
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            if item.importance != .low {
                Text(item.importance.title)
                
            }
            
            if item.language != .unknown {
                Text(item.language.rawValue)
                
            }
            
            // TODO: Tags View Layout
            
        }
        .padding(5)
        .background(Color.gray)
        
    }
    
}

struct TaskSnoozed: View {
    @State var item:TaskObject
    
    init(_ item: TaskObject) {
        self._item = State(initialValue: item)
        
    }
    
    var body: some View {
        if let snoozed = item.snoozed {
            if snoozed > Date() {
                Text("Snoozed Until: \(snoozed.formatted())")
                    .foregroundColor(Color.red)
                
            }

        }
        
    }
    
}
