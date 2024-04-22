//
//  GTaskModel.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import SwiftData

@Model
class TaskObject:Equatable,Hashable {
    @Attribute(.unique) var id:UUID
    
    @Relationship(deleteRule: .noAction) var project:TaskProject

    var created:Date
    var refreshed:Date
    var changes:Date?
    var snoozed:Date?
    var state:TaskState
    var order:Int
    var task:String
    var line:Int
    var directory:String
    var language:TaskLanguage
    var importance:TaskImportance

    init(_ state:HelperTaskState, task: String, line: Int, project:TaskProject) {
        self.id = UUID()
        self.project = project
        self.created = Date.now
        self.refreshed = Date.now
        self.changes = nil
        self.snoozed = nil
        self.state = TaskState(from:state)
        self.order = 1
        self.task = task
        self.line = line
        self.directory = project.directory
        self.language = .init(file: project.directory)
        self.importance = .init(string: task)
        
   }
    
}

@Model
class TaskProject:Equatable,Hashable {
    var directory:String
    var name:String
    var added:Date
    var updated:Date?

    init(_ directory: URL) {
        self.name = directory.lastPathComponent
        self.directory = directory.path
        self.added = Date.now
        self.updated = nil
        
    }
    
    static func == (lhs: TaskProject, rhs: TaskProject) -> Bool {
        return lhs.directory == rhs.directory
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(directory)

    }
    
}

enum TaskLanguage:String,Codable {
    case python = "py"
    case swift = "swift"
    case objc = "m"
    case javascript = "js"
    case css = "css"
    case html = "html"
    case php = "php"
    case java = "java"
    case csharp = "cs"
    case c = "c"
    case cpp = "cpp"
    case ruby = "rb"
    case kotlin = "kt"
    case go = "go"
    case rust = "rs"
    case scala = "scala"
    case perl = "pl"
    case shell = "sh"
    case typescript = "ts"
    case unknown

    init(file: String) {
        guard let ext = file.split(separator: ".").last?.lowercased() else {
            self = .unknown
            return
            
        }
        
        guard let type = TaskLanguage(rawValue: String(ext)) else {
            self = .unknown
            return
            
        }
        
        self = type
        
    }
    
}

enum TaskState:String,Codable {
    case todo
    case done
    case note
    case archived
    
    init(from helper:HelperTaskState) {
        switch helper {
            case .done:self = .done
            case .note:self = .note
            default:self = .todo

        }
        
    }
    
    var title:String {
        switch self {
            case .todo : return "TODO"
            case .done : return "DONE"
            case .note : return "NOTE"
            case .archived : return "ARCHIVED"

        }
        
    }
    
    var complete:Bool {
        switch self {
            case .done : return true
            case .archived : return true
            default : return false
            
        }
        
    }
    
    var revealed:Bool {
        switch self {
            case .archived : return false
            default : return true
            
        }
        
    }
    
}

enum TaskImportance:Int,Comparable,Codable {
    static func < (lhs: TaskImportance, rhs: TaskImportance) -> Bool {
        return lhs.rawValue > rhs.rawValue
        
    }
    
    case critical = 3
    case urgent = 2
    case high = 1
    case low = 0
    
    init(string:String) {
        var count:Int = 0
        for character in string.reversed() {
            switch character {
                case "!" : count += 1
                default : break;
                
            }
            
        }
        
        switch count {
            case 0 : self = .low
            case 1 : self = .high
            case 2 : self = .urgent
            default : self = .critical
            
        }
        
    }
    
}
