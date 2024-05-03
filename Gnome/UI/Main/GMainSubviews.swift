//
//  GMainController.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import SwiftUI
import SwiftData

struct MainSection: View {
    @State var type:TaskState
    
    @State private var expand:Bool = true
    @State private var limit:Int = 0

    @Query() private var tasks: [TaskObject]

    init(_ type: TaskState) {
        self._type = State(initialValue: type)
        self._expand = State(initialValue: type.revealed)
        self._limit = State(initialValue: type.limit)

    }
    
    var body: some View {
        if type.filter(tasks).isEmpty == false {
            VStack(alignment:.leading, spacing: 12) {
                MainHeader(type, expand: $expand, limit: $limit)
                
                if expand == true {
                    MainList(type, limit: $limit)
                    
                }
                
            }
            
        }
        else if type == .todo {
            GeometryReader { geo in
                Text("Placeholder")
                
            }
            
        }
        else {
            EmptyView()
            
        }
        
    }
    
}

struct MainHeader: View {
    @State var type:TaskState

    @Binding var expand:Bool
    @Binding var limit:Int

    @Query() private var tasks: [TaskObject]

    init(_ type: TaskState, expand:Binding<Bool>, limit:Binding<Int>) {
        self._type = State(initialValue: type)
        self._expand = expand
        self._limit = limit

    }

    var body: some View {
        HStack {
            HStack(alignment: .center, spacing: 10) {
                Text(type.title)
                
                Text(expand ? "Hide" : "Reveal").onTapGesture {
                    expand.toggle()
                    
                }
                
            }
            .foregroundColor(Color("SectionInnerColour"))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color("SectionBackgroundColour"))
                
            )
            
            Spacer()
            
            if type.filter(tasks).count > limit {
                HStack {
                    Text("Show All")
                    
                }
                .foregroundColor(Color("SectionInnerColour"))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color("SectionBackgroundColour"))
                    
                )
                .onTapGesture {
                    limit = 100
                    
                }

            }
           
        }
        
    }
    
}

struct MainList: View {
    @State var type:TaskState

    @Binding var limit:Int

    @Query() private var tasks: [TaskObject]

    init(_ type: TaskState, limit:Binding<Int>) {
        self._type = State(initialValue: type)
        self._limit = limit
        
    }
    
    var body: some View {
        if type.filter(tasks).isEmpty == false {
            ForEach(type.filter(tasks).prefix(limit)) { task in
                TaskCell(task, section:type)
                // TODO: Add Drag & Drop Repositioning
                
            }
            
        }
       
    }
    
}



