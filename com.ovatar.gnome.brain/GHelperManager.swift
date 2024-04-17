//
//  GHelperManager.swift
//  GnomeHelper
//
//  Created by Joe Barbour on 4/16/24.
//

import Foundation

@objc(GnomeHelperProtocol) protocol GnomeHelperProtocol {
    
}

final class GnomeHelperManager: NSObject, GnomeHelperProtocol {
    static let shared = GnomeHelperManager()
    
}
