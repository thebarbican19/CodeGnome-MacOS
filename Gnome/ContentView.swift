//
//  ContentView.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var process:ProcessManager

    @Query var tasks:[TaskObject]

    var body: some View {
        VStack {
            if process.helper == .undetermined {
                Button("Grant") {
                    ProcessManager.shared.processInstallHelper()
                    
                }
                
            }
            else {
                Text(process.helper.rawValue).onTapGesture {
                    ProcessManager.shared.processInstallHelper()
                    
                }
                
            }
            
            Text(process.message).fontWeight(.bold)
            
            if tasks.isEmpty == true {
                Text("NO TASKS SAVED")

            }
            else {
                ForEach(tasks) { task in
                    HStack {
                        Text(task.state.title)
                        
                        Text(task.task)

                        Text("#\(task.line)")

                        Text(task.importance.rawValue)

                    }
                    
                }
                .padding(.top, 20)
                
            }

        }
        .padding()
        
    }
    
}

#Preview {
    ContentView()
}
