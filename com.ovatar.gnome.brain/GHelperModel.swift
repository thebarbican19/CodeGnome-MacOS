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

@objc enum HelperTaskState:Int {
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
    
}

