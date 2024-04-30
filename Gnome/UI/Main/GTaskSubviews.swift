//
//  GTaskSubviews.swift
//  Gnome
//
//  Created by Joe Barbour on 4/22/24.
//

import SwiftUI

struct TaskCell: View {
    @State var item:TaskObject
    
    init(_ item: TaskObject) {
        self._item = State(initialValue: item)
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // TODO: Import Fonts & Import Colours
                        
            TaskHirachy(item)
            
            Text(item.task)
                .foregroundColor(Color("TaskTitleColour"))
                .lineLimit(3)

            Spacer().frame(height: 10)
            
            TaskTags(item)
            
        }
        .padding(18)
        .background(
            ZStack() {
                WindowViewBlur()
                    .opacity(0.08)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
                
                RoundedRectangle(cornerRadius: 7.8, style: .continuous)
                    .fill(Color("TaskBackgroundColour"))
                    .padding(4)
                    .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                    
                // TODO: add Gradient Background
                
            }
            
        )
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
        .foregroundColor(self.hover ? Color("TaskHoverColour") : Color("TaskSubtitleColour"))
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
            print("action" ,action)
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
        
    }
    
}
