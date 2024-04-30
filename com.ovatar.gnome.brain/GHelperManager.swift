//
//  GHelperManager.swift
//  GnomeHelper
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation
import OSLog

final class HelperManager: NSObject, HelperProtocol {
    static let shared = HelperManager()
    
    private var timer: Timer?

    override init() {
        super.init()
        self.brainSetup { _ in
            self.helperCheckin()

        }
                
    }
    
    func brainSetup(_ completion: @escaping (HelperState) -> Void) {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
                self?.helperSearchFiles()
                self?.helperCheckin()
                
            }
            
            self.helperInstallTools(.vscode)
            
            if self.timer != nil {
                RunLoop.main.add(self.timer!, forMode: .common)

            }
            else {
                os_log("Failed to create timer")
                
            }
            
            completion(.installed)
            
        }
        
    }
    
    func brainTaskFound(_ type: HelperTaskState, task: String, line: Int, directory: String, total:Int) {
        os_log("Received Task in Helper: %@", task)

    }
    
    func brainCheckin() {
        
    }
    
    @objc func brainProcess(_ path: String, arguments: [String], whitespace: Bool, completion: @escaping (String?) -> Void) {
        self.helperProcessTaskWithArguments(path, arguments: arguments) { output in
            print("outputString" ,output)

            completion(output)
            
        }
        
    }

    @objc private func helperSearchFiles() {
        self.helperProcessTaskWithArguments("/usr/bin/mdfind", arguments:  ["(kMDItemTextContent == '//DONE:'c) || (kMDItemTextContent == '//TODO:'c) || (kMDItemTextContent == '//NOTE:'c) || (kMDItemTextContent == '//GENDOC:'c) || (kMDItemTextContent == '//FIX:'c) || (kMDItemTextContent == '// DONE:'c) || (kMDItemTextContent == '// TODO:'c) || (kMDItemTextContent == '// NOTE:'c) || (kMDItemTextContent == '// GENDOC:'c) || (kMDItemTextContent == '// FIX:'c)"], whitespace: true) { output in
            if let output = output?.components(separatedBy: "\n") {
                for directory in output {
                    self.helperRetriveContent(directory)
                    
                }
                
            }
            else {
                print("No output or error occurred")
                
            }
            
        }
        
    }
        
    @objc private func helperRetriveContent(_ directory:String) {
        if FileManager.default.fileExists(atPath: directory) {
            if directory.contains("Application Support") == false {
                do {
                    let content = try String(contentsOfFile: directory, encoding: String.Encoding.utf8)
                    let lines = content.components(separatedBy: .newlines)
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
                                    self.helperSendCallback(tag, task: task, line: number, directory: directory, total: lines.count)

                                }
                                
                            }
                            
                        }
                        
                        number += 1
                        
                    }
                    
                }
                catch {
                    print("Could not open Contents" ,error)
                    
                }
                
            }
            
        }
        else {
            print("File Does Not Exist")
            
        }
    }

    @objc private func helperSendCallback(_ type: HelperTaskState, task: String, line: Int, directory: String, total:Int) {
        let connection = NSXPCConnection(machServiceName: "com.ovatar.gnome.brain.mach", options: [])
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
        }) 
        as? HelperProtocol {
            proxy.brainTaskFound(type, task: task, line: line, directory: directory, total:total)
            
        }
        else {
            os_log("Failed to create proxy to main app.")
            
        }
              
    }
    
    @objc private func helperCheckin() {
        let connection = NSXPCConnection(machServiceName: "com.ovatar.gnome.brain.mach", options: [])
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
        })
        as? HelperProtocol {
            proxy.brainCheckin()
            
        }
        else {
            os_log("Failed to create proxy to main app.")
            
        }
              
    }
    
    // ## TODO: THIS IS MY FIRST GNOME TODO TASK

    func helperProcessTaskWithArguments(_ path: String, arguments: [String], whitespace: Bool = false, completion: @escaping (String?) -> Void) {
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
    
    func helperInstallTools(_ install:HelperInstallTools) {
        if install == .vscode {
            self.helperProcessTaskWithArguments("/bin/ln", arguments: ["-s", "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code", "/usr/local/bin/code"]) { response in
                os_log("VSCode Helper %@" ,response ?? "Unknown Response")
                
            }
            
        }

    }
    
}
