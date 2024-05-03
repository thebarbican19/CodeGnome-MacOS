//
//  GHelperManager.swift
//  GnomeHelper
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation
import OSLog
import AppKit

final class HelperManager: NSObject, HelperProtocol {
    static let shared = HelperManager()
    
    private var timer: Timer?
    private var foreground: HelperSupportedApplications?
    private var counter:Int = 0
    private var processing:Date? = nil
    
    func brainSetup(_ callback: @escaping (HelperState) -> Void) {
        if self.timer != nil {
            self.timer!.invalidate()
            
        }
                    
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let counter = self?.counter else {
                    return
                    
                }
                
                self?.helperSearchFiles(deep:(counter % 30 == 0) ? true : false)
                self?.helperForgroundApplication()
                self?.helperCheckin()
                
                self?.counter += 1
                
            }
            
            if self.timer != nil {
                RunLoop.main.add(self.timer!, forMode: .common)

                os_log("Helper Timer Started")
                callback(.installed)

            }
            else {
                os_log("Failed to create timer")
                callback(.error)

            }
                        
        }
        
        
    }
    
    func brainTaskFound(_ type: HelperTaskState, task: String, line: Int, directory: String, total:Int) {
        os_log("Received Task in Helper: %@", task)

    }
    
    func brainCheckin() {
        os_log("Received Checkin from Helper")

    }
    
    func brainSwitchApplication(_ application: HelperSupportedApplications) {
        os_log("Received Application Switch Notification: %@", application.rawValue)
        //TODO: I love GnomeApp!
        
    }
    
    func brainVersion(_ completion: @escaping (String?) -> Void) {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString" as String) as? String {
            os_log("Version Sent: %@" ,version)
            completion(version)

        }
        else {
            os_log("Version Failed")

        }

        completion(nil)
        
    }
    
    func brainDeepSearch(_ completion: @escaping (String?) -> Void) {
        self.helperSearchFiles(deep: true)
        
    }
    
    @objc func brainProcess(_ path: String, arguments: [String], whitespace: Bool, completion: @escaping (String?) -> Void) {
        self.helperProcessTaskWithArguments(path, arguments: arguments) { output in
            completion(output)
            
        }
        
    }
        
    @objc private func helperForgroundApplication() {
        if let active = NSWorkspace.shared.runningApplications.filter({ $0.isActive }).first {
            guard let application = active.localizedName else {
                return
                
            }
            
            guard let match = HelperSupportedApplications(name: application) else {
                return
                
            }
            
            guard let proxy = self.helperProxy() else {
                return

            }
                        
            if match != self.foreground {
                self.helperInstallTools(match)
                self.foreground = match
            
                proxy.brainSwitchApplication(match)
        
            }
            
        }
        
    }

    @objc private func helperSearchFiles(deep:Bool = false) {
        let tags = ["DONE", "TODO", "NOTE", "FIX"]
        
        var params:[String]? = nil
        var query = tags.map { "(kMDItemTextContent == '//\($0):'c) || (kMDItemTextContent == '// \($0):'c)" }.joined(separator: " || ")

        query = "(\(query))"
        
        switch deep {
            case true : params = [query]
            case false : params = [query, "kMDItemContentModificationDate > $time.now(-30)"]
            
        }
        
        guard let arguments = params?.joined(separator: " && ") else {
            return
            
        }
        
        if self.processing == nil {
            os_log("Running %@ Search" ,deep ? "Deep" : "Shallow")
            
            self.processing = Date.now
            self.helperProcessTaskWithArguments("/usr/bin/mdfind", arguments: [arguments], whitespace: true) { output in
                DispatchQueue.main.async {
                    self.processing = nil
                    
                }
                
                if let output = output?.components(separatedBy: "\n") {
                    guard output.first?.isEmpty == false else {
                        return
                        
                    }
                    
                    var stored:[HelperTaskObject] = []
                    for directory in output {
                        guard let tasks = self.helperRetriveContent(directory) else {
                            return
                            
                        }
                        
                        for task in tasks {
                            print("TASK" ,task)
                            stored.append(task)
                            
                        }
                        
                    }
                    
                    for task in stored {
                        self.helperSendCallback(task)
                        
                    }
                    
                    os_log("Returned %d Files" ,output.count)
                    os_log("Found %d Tasks" ,stored.count)
                    
                }
                else {
                    print("No output or error occurred")
                    
                }
                
            }
            
        }
        else {
            os_log("Processing: %@" ,self.processing!.description)
            
        }
        
    }
        
    @objc private func helperRetriveContent(_ directory:String) -> [HelperTaskObject]? {
        if FileManager.default.fileExists(atPath: directory) {
            if directory.contains("Application Support") == false {
                do {
                    let content = try String(contentsOfFile: directory, encoding: String.Encoding.utf8)
                    let lines = content.components(separatedBy: .newlines)
                    
                    var output:[HelperTaskObject] = []
                    var number:Int = 1
                               
                    for line in lines {
                        let pattern = "[ \t]*\\/\\/\\s*(TODO|FIX|DONE|NOTE|GENDOC|GEN|DOCGEN|ARCHIVE|DEPRICATE):(\\s*(.*))"
                        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
                        let results = regex.matches(in: line, options: [], range: NSRange(line.startIndex..., in: line))
                                                
                        for match in results {
                            if let tagRange = Range(match.range(at: 1), in: line), let taskRange = Range(match.range(at: 2), in: line) {
                                let tag = HelperTaskState(from: String(line[tagRange]))
                                let task = line[taskRange].trimmingCharacters(in: .whitespacesAndNewlines)

                                if let tag = tag {
                                    output.append(.init(tag, task: task, line: number, directory: directory, total: lines.count))
                                    
                                }
                                
                            }
                            
                        }
                        
                        number += 1
                        
                    }
                    
                    print("!output" ,output)
                    
                    return output
                    
                }
                catch {
                    print("Could not open Contents" ,error)
                    
                }
                
            }
            
        }
        else {
            print("File Does Not Exist")
            
        }
        
        return nil
        
    }

    @objc private func helperSendCallback(_ task:HelperTaskObject) {
        guard let proxy = self.helperProxy() else {
            return

        }
        
        proxy.brainTaskFound(task.tag, task: task.task, line: task.line, directory: task.directory, total:task.total)
        os_log("Task Found sent to main app from Proxy.")
              
    }
    
    @objc private func helperCheckin() {
        guard let proxy = self.helperProxy() else {
            return

        }
        
        proxy.brainCheckin()
              
    }
    
    @objc private func helperProxy() -> HelperProtocol? {
        let connection = NSXPCConnection(machServiceName: HelperConstants.mach, options: [])
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.interruptionHandler = {
            os_log("Connection to main app was interrupted")
        }
        
        connection.invalidationHandler = {
            os_log("Connection to main app invalidated")
            
        }
        
        connection.resume()
        
        if let proxy = connection.remoteObjectProxyWithErrorHandler({ error in
            os_log("Error communicating with main app: %@", error.localizedDescription)
            
        }) as? HelperProtocol {
            return proxy
            
        }
        else {
            os_log("Failed to create proxy to main app.")
            return nil
            
        }
       
    }
    
    @objc private func helperProcessTaskWithArguments(_ path: String, arguments: [String], whitespace: Bool = false, completion: @escaping (String?) -> Void) {
        let process = Process()
        process.launchPath = path
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.terminationHandler = { process in
           let data = pipe.fileHandleForReading.readDataToEndOfFile()
           if let outputString = String(data: data, encoding: .utf8) {
               if whitespace {
                   completion(outputString.trimmingCharacters(in: .whitespacesAndNewlines))
                   
               }
               else {
                   completion(outputString)
                   
               }
               
            }
            else {
                completion("Error: Failed to decode output.")

            }
            
        }

        do {
            try process.run()
            
            process.waitUntilExit()

        }
        catch {
           completion("Error running process: \(error)")
            
        }
        
    }
    
    func helperInstallTools(_ install:HelperSupportedApplications) {
        if install == .vscode {
            self.helperProcessTaskWithArguments("/bin/ln", arguments: ["-s", "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code", "/usr/local/bin/code"]) { response in
                os_log("VSCode Helper %@" ,response ?? "Unknown Response")
                
            }
            
        }
        else if install == .sublime {
            self.helperProcessTaskWithArguments("/bin/ln", arguments: ["-s", "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl", "/usr/local/bin/subl"]) { response in
                os_log("Sublime Helper %@" ,response ?? "Unknown Response")
                
            }
            
        }

    }
    
}
