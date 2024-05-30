//
//  GLicenseManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/29/24.
//

import Foundation
import Combine
import SwiftUI

class LicenseManager:ObservableObject {
    static var shared = LicenseManager()

    @Published var state:LicenseObject = .init(.undetermined)
    @Published var error:LicenseResponseState? = nil
    @Published var customer:LicenseCustomerObject? = nil
    @Published var expiry:Date? = nil
    
    //TODO: License Checked Date Functionality to add
    //Check if license has been verifyed last, store date so it doesn't need to check every time the app has launched

    private var updates = Set<AnyCancellable>()

    init() {
        TaskManager.shared.$tasks.debounce(for: .seconds(100), scheduler: DispatchQueue.main).removeDuplicates().sink() { _ in
            self.licenseValidate(true)

        }.store(in: &updates)
        
        UserDefaults.changed.receive(on: DispatchQueue.main).dropFirst(3).sink { key in
            print("key updated" ,key)
            if key == .licenseKey {
                self.licenseValidate(true)

            }
            
        }.store(in: &updates)

        self.licenseValidate(false)
        
    }
    
    static var licenseKey:String? {
        get {
            if let key = UserDefaults.object(.licenseKey) as? String {
                return key
                
            }
            
            return nil
            
        }
        
        set {
            guard let key = newValue else {
                UserDefaults.save(.licenseKey, value: nil)
                return
                
            }
            
            if key.filter({ $0 == "-" }).count == 4 && key.hasPrefix("CG") {
                UserDefaults.save(.licenseKey, value: newValue)
                
            }
            else {
                UserDefaults.save(.licenseKey, value: nil)
                LicenseManager.shared.error = .validation
                
            }
            
        }
        
    }
    
    public func licenseValidate(_ force:Bool) {
        if let key = LicenseManager.licenseKey {
            self.licenseServerCheck(key: key, force: force) { state, expiry in
                DispatchQueue.main.async {
                    switch state {
                        case .valid : self.state = .init(.valid, expires: expiry)
                        case .expired : self.state = .init(.expired, expires: expiry)
                        case .invalid : self.state = .init(.expired, expires: expiry)
                        case .unknown : self.state = .init(.undetermined, expires: expiry)
                        case .capacity : self.state = .init(.expired, expires: expiry)
                        case .validation : self.state = .init(.undetermined, expires: expiry)
                        
                    }
                    
                    self.error = state
                    
                }
               
            }
            
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
    
    public func licenseRevoke(_ completion: @escaping (Bool) -> Void) {
        guard let serial = self.licenseSerialNumber() else {
            completion(false)
            return
            
        }
        
        var params:[String:String] = [:]
        params["sn"] = serial
        
        guard let endpoint = self.licenceEndpoint("https://ovatar.io/api/license", parameters:params) else {
            completion(false)
            return
            
        }
        
        print("calling \(endpoint)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse else {
                    print("no response")
                    
                    completion(false)
                    return
                    
                }
                
                switch response.statusCode {
                    case 200 : completion(true)
                    case 201 : completion(true)
                    default : completion(false)
                    
                }
                
            }
            
        }.resume()
                
    }
        
    private func licenseServerCheck(key: String, force:Bool, completion: @escaping (LicenseResponseState, Date?) -> Void) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let expiry = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            completion(.unknown, nil)
            return
            
        }
        
        if UserDefaults.timestamp(.licensePayload) ?? Date() < expiry || force == true {
            if force == true {
                print("Force License Check")
                
            }
            
            guard let serial = self.licenseSerialNumber() else {
                completion(.unknown, nil)
                return
                
            }
            
            DispatchQueue.main.async {
                self.state = .init(.updating)
                
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                var params:[String:String] = [:]
                params["key"] = key
                params["name"] = self.licenseDeviceName()
                params["sn"] = serial
                
                guard let endpoint = self.licenceEndpoint("https://ovatar.io/api/license", parameters:params) else {
                    completion(.unknown, nil)
                    return
                    
                }
                
                print("calling \(endpoint)")
                var request = URLRequest(url: endpoint)
                request.httpMethod = "GET"
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        guard let response = response as? HTTPURLResponse else {
                            print("no response")
                            
                            completion(.unknown, nil)
                            return
                            
                        }
                        
                        if let data = data {
                            if let payload = try? decoder.decode(LicenseResponse.self, from: data) {
                                self.expiry = payload.license.expiry
                                self.customer = payload.license.customer
                                
                                
                                
                            }
                            
                            if let json = String(data: data, encoding: .utf8) {
                                UserDefaults.save(.licensePayload, value: json)
                                
                            }
                            
                        }
                        
                        print("response" ,response.statusCode)
                        
                        switch response.statusCode {
                            case 403 : completion(.expired, self.expiry)
                            case 415 : completion(.invalid, self.expiry)
                            case 429 : completion(.capacity, self.expiry)
                            case 200 : completion(.valid, self.expiry)
                            default : completion(.unknown, self.expiry)
                            
                        }
                        
                    }
                    
                }.resume()
                
            }
            
        }
        else {
            guard let json = UserDefaults.object(.licensePayload) as? String else {
                completion(.unknown, nil)
                return
                
            }
            
            guard let data = json.data(using: .utf8) else {
                completion(.unknown, nil)
                return
                
            }
            
            if let payload = try? decoder.decode(LicenseResponse.self, from: data) {
                self.expiry = payload.license.expiry
                self.customer = payload.license.customer
             
                switch payload.status {
                    case 403 : completion(.expired, self.expiry)
                    case 415 : completion(.invalid, self.expiry)
                    case 429 : completion(.capacity, self.expiry)
                    case 200 : completion(.valid, self.expiry)
                    default : completion(.unknown, self.expiry)
                    
                }
                
            }
            
        }
        
    }
    
    private func licenceEndpoint(_ base: String, parameters: [String: String]) -> URL? {
        guard var components = URLComponents(string: base) else {
            return nil
            
        }

        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        return components.url
        
    }
    
    private func licenseDeviceName() -> String {
        return Host.current().localizedName ?? ""
        
    }

    private func licenseSerialNumber() -> String? {
        let platform = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

        defer {
            IOObjectRelease(platform)
            
        }

        guard platform != 0 else {
            return nil
            
        }

        guard let serial = IORegistryEntryCreateCFProperty(platform, "IOPlatformSerialNumber" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? String else {
            return nil
            
        }

        return serial
        
    }
    
}
