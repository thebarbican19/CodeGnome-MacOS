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
    @Published var files:[TaskFile]?
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
                
            }
            
        }.store(in: &updates)
        
        $notification.delay(for: 6, scheduler: RunLoop.main).removeDuplicates().sink { item in
            if item != nil {
//                self.notification = nil
                
            }
            
        }.store(in: &updates)
        
        _ = self.taskList()
        
    }
    
    public func taskCreate(_ type:HelperTaskState, task:String, line:Int, directory:String, file:TaskFile, project:TaskProject, total:Int) {
        let context = PersistenceManager.context
        let total = tasks?.filter({ $0.state == TaskState(from: type) }).count
        
        var modified = false

        print("Attenpting to Store '\(task)'")
        if task.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression).isEmpty == false {
            do {
                if let existing = self.taskMatch(task, directory: directory) {
                    let state = TaskState(from: type)
                    let importance = TaskImportance.init(string: task)
                    let title = task.replacingOccurrences(of: "!+$", with: "", options: .regularExpression)

                    if existing.line != line {
                        existing.line = line
                        existing.file.changes = Date.now
                        existing.changes = Date.now

                        modified = true
                        
                    }
                    
                    if existing.task != title {
                        existing.task = title
                        existing.file.changes = Date.now
                        existing.changes = Date.now

                        modified = true

                    }
                    
                    if existing.state != state {
                        existing.changes = Date.now
                        existing.state = TaskState(from: type)
                        existing.file.changes = Date.now

                        modified = true

                        self.taskNotification(.state, task: existing)
                        
                    }
                    
                    if existing.importance != importance {
                        existing.changes = Date.now
                        existing.importance = importance
                        existing.file.changes = Date.now

                        modified = true

                        self.taskNotification(.state, task: existing)

                    }
                    
                    print("\(modified ? "Updateing" : "Not Updating") Task '\(existing.task)'")
                
                }
                else {
                    let task = TaskObject.init(type, task: task, directory: directory, line: line, project: project, file: file, total: total, comments: nil)
                    modified = true
                    file.addTask(task)
                    context.insert(task)
                    
                    self.taskNotification(.new, task: task)
                    print("Storing New Task '\(task.task)'")

                }
                
                if modified == true {
                    try PersistenceManager.save(context: context)

                }
                
            }
            catch {
                print("Save Error", error)
                
            }
            
        }
        
    }
    
    public func taskUpdateFromDirectory(_ directory:String, state:TaskState) {
        guard self.files?.first(where: { $0.directory == directory }) != nil else {
            return
            
        }
        
        guard let tasks = self.tasks?.filter({ $0.directory == directory && $0.state != state }) else {
            return
            
        }
        
        do {
            let context = PersistenceManager.context

            for task in tasks {
                print("Set '\(task.task)' to \(state.rawValue)")
                task.line = 0
                task.state = state
                
            }
            
            try PersistenceManager.save(context: context)

        }
        catch {
            
        }

    }
    
    private func taskExpire() {
        let fetch = FetchDescriptor<TaskObject>()

        do {
            var modifyed:Bool = false

            let context = PersistenceManager.context
            let tasks = try context.fetch(fetch)
            
            for item in tasks.filter({ $0.state.complete == false }) {
                let difference = item.file.changes.timeIntervalSince(item.changes)

                if difference > 1 && item.state.complete == false {
                    switch SettingsManager.shared.enabledArchive {
                        case true : item.state = TaskState.archived
                        case false : item.state = TaskState.done
                        
                    }
                    
                    modifyed = true
                    
                }
                                    
            }
            
            if modifyed == true {
                try PersistenceManager.save(context: context)

            }

            
        }
        catch {
            
        }
            
    }
        
    private func taskNotification(_ type:TaskNotificationType, task:TaskObject) {
        if self.notification == nil {
            self.notification = .init(type, task: task)
            // TODO: Finish Task Notification View
            
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
    
    public func taskOpen(_ task:TaskObject, directory:String) {
        var path:String? = nil
        var arguments:[String]? = nil
        
        print("Opening: " ,directory)
        if directory == task.directory {
            if task.file.application == .vscode {
                path = "/usr/local/bin/code"
                arguments = ["-g", "\(task.directory):\(task.line)"]
   
            }
            else if task.file.application == .xcode {
                path = "/usr/bin/xed"
                arguments = ["--line", String(task.line), task.directory]
        
            }
            else if task.file.application == .sublime {
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
            print("Failed to open \(task.file.application?.rawValue ?? ""): \(error)")
            
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
    
    public func taskActive(_ task:TaskObject, active:Bool) {
        do {
            let context = PersistenceManager.context
            let order = (self.tasks?.filter({ $0.active != nil }).count ?? 0) + 1
            
            task.ignore = false
            task.snoozed = nil
            task.active = active ? order : nil
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
            print("Project Not Stored as Projects List is Null")
            return nil
            
        }
        
        guard let root = self.projectFromDirectory(directory: directory) else {
            print("Project Root Not Determined")
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
    
    public func fileList() -> [TaskFile]? {
        let fetch = FetchDescriptor<TaskFile>()
        
        do {
            self.files = try PersistenceManager.context.fetch(fetch)
            
            return self.files
            
        }
        catch {
            print("Could Not Get Project")
            
        }
        
        return nil
        
    }
    
    public func fileStore(directory: String) -> TaskFile? {
        let context = PersistenceManager.context
        let application = ProcessManager.shared.application

        guard let files = self.fileList() else {
            print("File Not Stored as Files List is Null")
            return nil
            
        }
        
        do {
            if let existing = files.first(where: { $0.directory == directory }) {
                return existing
                
            }
            else {
                let project = TaskFile.init(directory: directory, application: application)
                
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
    
}
