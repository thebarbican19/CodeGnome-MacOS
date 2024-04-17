//
//  GProcessModel.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation

enum ProcessPermissionState:String {
    case error
    case allowed
    case undetermined
    case denied
    case unknown
    
    var title:String {
        switch self {
//            case .error : return "PermissionsErrorLabel".localise(["pissnugget"])
//            case .allowed : return "PermissionsEnabledLabel".localise()
//            case .undetermined : return "PermissionsUndeterminedLabel".localise()
//            case .denied : return "PermissionsDeniedLabel".localise()
//            case .unknown : return "PermissionsUnknownLabel".localise()
            default : return "TBA"
            
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
