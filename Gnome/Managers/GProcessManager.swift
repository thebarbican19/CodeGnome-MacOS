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
import SystemConfiguration
import Security
import OSLog

class ProcessListener: NSObject, NSXPCListenerDelegate, HelperProtocol {
    static var shared = ProcessListener()

    var listener: NSXPCListener?

    func startListener() {
        listener = NSXPCListener(machServiceName: "com.ovatar.gnome.brain.mach")
        listener?.delegate = self
        listener?.resume()
        
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.exportedObject = self
        newConnection.resume()
        
        return true
        
    }
        
    func brainTaskFound(_ type: HelperTaskState, task: String, line: Int, directory: String, total:Int) {
        DispatchQueue.main.async {
            guard let project = TaskManager.shared.projectStore(directory: directory) else {
                return
                
            }
            
            TaskManager.shared.taskCreate(type, task: task, line: line, project:project, total:total)

        }
        
    }
    
    func brainCheckin() {
        DispatchQueue.main.async {
            ProcessManager.shared.checkin = Date.now
            ProcessManager.shared.processUpdateState(.allowed)

        }
        
    }

    func brainSetup(_ completion: @escaping (HelperState) -> Void) {
        
    }
    
}

class ProcessManager:ObservableObject {
    static var shared = ProcessManager()
    
    @Published var helper:ProcessPermissionState = .unknown
    @Published var checkin:Date? = nil
    @Published var message:String = "Nothing Recived"

    init() {
        self.processSetup()
            
    }
    
    var connection: NSXPCConnection? = {
       let connection = NSXPCConnection(machServiceName: "com.ovatar.gnome.brain.mach", options: .privileged)
       connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
       connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
       connection.exportedObject = HelperProtocol.self
       connection.interruptionHandler = {
           print("Connection to helper was interrupted.")
           
       }
       connection.invalidationHandler = {
           DispatchQueue.main.async {
               ProcessManager.shared.processUpdateState(.undetermined)
               
           }
       }

       connection.resume()
        
       return connection
        
   }()
    
    public func processSetup() {
        ProcessListener.shared.startListener()

        if let helper = self.connection?.remoteObjectProxy as? HelperProtocol {
            helper.brainSetup { state in
                if state == .installed {
                    self.processUpdateState(.allowed)

                }

            }
            
        }
        else {
            if self.helper == .allowed {
                self.processInstallHelper()
                
            }
                        
        }
        
    }
    
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
            let error = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            print("AuthorizationCreate failed with \(status): \(error)")
            
            self.processUpdateState(.error)
            
        }
        else {
            if SMJobBless(kSMDomainSystemLaunchd, helper, reference, &error) != true {
                if let error = error?.takeRetainedValue() {
                    DispatchQueue.main.async {
                        let errorCode = CFErrorGetCode(error)
                        let errorDescription = CFErrorCopyDescription(error) as String? ?? "Unknown error"
                        print("SMJobBless failed with error code \(errorCode): \(errorDescription)")
                        
                        switch errorCode {
                            case -60005, -60006, -60008:self.processUpdateState(.denied)
                            default:self.processUpdateState(.error)
                            
                        }
                        
                    }
                    
                }
                
            }
            else {
                self.processSetupConntection()
                
            }
            
        }
        
        if reference != nil {
            AuthorizationFree(reference!, [])
            
        }

    }
    
    private func processSetupConntection() {
        if let helper = self.connection?.remoteObjectProxy as? HelperProtocol {
            helper.brainSetup { state in
                DispatchQueue.main.async {
                    self.processUpdateState(.allowed)
                    
                }
                
            }
            
        }
        else {
            self.processUpdateState(.error)
            
        }
        
    }
    
    public func processUpdateState(_ state:ProcessPermissionState) {
        DispatchQueue.main.async {
            if self.helper != state {
                self.helper = state
                print("STATE: " ,state)
                
            }
            
            if state == .allowed {
                ProcessListener.shared.startListener()

            }
            
        }
        
    }
    
}
