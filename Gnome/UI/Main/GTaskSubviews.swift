//
//  GTaskSubviews.swift
//  Gnome
//
//  Created by Joe Barbour on 4/22/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct TaskDropDelegate: DropDelegate {
    let item: TaskObject
    
    @State var items: [TaskObject]
    @Binding var dragging: TaskObject?

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [UTType.text])
        
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let source = items.firstIndex(where: { $0 == self.dragging }) else {
            return false
            
        }
        
        guard let targetIndex = items.firstIndex(of: item) else {
           return false
            
        }
               
           // Perform actual item move
       let movingItem = items.remove(at: source)
       items.insert(movingItem, at: targetIndex)
       
       // Update orders based on new positions
       for index in items {
           //items[index].order = index
           print("\n\nitems" ,index.task)

       }
               // Clear the hovered item
        self.dragging = nil
               return true
        
    }
    
    func dropEntered(info: DropInfo) {
        dragging = item
        
    }

    func dropExited(info: DropInfo) {
        dragging = nil
        
    }
    
}

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
            TaskHirachy(item)
            
            Text(item.task)
                .foregroundColor(Color("TileTitle"))
                .lineLimit(3)
                .font(.system(size: 16, weight: .bold))
                .kerning(-0.4)

            Spacer().frame(height: 10)
            
            //TaskTags(item)
            
            TaskDetails(item, section: section)
            
            // TODO: Cell Layout UI
            
        }
        .padding(18)
        .overlay(
            TaskOverlayContainer(item, section: section).opacity(hover ? 1.0 : 0.0), alignment: .topTrailing

        )
        .background(TileBackground(animate: false))
        .hover(cursor: NSCursor.pointingHand, value: { state in
            if hover == true {
                withAnimation(Animation.easeOut(duration: 0.2)) {
                    self.hover = state

                }
                
            }
            else {
                withAnimation(Animation.easeIn(duration: 0.6)) {
                    self.hover = state
                    
                }
                
            }
            
        })
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

            }
            
            if item.line > 0 {
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
            
            if item.file.language != .unknown {
                Text(item.file.language.rawValue)
                
            }
            
            // TODO: Tags View LayoutUI!
            
        }
        .padding(5)
        .background(Color.gray)
        
    }
    
}

struct TaskDetails: View {
    @State var item:TaskObject
    @State var section:TaskState

    init(_ item: TaskObject, section:TaskState) {
        self._item = State(initialValue: item)
        self._section = State(initialValue: section)

    }
    
    var body: some View {
        HStack {
            HStack {
                if let snoozed = item.snoozed {
                    if snoozed > Date() {
                        Text("Snoozed Until: \(snoozed.formatted())")
                        
                    }
                    
                }
                else if item.active != nil && section != .active {
                    Text("In Progress")
                    
                }
                
            }
            
            Spacer()
            
            HStack {
                Text(item.created.display())
                
            }

        }
        .foregroundStyle(Color("TileBorderShine"))
        .font(.system(size: 10, weight: .semibold))
        
    }
    
}
