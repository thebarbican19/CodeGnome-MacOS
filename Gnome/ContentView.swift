//
//  ContentView.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Grant") {
                ProcessManager.shared.processInstallHelper()
                
            }
            
        }
        .padding()
        
    }
    
}

#Preview {
    ContentView()
}
