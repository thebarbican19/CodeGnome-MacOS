//
//  OTaskManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/18/24.
//

import Foundation
import SwiftData
import Combine
import OSLog

class TaskManager:ObservableObject {
    static var shared = TaskManager()

    @Published var tasks:[TaskObject]?
    @Published var project:[TaskProject]?
    @Published var notification:TaskNotification? = nil

    private var updates = Set<AnyCancellable>()

    init() {
        $tasks.delay(for: 0.1, scheduler: RunLoop.main).removeDuplicates().sink { _ in
            self.taskExpire()
            
        }.store(in: &updates)
        
        $notification.debounce(for: 1.0, scheduler: RunLoop.main).removeDuplicates().sink { item in
            switch item {
                case nil : WindowManager.shared.windowClose(.notification, animate: true)
                default: WindowManager.shared.windowOpen(.notification, present: .present)
                
                // TODO: Test Notification Open!!

            }
            
        }.store(in: &updates)
        
        $notification.delay(for: 6, scheduler: RunLoop.main).removeDuplicates().sink { item in
            if item != nil {
                self.notification = nil
                
            }
            
        }.store(in: &updates)
        
        _ = self.taskList()
        
    }
    
    public func taskCreate(_ type:HelperTaskState, task:String, line:Int, directory:String, project:TaskProject, total:Int) {
        let context = PersistenceManager.context
        let modifyed = self.taskModification(directory)
        let application = ProcessManager.shared.application
        let total = tasks?.filter({ $0.state == TaskState(from: type) }).count

        guard self.taskOwner(directory) == true else {
            print("Task is not owned by user: \(directory)")
            return
            
        }
        
        if task.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression).isEmpty == false {
            do {
                if let existing = self.taskMatch(task, directory: directory) {
                    let state = TaskState(from: type)
                    let importance = TaskImportance.init(string: task)

                    existing.refreshed = Date.now
                    existing.line = line
                    existing.task = task.replacingOccurrences(of: "!+$", with: "", options: .regularExpression)
                    existing.project = project
                    existing.modifyed = modifyed
                    existing.application = .init(name: application)
                    
                    if existing.state != state {
                        existing.changes = Date.now
                        existing.state = TaskState(from: type)

                        self.taskNotification(.state, task: existing)
                        
                    }
                    
                    if existing.importance != importance {
                        existing.changes = Date.now
                        existing.importance = importance

                        self.taskNotification(.state, task: existing)

                    }
                
                    os_log("Updated Task %@" ,existing.task)
                    
                }
                else {
                    let task = TaskObject.init(type, task: task, directory: directory, line: line, project: project, application: application, total: total, comments: nil, modifyed: modifyed)
                    context.insert(task)
                    
                    self.taskNotification(.new, task: task)
                    print("Storing New Task: \(task.task)")
                    os_log("Storing New Task %@" ,task.task)

                }
                
                try PersistenceManager.save(context: context)
                
            }
            catch {
                print("Save Error", error)
                
            }
            
        }
        
    }
    
    private func taskNotification(_ type:TaskNotificationType, task:TaskObject) {
        if self.notification == nil {
            self.notification = .init(type, task: task)
            
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
        
        return tasks.first(where: { $0.task.levenshteinDistance(with: task) <= 20 || task.hasPrefix($0.task) })
                
    }
    
    public func taskOwner(_ directory: String) -> Bool {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: directory)
            if let owner = attributes[.ownerAccountID] as? NSNumber {
                if owner.uint32Value == getuid() {
                    return true
                    
                }
                else {
                    print("File \(directory) is not owned by the current user.")
                    return false
                    
                }
                
            }
            
        }
        catch {
            print("Error retrieving file attributes: \(error)")
            
        }
        
        return false
        
    }
    
    public func taskModification(_ directory: String) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: directory)
            if let _ = attributes[.ownerAccountID] as? NSNumber {
                return attributes[.modificationDate] as? Date
                
            }
            
        }
        catch {
            
        }
        
        return nil
        
    }
    
    public func taskOpen(_ task:TaskObject, directory:String) {
        var path:String? = nil
        var arguments:[String]? = nil
        
        print("Opening: " ,directory)
        if directory == task.directory {
            if task.application == .vscode {
                path = "/usr/local/bin/code"
                arguments = ["-g", "\(task.directory):\(task.line)"]
   
            }
            else if task.application == .xcode {
                path = "/usr/bin/xed"
                arguments = ["--line", String(task.line), task.directory]
        
            }
            else if task.application == .sublime {
                path = "/usr/local/bin/subl"
                arguments = ["\(task.directory):\(task.line)"]
                             
            }
            
        }
        else {
            path = "/usr/bin/open"
            arguments = ["-R", directory]
            
        }
        
        guard let path = path, let arguments = arguments else {
            return
            
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments

        do {
           try process.run()
            
        }
        catch {
            print("Failed to open \(task.application?.rawValue ?? ""): \(error)")
            
        }
    
    }
    
    public func taskIgnore(_ task:TaskObject, hide:Bool) {
        do {
            let context = PersistenceManager.context

            task.ignore = hide
            task.changes = Date.now

            try PersistenceManager.save(context: context)
            
        }
        catch {
            
        }
        
    }
    
    public func taskSnooze(_ task:TaskObject, action:AppDropdownType) {
        var next:Date? = nil
        var components = DateComponents()
        components.hour = 7

        switch action {
            case .snoozeWeek : components.day = +7
            case .snoozeTomorrow : components.weekday = Date().snooze.weekday
            default : break
            
        }
        
        if action != .snoozeRemove {
            next = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)

        }
       
        do {
            let context = PersistenceManager.context

            task.snoozed = next
            task.changes = Date.now
            
            try PersistenceManager.save(context: context)
            
        }
        catch {
            
        }
        
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
