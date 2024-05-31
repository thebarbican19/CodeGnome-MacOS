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
    let customer: LicenseCustomerObject?
    
    init(usage: LicensUsageObject, expiry: Date?, customer: LicenseCustomerObject?) {
        self.usage = usage
        self.expiry = expiry ?? Date()
        self.customer = customer
        
    }
    
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
            case .unknown : return "Unknown error occurred"
            case .expired : return "License has expired"
            case .valid : return "License is valid"
            case .capacity : return "Capacity limit reached"
            case .validation : return "License key is invalid"
            case .invalid : return "Invalid license"
            
        }
        
    }
    
    var colour:Color {
        switch self {
            case .unknown : return Color("GradientMagenta")
            case .expired : return Color("GradientMagenta")
            case .valid : return Color("GradientGreen")
            case .capacity : return Color("GradientYellow")
            case .validation : return Color("GradientMagenta")
            case .invalid : return Color("GradientMagenta")
            
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

enum LicenseType {
    case trial
    case full
    
}

struct LicenseObject {
    var state:LicenseState
    var type:LicenseType
    var expires:Date?
    
    init(_ state: LicenseState, type:LicenseType, expires: Date? = nil) {
        self.state = state
        self.expires = expires
        self.type = type
        
    }
    
}
