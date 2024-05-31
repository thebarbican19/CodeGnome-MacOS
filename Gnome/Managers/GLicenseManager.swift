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

    @Published var state:LicenseObject = .init(.undetermined, type: .full)
    @Published var error:LicenseResponseState? = nil
    @Published var details:LicenseResponseObject? = nil
    
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
                
                LicenseManager.shared.error = nil
                LicenseManager.shared.details = nil
                
                _ = OnboardingManager.shared.onboardingStep(.complete, step: .remove)

                WindowManager.shared.windowClose(.license, animate: true)
                
                return
                
            }
            
            if key.filter({ $0 == "-" }).count == 4 && key.hasPrefix("CG") {
                UserDefaults.save(.licenseKey, value: newValue)
                
                LicenseManager.shared.error = nil

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
                        case .valid : self.state = .init(.valid, type: .full, expires: expiry)
                        case .expired : self.state = .init(.expired, type: .full, expires: expiry)
                        case .invalid : self.state = .init(.expired, type: .full, expires: expiry)
                        case .unknown : self.state = .init(.undetermined, type: .full, expires: expiry)
                        case .capacity : self.state = .init(.expired, type: .full, expires: expiry)
                        case .validation : self.state = .init(.undetermined, type: .full, expires: expiry)
                        
                    }
                    
                    self.error = state
                    
                }
               
            }
            
        }
        else {
            self.state = self.licenseTrialExpired()
            self.details = .init(usage: .init(used: 1, total: 1), expiry: self.state.expires, customer: nil)
            
        }
        
    }
    
    private func licenseTrialExpired() -> LicenseObject {
        guard let tasks = TaskManager.shared.tasks else {
            return .init(.trial, type: .trial, expires: Calendar.current.date(byAdding: .day, value: 14, to: Date.now))
            
        }
        
        guard let oldest = tasks.sorted(by: { $0.created < $1.created }).first else {
            return .init(.trial, type: .trial, expires: Calendar.current.date(byAdding: .day, value: 14, to: Date.now))

        }
                
        guard let days = Calendar.current.date(byAdding: .day, value: -14, to: Date.now) else {
            return .init(.trial, type: .trial, expires: Calendar.current.date(byAdding: .day, value: 14, to: Date.now))

        }
    
        if oldest.created < days {
            return .init(.expired, type: .trial, expires: days)
            
        }
        
        return .init(.trial, type: .trial, expires: days)
        
    }
    
    public func licenseRevoke() {
        guard let serial = self.licenseSerialNumber() else {
            return
            
        }
        
        var params:[String:String] = [:]
        params["sn"] = serial
        
        guard let endpoint = self.licenceEndpoint("https://ovatar.io/api/license", parameters:params) else {
            return
            
        }
        
        print("calling \(endpoint)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse else {
                    print("no response")
                    return
                    
                }
                
                if response.statusCode == 200 || response.statusCode == 201 {
                    self.error = nil
                    self.details = nil
                    
                    LicenseManager.licenseKey = nil
                    
                }
            
            }
            
        }.resume()
        
        DispatchQueue.main.async {
            self.state = .init(.updating, type: .full)
            
        }
                
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
                self.state = .init(.updating, type: .full)
                
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
                            completion(.unknown, nil)
                            return
                            
                        }
                        
                        guard let data = data else {
                            completion(.unknown, nil)
                            return
                            
                        }
                        
                        guard let payload = try? decoder.decode(LicenseResponse.self, from: data) else {
                            completion(.unknown, nil)
                            return
                            
                        }
                        
                        if let json = String(data: data, encoding: .utf8) {
                            UserDefaults.save(.licensePayload, value: json)
                            
                        }
                        
                        print("response" ,response.statusCode)
                        
                        switch response.statusCode {
                            case 403 : completion(.expired, payload.license.expiry)
                            case 415 : completion(.invalid, payload.license.expiry)
                            case 429 : completion(.capacity, payload.license.expiry)
                            case 200 : completion(.valid, payload.license.expiry)
                            default : completion(.unknown, payload.license.expiry)
                            
                        }
                        
                        self.details = payload.license

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
                switch payload.status {
                    case 403 : completion(.expired, payload.license.expiry)
                    case 415 : completion(.invalid, payload.license.expiry)
                    case 429 : completion(.capacity, payload.license.expiry)
                    case 200 : completion(.valid, payload.license.expiry)
                    default : completion(.unknown, payload.license.expiry)
                    
                }
                
                self.details = payload.license

                
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
