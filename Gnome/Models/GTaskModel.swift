//
//  GTaskModel.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class TaskObject:Equatable,Hashable {
    @Attribute(.unique) var id:UUID
    
    @Relationship(deleteRule: .noAction) var project:TaskProject
    @Relationship(deleteRule: .noAction) var file:TaskFile

    var created:Date
    var changes:Date
    var snoozed:Date?
    var state:TaskState
    var task:String
    var comments:String?
    var line:Int
    var directory:String
    var importance:TaskImportance
    var ignore:Bool = false
    var active:Int? = nil

    init(_ state:HelperTaskState, task: String, directory:String, line: Int, project:TaskProject, file:TaskFile, total:Int?, comments:String?) {
        self.id = UUID()
        self.project = project
        self.file = file
        self.created = Date.now
        self.changes = Date.now
        self.snoozed = nil
        self.state = TaskState(from:state)
        self.task = task.replacingOccurrences(of: "!+$", with: "", options: .regularExpression)
        self.comments = comments?.replacingOccurrences(of: "!+$", with: "", options: .regularExpression)
        self.line = line
        self.directory = directory
        self.importance = .init(string: task)
        self.ignore = false
        self.active = nil
        
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

@Model
class TaskFile:Equatable,Hashable {
    @Attribute(.unique) var directory:String
    
    @Relationship(deleteRule: .cascade) var tasks:[TaskObject] = []

    var filename:String
    var language:TaskLanguage
    var application:TaskApplication?
    var added:Date
    var changes:Date
    
    init(directory:String, application:HelperSupportedApplications?) {
        self.directory = directory
        self.filename = directory.filename()
        self.language = .init(file: directory)
        self.application = .init(name: application)
        self.added = Date.now
        self.changes = Date.now

    }
    
    func addTask(_ task: TaskObject) {
        tasks.append(task)
    }

}

enum TaskNotificationType {
    case new
    case importance
    case state
    case app
    
}

struct TaskNotification:Equatable {
    var task:TaskObject?
    var type:TaskNotificationType
    
    init(_ type: TaskNotificationType, task: TaskObject?) {
        self.task = task
        self.type = type
        
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
    case readme = "md"
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
    
    var colour: String {
        switch self {
            case .python: return "#3776AB"  // Python blue
            case .swift: return "#FA7343"  // Swift orange
            case .objc: return "#438EFF"  // Obj-C blue
            case .javascript: return "#F0DB4F"  // JavaScript yellow
            case .css: return "#264DE4"  // CSS blue
            case .html: return "#E34F26"  // HTML orange
            case .php: return "#4F5D95"  // PHP purple
            case .java: return "#5382A1"  // Java blue-grey
            case .csharp: return "#178600"  // C# green
            case .c: return "#A8B9CC"  // C blue
            case .cpp: return "#004482"  // C++ blue
            case .ruby: return "#D91404"  // Ruby red
            case .kotlin: return "#7F52FF"  // Kotlin purple
            case .go: return "#29BEB0"  // Go cyan
            case .rust: return "#DEA584"  // Rust orange-brown
            case .scala: return "#DC322F"  // Scala red
            case .perl: return "#0298C3"  // Perl blue
            case .shell: return "#89E051"  // Shell green
            case .typescript: return "#3178C6"  // TypeScript blue
            case .readme : return "#3178C6"  // TypeScript blue
            case .unknown: return "#FFFFFF"  // Default white
            
        }
        
    }
    
}

enum TaskState:String,Codable {
    case active
    case todo
    case done
    case hidden
    case note
    case archived
    case snoozed
    
    init(from helper:HelperTaskState) {
        switch helper {
            case .done:self = .done
            case .note:self = .note
            default:self = .todo

        }
        
    }
    
    var title:LocalizedStringKey {
        switch self {
            case .active : return "In-Progress"
            case .todo : return "To-do"
            case .done : return "Completed"
            case .note : return "Notes"
            case .archived : return "Archived"
            case .snoozed : return "Snoozed"
            case .hidden : return "Hidden"

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
    
    var limit:Int {
        switch self {
            case .todo : return 5
            default : return 3
            
        }
        
    }
    
    var dropdown:[AppDropdownType] {
        switch self {
            case .active : [.taskInactive, .taskHide, .divider, .openRoot, .openInline, .divider, .snoozeTomorrow, .snoozeWeek]
            case .todo : [.taskActive, .taskHide, .divider, .openRoot, .openInline, .divider, .snoozeTomorrow, .snoozeWeek]
            case .done : [.taskHide, .divider, .openRoot, .openInline]
            case .hidden : [.taskActive, .taskShow, .divider, .openRoot, .openInline]
            case .archived : [.taskHide, .divider, .openRoot, .openInline]
            case .snoozed : [.taskActive, .snoozeRemove, .divider, .openRoot, .openInline]
            default : [.openRoot, .openInline]
            
        }
        
    }
    
    func filter(_ tasks:[TaskObject]) -> [TaskObject] {
        switch self {
            case .snoozed : tasks.filter({ Date.now < $0.snoozed ?? Date.distantPast }).sorted(by: { $0.snoozed ?? Date.now < $1.snoozed ?? Date.now })
            case .hidden : tasks.filter({ $0.ignore == true }).sorted(by: { $0.changes < $1.changes  })
            case .active : tasks.filter({ $0.active != nil }).sorted(by: { $0.active ?? 0 > $1.active ?? 0 })
            default : tasks.filter({ Date.now > $0.snoozed ?? Date.distantPast && $0.state == self && $0.ignore == false }).sorted(by: { $0.active ?? 0 < $1.active ?? 100 && $0.created > $1.created })
            
        }
        
    }
    
}

enum TaskImportance:Int,Comparable,Codable {
    static func < (lhs: TaskImportance, rhs: TaskImportance) -> Bool {
        return lhs.rawValue > rhs.rawValue
        
    }
    
    case critical = 3 // TODO: Idea, pulsating icon with 'Oh Shit'
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
    
    var title:String {
        switch self {
            case .low : return "Not Important"
            case .high : return "Important"
            case .critical : return "Critical"
            case .urgent : return "Urgent"
            
        }
        
    }
    
}

enum TaskApplication:String,Codable {
    case vscode
    case xcode
    case bbedit
    case sublime
    case textmate
    case brackets
    
    init?(name:HelperSupportedApplications?) {
        switch name {
            case .xcode : self = .xcode
            case .bbedit : self = .bbedit
            case .sublime : self = .sublime
            case .textmate : self = .textmate
            case .brackets : self = .brackets
            default : self = .vscode
            
        }
        
    }
    
}

enum TaskHirachyAction {
    case root
    case host
    
}


