//
//  GHelperModel.swift
//  com.ovatar.gnome.brain
//
//  Created by Joe Barbour on 4/17/24.
//

import Foundation

@objc enum HelperSupportedApplications:Int {
    case vscode
    case xcode
    case bbedit
    case sublime
    case textmate
    case brackets
    
    init?(name:String) {
        switch name {
            case "Code" : self = .vscode
            case "Xcode" : self = .xcode
            case "BBEdit" : self = .bbedit
            case "Sublime Text" : self = .sublime
            case "TextMate" : self = .textmate
            case "Brackets" : self = .brackets
            default : return nil
            
        }
        
    }
    
}

@objc(HelperTaskObject)
class HelperTaskObject: NSObject, Codable {
    var tag: HelperTaskState
    var task: String
    var line: Int
    var directory: String
    var total: Int

    init(_ tag: HelperTaskState, task: String, line: Int, directory: String, total: Int) {
        self.tag = tag
        self.task = task
        self.line = line
        self.directory = directory
        self.total = total
        
    }
    
}

extension Array where Element: HelperTaskObject {
    func json() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(self)
        
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "HelperTaskObject", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to encode JSON string."])
            
        }
        
        return json
        
    }
    
    static func decode(_ string: String) throws -> [HelperTaskObject] {
        guard let data = string.data(using: .utf8) else {
           throw NSError(domain: "HelperTaskObjectArray", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to convert string to data."])
        }

        let decoder = JSONDecoder()
        let objects = try decoder.decode([HelperTaskObject].self, from: data)

        return objects
        
    }
    
}

@objc enum HelperTaskState:Int,Codable {
    case todo
    case done
    case note
    case generate
    
    init?(from tag: String) {
        switch tag.trimmingCharacters(in: .whitespaces).lowercased() {
            case "todo":self = .todo
            case "fix":self = .todo
            case "done":self = .done
            case "archive":self = .done
            case "note":self = .note
            case "gendoc":self = .generate
            case "gen":self = .generate
            default:return nil
            
        }
        
    }
    
}

@objc enum HelperState:Int {
    case installed
    case missing
    case error
    
}

@objc(HelperProtocol) protocol HelperProtocol {
    func brainCheckin()
    func brainTaskFound(_ type:HelperTaskState, task:String, line:Int, directory:String, total:Int)
    func brainSetup(_ completion: @escaping (HelperState) -> Void)
    func brainProcess(_ path: String, arguments: [String], whitespace: Bool, completion: @escaping (String?) -> Void)
    func brainSwitchApplication(_ application:HelperSupportedApplications)
    func brainVersion(_ completion: @escaping (String?) -> Void)
    func brainDeepSearch(_ completion: @escaping (String?) -> Void)

}

struct HelperConstants {
    static let mach = "com.ovatar.gnome.brain.mach"
    
}

