//
//  main.swift
//  com.ovatar.gnome.brain
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation
import Cocoa
import os.log

final class HelperDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        connection.exportedInterface = NSXPCInterface(with: GnomeHelperProtocol.self)
        connection.exportedObject = GnomeHelperManager.shared
        connection.interruptionHandler = {
           os_log("Scheming Gnome connection interrupted")

        }
        connection.invalidationHandler = {
           os_log("Scheming Gnome connection invalidated")

        }
        connection.resume()
        
        return true
        
    }
    
}

let delegate = HelperDelegate()
let listener = NSXPCListener(machServiceName: "com.ovatar.gnome.brain.mach")
listener.delegate = delegate
listener.resume()

RunLoop.current.run()

