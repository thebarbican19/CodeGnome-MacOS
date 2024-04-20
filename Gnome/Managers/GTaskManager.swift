//
//  OTaskManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/18/24.
//

import Foundation
import SwiftData
import Combine

class TaskManager {
    static var shared = TaskManager()

    @Published var tasks:[TaskObject]?
    
    private var updates = Set<AnyCancellable>()

    init() {
        $tasks.removeDuplicates().sink() { _ in
            self.taskExpire()
            
        }.store(in: &updates)
        // ##TODO: If tasks are updated functionality to be complete
        
    }
    
    public func taskCreate(_ type:HelperTaskState, task:String, line:Int, directory:String, total:Int) {
        let context = PersistenceManager.context
        
        if task.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression).isEmpty == false {
            do {
                if let existing = self.taskMatch(task, directory: directory) {
                    let state = TaskState(from: type)
                    let importance = TaskImportance.init(string: task)

                    if existing.state != state {
                        existing.changes = Date.now
                        existing.state = TaskState(from: type)

                        if state == .done {
                            AppSoundEffects.complete.play()
                            
                        }
                        
                    }
                    
                    if existing.importance != importance {
                        existing.changes = Date.now
                        existing.importance = importance

                    }
                    
                    existing.refreshed = Date.now
                    existing.line = line
                    existing.task = task
                    
                }
                else {
                    let task = TaskObject.init(type, task: task, line: line, directory:directory)
                    context.insert(task)
                    
                    AppSoundEffects.added.play()
         
                    print("Storing New Task: \(task)")
                    
                }
                
                try PersistenceManager.save(context: context)
                
            }
            catch {
                print("Save Error", error)
                
            }
            
        }
        
    }
    
    public func taskList(_ directory:String? = nil) -> [TaskObject]? {
        let fetch = FetchDescriptor<TaskObject>()
        
        do {
            self.tasks = try PersistenceManager.context.fetch(fetch)
            
            if let directory = directory {
                return self.tasks?.filter({ $0.directory == directory })
                
            }
            
            return self.tasks
            
        }
        catch {
            print("Could Not Get Tasks")
            
        }
        
        return nil
        
    }
    
    public func taskMatch(_ task:String, directory:String? = nil) -> TaskObject? {
        guard let tasks = self.taskList(directory) else {
            return nil
            
        }
        
        return tasks.first(where: { $0.task.levenshteinDistance(with: task) <= 20 })
                
    }
    
    private func taskExpire() {
        let fetch = FetchDescriptor<TaskObject>()

        do {
            let context = PersistenceManager.context
            let tasks = try context.fetch(fetch)
            let sorted = tasks.sorted(by: { $0.refreshed > $1.refreshed && $0.state.complete != true })

            if let newest = sorted.first {
                for element in sorted.dropFirst() {
                    let difference = newest.refreshed.timeIntervalSince(element.refreshed)
                    
                    if SettingsManager.shared.enabledArchive == true {
                        if difference > 5 && element.state != .archived {
                            element.state = .archived
                            element.changes = Date.now
                            
                            print("ARCHIVED" ,element.task)

                            AppSoundEffects.complete.play()

                        }
                        
                    }
                    else {
                        if difference > 5 && element.state != .done {
                            element.state = .done
                            element.changes = Date.now
                            
                            print("DONE" ,element.task)

                            AppSoundEffects.complete.play()

                        }
                        
                    }
                    
                }
                
            }
            
            try PersistenceManager.save(context: context)

        }
        catch {
            
        }
        
    }
    
}