//
//  GNotificationController.swift
//  Gnome
//
//  Created by Joe Barbour on 5/3/24.
//

import SwiftUI

struct NotificationContent: View {
    @EnvironmentObject var manager:TaskManager

    let size:WindowSize = WindowTypes.notification.size
    
    var body: some View {
        if let notification = manager.notification {
            HStack {
                Text(notification.task?.task ?? "")

            }
            .frame(maxWidth: size.width, maxHeight: size.height)
            .background(BackgroundContainer())
            
        }

        // TODO: Test Notification View!
    }
    
}

struct NotificationController: View {
    let persitence = PersistenceManager.container
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                NotificationContent()
                
            }
            .ignoresSafeArea(.all, edges: .all)
            .edgesIgnoringSafeArea(.all)
            .modelContainer(persitence)
            .environmentObject(WindowManager.shared)
            .environmentObject(TaskManager.shared)
            .environmentObject(OnboardingManager.shared)
            
        }
        
    }
    
}

