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
            guard let directory = PersistenceManager.shared.hosted(file: "PersistantDB") else {
                fatalError("Could not create ModelDirectory")

            }
            
            let configurations = ModelConfiguration(url:directory)
            let schema = Schema([TaskObject.self])
            let container = try ModelContainer(for: schema, configurations: configurations)
            
            print("Persistant File: " ,directory)
            
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
            if let _ = model as? TaskManager {
                TaskManager.shared.tasks = TaskManager.shared.taskList()
                
            }
//            else if let _ = model as? MessageObject {
//                MessageManager.shared.messages = MessageManager.shared.messageList(nil)
//                
//            }
            
        }
        
    }
    
    func hosted(file:String?) -> URL? {
        guard let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
            
        }
        
        let directory = support.appendingPathComponent("Gnome")
        
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                
            }
            catch {
                print("Could not create directory: \(error)")
                return nil
                
            }
            
        }
        
        if let file = file {
            return directory.appending(path: file)

        }
        
        return directory
        
    }

    
}
