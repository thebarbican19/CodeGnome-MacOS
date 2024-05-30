//
//  GLicenseModel.swift
//  Gnome
//
//  Created by Joe Barbour on 5/29/24.
//

import Foundation
import SwiftUI

struct LicenseResponse:Decodable {
    let status: Int
    let description: String
    let license: LicenseResponseObject

}

struct LicenseResponseObject: Decodable {
    let usage: LicensUsageObject
    let expiry: Date
    let customer: LicenseCustomerObject
    
}

struct LicensUsageObject: Decodable {
    let used: Int
    let total: Int
    
}

struct LicenseCustomerObject: Decodable {
    let id: String
    let email: String
    let name: String
    
}

enum LicenseResponseState:Error {
    case unknown
    case expired // 403
    case valid // 200
    case capacity //429
    case validation
    case invalid // 415
    
    var description: String {
        switch self {
            case .unknown : return "Unknown error occurred."
            case .expired : return "License has expired. (403)"
            case .valid : return "License is valid. (200)"
            case .capacity : return "Capacity limit reached. (429)"
            case .validation : return "License Key is Wrong Format"
            case .invalid : return "Invalid license. (415)"
            
        }
        
    }
    
}

enum LicenseState:String {
    case trial
    case expired
    case valid
    case undetermined
    case updating
    
    var valid:Bool {
        switch self {
            case .trial : return true
            case .valid : return true
            case .updating : return true
            default : return false
            
        }
        
    }
    
    var name:LocalizedStringKey {
        switch self {
            case .expired : return "Expired License"
            case .valid : return "Valid License"
            default : return "Trial"
            
        }
        
    }
    
}

struct LicenseObject {
    var state:LicenseState
    var expires:Date?
    
    init(_ state: LicenseState, expires: Date? = nil) {
        self.state = state
        self.expires = expires
        
    }
    
}
