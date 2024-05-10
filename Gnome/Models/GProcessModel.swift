//
//  GProcessModel.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation
import SwiftUI

enum ProcessPermissionState:String {
    case cancelled
    case error
    case allowed
    case undetermined
    case denied
    case outdated
    case unknown
    
    var title:String {
        switch self {
            case .error : return "Requires Restart"
            case .allowed : return "Enabled"
            case .undetermined : return "Undetermined"
            case .outdated : return "Requires Update"
            default : return "Denied"
            
        }
        
    }
    
    var flag:Bool {
        switch self {
            case .allowed : return true
            case .unknown : return true
            default : return false
            
        }
        
    }
    
}

