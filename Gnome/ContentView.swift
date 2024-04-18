//
//  ContentView.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var process:ProcessManager

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
            

        }
        .padding()
        
    }
    
}

#Preview {
    ContentView()
}
