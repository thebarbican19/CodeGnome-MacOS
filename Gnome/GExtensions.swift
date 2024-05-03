//
//  GExtensions.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import Combine
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let shortcutLeft = Self("RevealLeft", default: .init(.leftBracket, modifiers: [.option]))
    static let shortcutRight = Self("RevealRight", default: .init(.rightBracket, modifiers: [.option]))
    static let shortcutPin = Self("ModePin", default: .init(.p, modifiers: [.option, .command]))
    
}

extension Bundle {
    static func env(_ key:String) -> String? {
        let value = Bundle.main.infoDictionary?[key] as? String
        
        #if DEBUG
            if value == nil {
                fatalError("\n🚨 Enviroment Key MISSING: '\(key)'")
            }
        
        #endif
        
        return value
        
    }
    
}

extension String {
    private class Array2D {
        var rows: Int
        var columns: Int
        var matrix: [Int]
        
        init(rows: Int, columns: Int) {
            self.rows = rows
            self.columns = columns
            self.matrix = Array(repeating: 0, count: rows * columns)
        }
        
        subscript(row: Int, column: Int) -> Int {
            get {
                return matrix[row * columns + column]
            }
            set {
                matrix[row * columns + column] = newValue
            }
        }
    }
    
    func levenshteinDistance(with anotherString: String, caseSensitive: Bool = true, diacriticSensitive: Bool = true) -> Int {
        guard count != 0 else {
            return anotherString.count
        }
        
        guard anotherString.count != 0 else {
            return count
            
        }
        
        var firstString = self
        var secondString = anotherString
        if !caseSensitive {
            firstString = firstString.lowercased()
            secondString = secondString.lowercased()
        }
        
        if !diacriticSensitive {
            firstString = firstString.folding(options: .diacriticInsensitive, locale: Locale.current)
            secondString = secondString.folding(options: .diacriticInsensitive, locale: Locale.current)
        }
        
        let a = Array(firstString.utf16)
        let b = Array(secondString.utf16)
        
        // Initialize a 2D array for scores
        let scores = Array2D(rows: a.count + 1, columns: b.count + 1)
        
        // Fill scores of first word
        for i in 1...a.count {
            scores[i, 0] = i
        }
        
        // Fill scores of second word
        for j in 1...b.count {
            scores[0, j] = j
        }
        
        // Compute scores
        for i in 1...a.count {
            for j in 1...b.count {
                let cost: Int = a[i - 1] == b[j - 1] ? 0 : 1
                scores[i, j] = Swift.min(
                    scores[i - 1, j    ] + 1,   // deletion
                    scores[i    , j - 1] + 1,   // insertion
                    scores[i - 1, j - 1] + cost // substitution
                )
            }
        }
        
        return scores[a.count, b.count]
        
    }
    
    func filename() -> String {
        return self.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
        
    }
        
}

extension UserDefaults {
    static let changed = PassthroughSubject<AppDefaultsKeys, Never>()

    static func setup() {
        guard let _ = FileManager.default.ubiquityIdentityToken else {
            print("iCloud is not available or iCloud Drive is not enabled.")
            return
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            for key in cloud.dictionaryRepresentation.keys {
                if let key = AppDefaultsKeys(rawValue: key) {
                    changed.send(key)
                    
                }
                
            }
            
            NotificationCenter.default.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                       object: NSUbiquitousKeyValueStore.default, queue: nil) { notification in
                if let changes = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] {
                    for key in changes {
                        if let key = AppDefaultsKeys(rawValue: key) {
                            changed.send(key)

                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }

    static var cloud:NSUbiquitousKeyValueStore {
        return NSUbiquitousKeyValueStore.default
        
    }
    
    static func list() -> Array<AppDefaultsKeys> {
        return UserDefaults.cloud.dictionaryRepresentation.keys.compactMap({ AppDefaultsKeys(rawValue:$0) })
        
    }

    static func save(_ key:AppDefaultsKeys, value:Any?) {
        if let value = value {
            cloud.set(Date(), forKey: "\(key.rawValue)_timestamp")
            cloud.set(value, forKey: key.rawValue)
            cloud.synchronize()
            
            print("\n\n☁️ Saved \(value) to '\(key.rawValue)'\n\n")
    
            changed.send(key)
                            
        }
        else {
            cloud.removeObject(forKey: key.rawValue)
            cloud.set(Date(), forKey: "\(key.rawValue)_timestamp")
            cloud.synchronize()

            changed.send(key)
            
            print("\n\n💾 Removed to '\(key.rawValue)'\n\n")
            
        }
        
    }
        
    static func timestamp(_ key:AppDefaultsKeys) -> Date? {
        return UserDefaults.cloud.object(forKey: "\(key.rawValue)_timestamp") as? Date

    }
    
    static func object(_ key:AppDefaultsKeys) -> Any? {
        return UserDefaults.cloud.object(forKey: key.rawValue)
        
    }
    
    static func purge() {
        for key in UserDefaults.list() {
            if key.purgable {
                print("💀 Purged: \(key.rawValue)")
                UserDefaults.save(key, value: nil)
                
            }
            
        }
                
    }
    
}

extension Date {
    var snooze:AppSnoozeObject {
        if let weekday = Calendar.current.dateComponents([.weekday], from: self).weekday {
            switch weekday {
                case 6 : return .init(3, weekday: 2)
                case 7 : return .init(2, weekday: 2)
                default : return .init(1, weekday: weekday + 1)
            
            }
            
        }
        
        return .init(1, weekday: 2)
    
    }

    var days:Int {
        let oldest = self.compare(Date(), order: .past)
        let newest = self.compare(Date(), order: .future)
        
        guard let days = Calendar.current.dateComponents([.day], from: oldest, to:newest).day else {
            return 0
            
        }
        
        return days
        
    }
    
    func display(_ style: Date.RelativeFormatStyle.UnitsStyle = .wide) -> String {
        return self.formatted(.relative(presentation: .named, unitsStyle: style))

    }
    
    func compare(_ date:Date, order:AppTimestampCompare) -> Date {
        if order == .past {
            if self < date  {
                return self
                
            }
            
            return date
            
        }
        else {
            if self < date  {
                return date
                
            }
            
            return self
            
        }

    }
    
}

// ## TODO: ADD LANGUAGE FILE AND LOCALIZED FUNCTION!
