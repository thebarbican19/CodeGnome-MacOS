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
        
    }
    
    var body: some View {
        if tasks.filter({ $0.state == type }).isEmpty == false {
            MainHeader(type, expand: $expand, limit: $limit)
            
            if expand == true {
                MainList(type)
                
            }
            
        }
        
    }
    
}

struct MainHeader: View {
    @State var type:TaskState

    @Binding var expand:Bool
    @Binding var limit:Int

    init(_ type: TaskState, expand:Binding<Bool>, limit:Binding<Int>) {
        self._type = State(initialValue: type)
        self._expand = expand
        self._limit = limit

    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(type.title)
            
            Text(expand ? "Hide" : "Reveal").onTapGesture {
                expand.toggle()
                
            }
            
        }
        
    }
    
}

struct MainList: View {
    @State var type:TaskState

    @Query() private var tasks: [TaskObject]

    init(_ type: TaskState) {
        self._type = State(initialValue: type)
       
    }
    
    var body: some View {
        ForEach(tasks.filter({ $0.state == type }).sorted(by: { $0.importance > $1.importance })) { task in
            HStack {
                Text(task.task)

                Text("#\(task.line)")

            }
            
        }
        .padding(.top, 20)
        
    }
    
}




