//
//  GUpdateModel.swift
//  Gnome
//
//  Created by Joe Barbour on 5/2/24.
//

import Foundation

enum UpdateState {
    case idle
    case checking
    case complete
    case failed
    
}

struct UpdateVersionObject:Codable {
    var formatted:String
    var numerical:Double
    
}

struct UpdateChangeLogObject:Codable {
    var added:Array<String>
    var improved:Array<String>
    var fixed:Array<String>
    
}

struct UpdatePayloadObject {
    var id:String
    var created:Date
    var name:String
    var version:UpdateVersionObject
    var binary:String?
    var cached:Bool?
    var ignore:Bool = false
    
}

struct UpdateChangeObject {
    var version:Float
    var description:String
    
}
