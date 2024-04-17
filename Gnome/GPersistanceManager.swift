//
//  GPersistanceManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation
import SwiftData

class PersistenceManager:ObservableObject {
    static let shared = PersistenceManager()
        
    static var context: ModelContext {
        return ModelContext(PersistenceManager.container)
        
    }
    
    static var container: ModelContainer = {
        do {
            let configurations = ModelConfiguration()
//            let schema = Schema([AccountObject.self, ErrorObject.self, QueueObject.self, MessageObject.self, FolderObject.self])
            let schema = Schema([])
            let container = try ModelContainer(for: schema, configurations: configurations)
                     
            return container
            
        }
        catch {
            fatalError("Could not create ModelContainer: \(error)")
            
        }
            
    }()
    
    static func save(context:ModelContext) throws {
        do {
            for inserted in context.insertedModelsArray {
                PersistenceManager.shared.changes(inserted)

            }
            
            for changed in context.changedModelsArray {
                PersistenceManager.shared.changes(changed)
                
            }
            
            for deleted in context.deletedModelsArray {
                PersistenceManager.shared.changes(deleted)
                
            }
             
            try context.save()

        }
        catch {
//            if let error = error as? ErrorTypes {
//                ErrorManager.report(error)
//                
//            }
//            
        }
  
    }
    
    private func changes(_ model: any PersistentModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
//            if let _ = model as? AccountObject {
//                AccountManager.shared.accounts = AccountManager.shared.accountList(nil)
//                
//            }
//            else if let _ = model as? MessageObject {
//                MessageManager.shared.messages = MessageManager.shared.messageList(nil)
//                
//            }
            
        }
        
    }
    
}
