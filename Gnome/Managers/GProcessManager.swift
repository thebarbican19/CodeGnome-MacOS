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
    
    private var listener: NSXPCListener?

    func start(_ force:Bool = false) {
        if self.listener == nil || force == true {
            guard let mach = Bundle.env("G_HELPER_MACH") else {
                return
                
            }
            
            self.listener = NSXPCListener(machServiceName: mach)
            self.listener?.delegate = self
            self.listener?.resume()
         
            os_log("Listener Initlised")
            
        }
        
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        print("Connection: \(connection)")
        connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedObject = self
        connection.resume()
        
        return true
        
    }
    
    func brainTaskFound(_ type: HelperTaskState, task: String, line: Int, directory: String, total:Int) {
        DispatchQueue.main.async {
            guard let project = TaskManager.shared.projectStore(directory: directory) else {
                print("Importing Task but Project Not Stored")
                return
                
            }
            
            guard let file = TaskManager.shared.fileStore(directory: directory) else {
                print("Importing Task but File Not Stored")
                return
                
            }
            
            TaskManager.shared.taskCreate(type, task: task, line: line, directory: directory, file: file, project:project, total:total)
            
            print("Importing Task Complete")
            os_log("Importing Task")
            
        }
        
        DispatchQueue.main.async {
            ProcessManager.shared.checkin = Date.now
            ProcessManager.shared.processUpdateState(.allowed)

        }
        
    }
    
    func brainInvalidateTasks(_ directory: String) {
        DispatchQueue.main.async {
            switch SettingsManager.shared.enabledArchive {
                case true :  TaskManager.shared.taskUpdateFromDirectory(directory, state: .archived)
                case false : TaskManager.shared.taskUpdateFromDirectory(directory, state: .done)
                
            }
            
            ProcessManager.shared.checkin = Date.now
            ProcessManager.shared.processUpdateState(.allowed)

        }
        
    }

    func brainSetup(_ completion: @escaping (HelperState) -> Void) {

    }
    
    func brainProcess(_ path: String, arguments: [String], whitespace: Bool, completion: @escaping (String?) -> Void) {
        
    }
    
    func brainVersion(_ version: (String?) -> Void) {
        DispatchQueue.main.async {
            ProcessManager.shared.checkin = Date.now
            
        }
    }
    
    func brainSwitchApplication(_ application: HelperSupportedApplications) {
        DispatchQueue.main.async {
            ProcessManager.shared.application = application
            
        }
        
    }
    
    func brainDeepSearch(_ completion: @escaping (String?) -> Void) {
        
    }
    
}

class ProcessManager:ObservableObject {
    static var shared = ProcessManager()
    
    @Published var helper:ProcessPermissionState = .unknown
    @Published var checkin:Date? = nil
    @Published var message:String = "Nothing Recived"
    @Published var application:HelperSupportedApplications? = nil

    private var updates = Set<AnyCancellable>()

    init() {
        $checkin.receive(on: DispatchQueue.main).sink { checkin in
           
        }.store(in: &updates)
        
        $application.receive(on: DispatchQueue.main).sink { app in
            // TODO: Tutorial Application Notification!
            
        }.store(in: &updates)
        
        self.processStatus()
        
    }

    private func processConnection() -> NSXPCConnection? {
        guard let mach = Bundle.env("G_HELPER_MACH") else {
            return nil
            
        }
        
        let connection = NSXPCConnection(machServiceName: mach, options: .privileged)
        connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedObject = HelperProtocol.self
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.invalidationHandler = {
        connection.invalidationHandler = nil
            OperationQueue.main.addOperation {
                os_log("XPC Connection Invalidated")
                DispatchQueue.main.async {
                   ProcessManager.shared.processUpdateState(.undetermined)
    
                }
                    
            }
            
        }
        
        connection.resume()
        os_log("XPC Connection established")
                
        return connection
        
    }
    
    public func processHelper() -> HelperProtocol? {
        guard let connection = self.processConnection() else {
            return nil

        }
        
        if let helper = connection.remoteObjectProxy as? HelperProtocol {
            return helper

        }
        else {
            return nil
            
        }
        
    }
    
    public func processStatus() {
        guard let mach = Bundle.env("G_HELPER_ID") else {
            return
            
        }
        
        guard let info = CFBundleCopyInfoDictionaryForURL(Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/" + mach) as CFURL) as? [String: Any] else {
            print("Could Not Get Mach Information")
            self.processUpdateState(.error)
            return
            
        }
        
        guard let version = info["CFBundleVersion"] as? String else {
            print("Could Not Get Mach Version")
            self.processUpdateState(.error)
            return
            
        }
        
        guard let helper = self.processHelper() else {
            print("Could Not Get Helper")
            self.processUpdateState(.error)
            
            return
            
        }
        
        NSLog("Helper: Bundle Version => \(String(describing: version))")
                
        ProcessListener.shared.start()
        
        helper.brainVersion { installed in
            guard let installed = installed else {
                print("Setup No Version")
                self.processUpdateState(.error)
                return
                
            }
            
            print("Setup Version: \(version)")

            if installed == version {
                self.processSetupConntection()
            
            }
            else {
                self.processUpdateState(.outdated)
                
            }
            
        }
        
    }
    
    public func processDeepSearch() {
        guard let helper = self.processHelper() else {
            return
            
        }
        
        helper.brainDeepSearch { response in
            
        }

    }
    
    public func processInstallHelper() {
        guard let mach = Bundle.env("G_HELPER_ID") else {
            return
            
        }
        
        var reference: AuthorizationRef?
        var error: Unmanaged<CFError>?
            
        var item = kSMRightBlessPrivilegedHelper.withCString {
            AuthorizationItem(name: $0, valueLength: 0, value: nil, flags: 0)
            
        }
        
        var rights = withUnsafeMutablePointer(to: &item) {
            AuthorizationRights(count: 1, items: $0)
            
        }
        
        let status = AuthorizationCreate(&rights, nil, [.interactionAllowed, .preAuthorize, .extendRights], &reference)
        if status != errAuthorizationSuccess {
            let error = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            print("AuthorizationCreate failed with \(status): \(error)")
            
            switch status {
                case -60006 : self.processUpdateState(.cancelled)
                default : self.processUpdateState(.error)
                
            }
            
        }
        else {
            if SMJobRemove(kSMDomainSystemLaunchd, mach as CFString, reference, true, &error) {
                print("Successfully removed old helper job.")
                    
            }
            
            if SMJobBless(kSMDomainSystemLaunchd, mach as CFString, reference, &error) {
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
                else {
                    self.processStatus()

                }
                
            }
            else {
                self.processStatus()

            }
            
            if reference != nil {
                AuthorizationFree(reference!, [.destroyRights])
                
            }
            
        }

    }
    
    private func processSetupConntection() {
        guard let connection = self.processConnection() else {
            return
            
        }
        
        if let helper = connection.remoteObjectProxy as? HelperProtocol {
            print("Setting Up Connection")
            helper.brainSetup() { state in
                DispatchQueue.main.async {
                    self.processUpdateState(.allowed)
                    
                }
                
            }
            
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
                if self?.helper != .allowed {
                    self?.processUpdateState(.error)

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
                
                if self.helper == .allowed && self.processConnection() != nil {
                    ProcessListener.shared.start(true)

                }
                
            }
            
        }
        
    }
    
    func processBootupHelper(named processName: String, at path: String) {
        let taskList = Process()
        taskList.launchPath = "/bin/ps"
        taskList.arguments = ["-axco", "command"]

        let pipe = Pipe()
        taskList.standardOutput = pipe

        taskList.launch()
        taskList.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        if output?.contains(processName) == false {
            let process = Process()
            process.launchPath = path
            process.launch()
            
        } 
        else {
            print("\(processName) is already running.")
            
        }
    }
    
    public func processRun(_ path:String, arguments:[String], whitespace:Bool = false, completion: @escaping (String?) -> Void) {
        guard let connection = self.processConnection() else {
            return
            
        }
        
        if let helper = connection.remoteObjectProxy as? HelperProtocol {
            helper.brainProcess(path, arguments: arguments, whitespace: whitespace) { response in
                completion(response)

            }
            
        }
        else {
            completion(nil)
            
        }
        
    }
    
}
