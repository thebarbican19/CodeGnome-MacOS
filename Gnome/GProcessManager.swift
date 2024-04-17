//
//  GProcessManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation
import Combine
import AppKit
import SecurityFoundation
import ServiceManagement

class ProcessManager:ObservableObject {
    static var shared = ProcessManager()
    
    @Published var helper:ProcessPermissionState = .unknown

    public var connection: NSXPCConnection? = {
        let connection = NSXPCConnection(machServiceName: "com.ovatar.gnome.brain.mach", options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: GnomeHelperProtocol.self)
        connection.resume()
        
        return connection
        
    }()
    
    public func processInstallHelper() {
        var reference: AuthorizationRef?
        var error: Unmanaged<CFError>?
        
        let helper = "com.ovatar.gnome.brain" as CFString
        let flags: AuthorizationFlags = [.interactionAllowed, .preAuthorize, .extendRights]
        
        var item = kSMRightBlessPrivilegedHelper.withCString {
            AuthorizationItem(name: $0, valueLength: 0, value: nil, flags: 0)
        }
        
        var rights = withUnsafeMutablePointer(to: &item) {
            AuthorizationRights(count: 1, items: $0)
        }
        
        let status = AuthorizationCreate(&rights, nil, flags, &reference)
        if status != errAuthorizationSuccess {
            print("AuthorizationCreate failed with \(status)")
            // Consider adding more detailed error handling here.
            return
        }
        
        let blessStatus = SMJobBless(kSMDomainSystemLaunchd, helper, reference, &error)
        if blessStatus != true {
            if let error = error?.takeRetainedValue() {
                DispatchQueue.main.async {
                    let errorCode = CFErrorGetCode(error)
                    let errorDescription = CFErrorCopyDescription(error) as String? ?? "Unknown error"
                    print("SMJobBless failed with error code \(errorCode): \(errorDescription)")
                    
                    switch errorCode {
                        case -60005, -60006, -60008:self.helper = .denied
                        default:self.helper = .error
                        
                    }
                    
                }
                
            }
            
        }
        else {
            DispatchQueue.main.async {
                self.helper = .allowed
                print("ALLOWED")
                
            }
            
        }
        
    }
    
}
