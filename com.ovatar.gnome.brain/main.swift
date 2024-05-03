//
//  main.swift
//  com.ovatar.gnome.brain
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation
import Cocoa
import os.log

os_log("Main Helper Setup Began")

HelperManager.shared.brainSetup { state in
    os_log("Main Helper Setup Complete")
    
}

CFRunLoopRun()
