//
//  GLicenseManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/29/24.
//

import Foundation
import Combine
import SwiftUI

enum LicenseState:String {
    case trial
    case expired
    case valid
    case undetermined
    
    var valid:Bool {
        switch self {
            case .trial : return true
            case .valid : return true
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

class LicenseManager:ObservableObject {
    static var shared = LicenseManager()

    @Published var state:LicenseObject = .init(.undetermined)
    
    private var updates = Set<AnyCancellable>()

    init() {
        TaskManager.shared.$tasks.debounce(for: .seconds(100), scheduler: DispatchQueue.main).removeDuplicates().sink() { _ in
            self.licenseValidate()

        }.store(in: &updates)
        
        self.licenseValidate()
        
    }
    
    static var licenseKey:String? {
        get {
            // TODO: License Backend Logic
            return nil
            
        }
        
        set {
            
        }
        
    }
    
    public func licenseValidate() {
        if let _ = LicenseManager.licenseKey {
            self.state = .init(.valid)
            
        }
        else {
            self.state = self.licenseTrialExpired()
            
        }
        
    }
    
    private func licenseTrialExpired() -> LicenseObject {
        guard let tasks = TaskManager.shared.tasks else {
            return .init(.trial, expires: Calendar.current.date(byAdding: .day, value: 14, to: Date.now))
            
        }
        
        guard let oldest = tasks.sorted(by: { $0.created < $1.created }).first else {
            return .init(.trial, expires: Calendar.current.date(byAdding: .day, value: 14, to: Date.now))

        }
                
        guard let days = Calendar.current.date(byAdding: .day, value: -14, to: Date.now) else {
            return .init(.trial, expires: Calendar.current.date(byAdding: .day, value: 14, to: Date.now))

        }
    
        if oldest.created < days {
            return .init(.expired, expires: days)
            
        }
        
        return .init(.trial, expires: days)
        
    }
        
//    private func fetchData(from endpoint: LicenseEndpoint) async throws -> [String: Any] {
//        var request = URLRequest(url: endpoint.url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer YOUR_SECRET_KEY", forHTTPHeaderField: "Authorization")
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)
//            
//        }
//        
//        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//            throw NSError(domain: "", code: 0, userInfo: nil)
//            
//        }
//        
//        return jsonObject
//        
//    }
    
}
