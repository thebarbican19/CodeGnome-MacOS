//
//  OTaskManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/18/24.
//

import Foundation
import SwiftData

@Model
class TaskObject:Equatable,Hashable {
    @Attribute(.unique) var id:UUID
    
    var created:Date
    var updated:Date
    var task:String
    var line:Int
    var directory:String
    var language:TaskLanguage

    init(task: String, line: Int, directory: String, language: String) {
        self.id = UUID()
        self.created = Date()
        self.updated = Date()
        self.task = task
        self.line = line
        self.directory = directory
        self.language = .init(file: directory)
        
   }
   
   static func == (lhs: TaskObject, rhs: TaskObject) -> Bool {
       return lhs.id == rhs.id
   }
   
   func hash(into hasher: inout Hasher) {
       hasher.combine(id)
   }
    
}

enum TaskLanguage:String {
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

enum TaskState {
    case todo
    case done
    
    init?(_ helper:HelperTaskState) {
        switch helper {
            case .todo:self = .todo
            case .done:self = .done
            default:return nil

        }
        
    }
    
}

class TaskManager {
    static var shared = TaskManager()

    public func taskChecker(_ type:HelperTaskState, task:String, line:Int, directory:String) {
        
    }
    
}
