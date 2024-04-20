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
    
    var created:Date
    var refreshed:Date
    var changes:Date?
    var state:TaskState
    var task:String
    var line:Int
    var directory:String
    var language:TaskLanguage
    var importance:TaskImportance

    init(_ state:HelperTaskState, task: String, line: Int, directory: String) {
        self.id = UUID()
        self.created = Date.now
        self.refreshed = Date.now
        self.changes = nil
        self.state = TaskState(from:state)
        self.task = task
        self.line = line
        self.directory = directory
        self.language = .init(file: directory)
        self.importance = .init(string: task)
        
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
    case fix
    case archived
    
    init(from helper:HelperTaskState) {
        switch helper {
            case .done:self = .done
            case .fix:self = .fix
            default:self = .todo

        }
        
    }
    
    var title:String {
        switch self {
            case .todo : return "TODO"
            case .done : return "DONE"
            case .fix : return "FIX"
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
    
}

enum TaskImportance:String,Codable {
    case critical
    case urgent
    case high
    case low
    
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
