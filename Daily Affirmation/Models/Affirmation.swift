//
//  Affirmation.swift
//  Daily Affirmation
//
//  Created by Efe Helvacı on 22.10.2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import Foundation
import FTIndicator

class Affirmation {
    
    struct AffirmationStoreKeys {
        static let BannedAffirmationsKey  = "BannedAffirmations"
        static let FavoriteAffirmationKey = "FavoriteAffirmations"
        static let SeenAffirmationKey    = "SeenAffirmations"
    }
    
    var id: Int
    var clause: String
    var isFavorite: Bool {
        willSet {
            Affirmation.isChanged = true
            
            var favoriteAffirmations = UserDefaults.standard.array(forKey: AffirmationStoreKeys.FavoriteAffirmationKey) as? [Int] ?? [Int]()
            
            if newValue {
                favoriteAffirmations.append(self.id)
            } else {
                if let index = favoriteAffirmations.index(of: self.id) {
                    favoriteAffirmations.remove(at: index)
                }
            }
            
            UserDefaults.standard.set(favoriteAffirmations, forKey: AffirmationStoreKeys.FavoriteAffirmationKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var isBanned: Bool {
        willSet {
            Affirmation.isChanged = true
            
            var bannedAffirmations = UserDefaults.standard.array(forKey: AffirmationStoreKeys.BannedAffirmationsKey) as? [Int] ?? [Int]()
            
            if newValue {
                bannedAffirmations.append(self.id)
            } else {
                if let index = bannedAffirmations.index(of: self.id) {
                    bannedAffirmations.remove(at: index)
                }
            }
            
            UserDefaults.standard.set(bannedAffirmations, forKey: AffirmationStoreKeys.BannedAffirmationsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var isSeen: Bool {
        willSet {
            Affirmation.isChanged = true
            
            var seenAffirmations = UserDefaults.standard.array(forKey: AffirmationStoreKeys.SeenAffirmationKey) as? [Int] ?? [Int]()
            
            if newValue {
                seenAffirmations.append(self.id)
            } else {
                if let index = seenAffirmations.index(of: self.id) {
                    seenAffirmations.remove(at: index)
                }
            }
            
            UserDefaults.standard.set(seenAffirmations, forKey: AffirmationStoreKeys.SeenAffirmationKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    init(id: Int, clause: String, isFavorite: Bool, isBanned: Bool, isSeen: Bool) {
        self.id         = id
        self.clause     = clause
        self.isFavorite = isFavorite
        self.isBanned   = isBanned
        self.isSeen     = isSeen
    }
}

extension Affirmation {
    static fileprivate var shared: [Affirmation]?
    static fileprivate var isChanged: Bool = true
    
    static func getAffirmations(shouldUpdate update: Bool = isChanged) -> [Affirmation] {
        if let affirmations = shared, !update {
            return affirmations
        }
        
        if let plistFile = Bundle.main.path(forResource: "Affirmations", ofType: "plist"),
           let affirmationObjects = NSArray(contentsOfFile: plistFile) as? [NSDictionary]  {
            
            var affirmations = [Affirmation]()
            for affirmationObject in affirmationObjects {
                let id = affirmationObject["id"] as! Int
                let clause = affirmationObject["clause"] as! String
                var isBanned = false
                var isFavorite = false
                var isSeen = false
                
                if let bannedAffirmations = UserDefaults.standard.array(forKey: AffirmationStoreKeys.BannedAffirmationsKey) as? [Int] {
                    isBanned = bannedAffirmations.contains(id)
                }
                
                if let seenAffirmations = UserDefaults.standard.array(forKey: AffirmationStoreKeys.SeenAffirmationKey) as? [Int] {
                    isSeen = seenAffirmations.contains(id)
                }
                
                if let favoriteAffirmations = UserDefaults.standard.array(forKey: AffirmationStoreKeys.FavoriteAffirmationKey) as? [Int] {
                    isFavorite = favoriteAffirmations.contains(id)
                }
                
                affirmations.append(Affirmation(id: id, clause: clause, isFavorite: isFavorite, isBanned: isBanned, isSeen: isSeen))
            }
            
            shared = affirmations
            isChanged = false
            
            return affirmations
        }
        
        return [Affirmation]()
    }

    // Affirmations that can be shown
    class private func validAffirmations() -> [Affirmation] {
        var affirmations = getAffirmations()
        
        let isAllBanned = affirmations.reduce(true, {$0 && $1.isBanned })
        let isAllSeen   = affirmations.reduce(true, {$0 && $1.isSeen })
        
        if isAllSeen {
            print("All clauses are seen!!!")
            
            // TODO show message to notify user
            UserDefaults.standard.removeObject(forKey: AffirmationStoreKeys.SeenAffirmationKey)
            
            affirmations = getAffirmations(shouldUpdate: true)
        } else if isAllBanned {
            print("All clauses are banned!!!")
            
            // TODO show message to notify user
            UserDefaults.standard.removeObject(forKey: AffirmationStoreKeys.BannedAffirmationsKey)
            
            affirmations = getAffirmations(shouldUpdate: true)
        }
        
        return affirmations.filter{
            return !$0.isBanned && !$0.isSeen
        }
    }
    
    class public func randomAffirmation() -> Affirmation {
        let affirmations = validAffirmations()
        
        return affirmations.randomItem
    }
    
    class public func favoriteAffirmations() -> [Affirmation] {
        let affirmations = validAffirmations()
        
        return affirmations.filter { $0.isFavorite }
    }
}
