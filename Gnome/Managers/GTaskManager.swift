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
    @Published var project:[TaskProject]?

    private var updates = Set<AnyCancellable>()

    init() {
        $tasks.removeDuplicates().sink() { _ in
            self.taskExpire()
            
        }.store(in: &updates)
        
    }
    
    public func taskCreate(_ type:HelperTaskState, task:String, line:Int, project:TaskProject, total:Int) {
        let context = PersistenceManager.context
        
        if task.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression).isEmpty == false {
            
            do {
                if let existing = self.taskMatch(task, directory: project.directory) {
                    let state = TaskState(from: type)
                    let importance = TaskImportance.init(string: task)

                    if existing.state != state {
                        existing.changes = Date.now
                        existing.state = TaskState(from: type)

                        if state == .done {
                            AppSoundEffects.complete.play()
                            WindowManager.shared.windowOpen(.main, present: .present)

                        }
                        
                    }
                    
                    if existing.importance != importance {
                        existing.changes = Date.now
                        existing.importance = importance

                    }
                    
                    existing.refreshed = Date.now
                    existing.line = line
                    existing.task = task
                    existing.project = project
                    
                }
                else {
                    let task = TaskObject.init(type, task: task, line: line, project: project)
                    context.insert(task)
                    
                    AppSoundEffects.added.play()
                    WindowManager.shared.windowOpen(.main, present: .present)
                    print("Storing New Task: \(task.task)")

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
                        if difference > 5 && element.state != TaskState.archived {
                            element.state = TaskState.archived
                            element.changes = Date.now
                            
                            print("ARCHIVED" ,element.task)

                            AppSoundEffects.complete.play()

                        }
                        
                    }
                    else {
                        if difference > 5 && element.state != TaskState.done {
                            element.state = TaskState.done
                            element.changes = Date.now
                            
                            print("DONE" ,element.task)

                            AppSoundEffects.complete.play()
                            WindowManager.shared.windowOpen(.main, present: .present)

                        }
                        
                    }
                    
                }
                
            }
            
            try PersistenceManager.save(context: context)

        }
        catch {
            
        }
        
    }
    
    public func projectList() -> [TaskProject]? {
        let fetch = FetchDescriptor<TaskProject>()
        
        do {
            self.project = try PersistenceManager.context.fetch(fetch)
            
            return self.project
            
        }
        catch {
            print("Could Not Get Project")
            
        }
        
        return nil
        
    }
    
    public func projectStore(directory: String) -> TaskProject? {
        let context = PersistenceManager.context

        guard let projects = self.projectList() else {
            return nil
            
        }
        
        guard let root = self.projectFromDirectory(directory: directory) else {
            return nil
            
        }
           
        do {
            if let existing = projects.first(where: { $0.directory == root.path }) {
                if existing.name != root.lastPathComponent {
                    existing.updated = .now
                    existing.name = root.lastPathComponent

                    try PersistenceManager.save(context: context)

                }
                
                return existing
                
            }
            else {
                let project = TaskProject.init(root)
                
                context.insert(project)

                try PersistenceManager.save(context: context)

                return project
                
            }
            
        }
        catch {
            print("Could not save Project")
            
        }
        
       
      
        return nil
        
    }

    public func projectFromDirectory(directory:String) -> URL? {
        var path = URL(fileURLWithPath: directory)
        var output:URL? = nil

        guard FileManager.default.fileExists(atPath: path.path) else {
            print("Provided path is not a directory")
            return nil
            
        }

        while path.pathComponents.count > 1 {
            if let entries = try? FileManager.default.contentsOfDirectory(atPath: path.path) {
                for entry in entries {
                    if entry.hasSuffix(".code-workspace") || entry.hasSuffix(".xcodeproj") || entry.hasSuffix(".git") || entry.hasPrefix("index") {
                        output = path
                        
                    }
                    
                }
                
            }
            
            path.deleteLastPathComponent()
            
        }
        
        return output
        
    }
    
    
}
