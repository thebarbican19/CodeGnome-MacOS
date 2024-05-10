//
//  GMainController.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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
            .padding(12)
            .animation(Animation.easeInOut, value: expand)
            .animation(Animation.easeInOut, value: limit)
            .transition(.slide)
            .background(
                TileSection()
            
            )
           
        }
        
    }
    
}

struct MainHeader: View {
    @State var type:TaskState
    @State var hover:Bool = false

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
                    
                // TODO: Replace with dropdown icon!
                Text(expand ? "Collapse" : "Expand")
                    .foregroundColor(Color("TileSubtitle"))
                    .font(.custom("Inter", size: 11))
                    .kerning(-0.2)
                    .fontWeight(.semibold)
                    .onTapGesture {
                        expand.toggle()
                    
                    }
                
            }
            .foregroundColor(Color("TileTitle"))
            .font(.custom("Inter", size: 13))
            .kerning(-0.2)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                ButtonSecondaryBackground($hover)
                
            )
            .hover { state in
                hover = state
                
            }
            
            Spacer()
                        
            if type.filter(tasks).count > limit {
                HStack {
                    Text("Show All \(type.filter(tasks).count)")
                    
                }
                .foregroundColor(Color("TileSubtitle"))
                .font(.custom("Inter", size: 11))
                .kerning(-0.2)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    ButtonSecondaryBackground(.constant(false))

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
            ForEach(type.filter(tasks).prefix(limit)) { item in
                TaskCell(item, section:type)
                
            }
            
        }
       
    }
    
}



