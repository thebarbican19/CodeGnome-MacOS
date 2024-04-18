//
//  GHelperModel.swift
//  com.ovatar.gnome.brain
//
//  Created by Joe Barbour on 4/17/24.
//

import Foundation

@objc enum HelperTaskState:Int {
    case todo
    case done
    
    init?(from tag: String) {
        switch tag.trimmingCharacters(in: .whitespaces).lowercased() {
            case "todo:":self = .todo
            case "done:":self = .done
            default:return nil
            
        }
        
    }
    
    var title:String {
        switch self {
            case .todo : return "TODO"
            case .done : return "DONE"
            
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
    func brainTaskFound(_ type:HelperTaskState, task:String, line:Int, directory:String)
    func brainSetup(_ completion: @escaping (HelperState) -> Void)

}

