//
//  Options.swift
//  Daily Affirmation
//
//  Created by Efe Helvacı on 28.10.2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let OptionsUpdate = Notification.Name("OptionsUpdate")
}

enum NotificationPermissionStatus {
    case Authorized
    case NotAuthorized
    case NotDetermined
}

struct NotificationTime {
    let hour: Int
    let minute: Int
    
    init(hour: Int = 7, minute: Int = 30) {
        self.hour = hour
        self.minute = minute
    }
}

struct Options {
    
    struct OptionsStoreKeys {
        static let DidNotificationTimeManuallySet = "notificationTimeManuallySet"
        static let NotificationHour = "notificationHour"
        static let NotificationMinute = "notificationMinute"
        static let IsTextToSpeechDisabled = "textToSpeechDisabled"
    }
    
    var notificationTime: NotificationTime {
        didSet {
            UserDefaults.standard.set(true, forKey: OptionsStoreKeys.DidNotificationTimeManuallySet)
            
            UserDefaults.standard.set(notificationTime.hour, forKey: OptionsStoreKeys.NotificationHour)
            
            UserDefaults.standard.set(notificationTime.minute, forKey: OptionsStoreKeys.NotificationMinute)
            
            UserDefaults.standard.synchronize()
            
            AppDelegate.setDailyNotifications(hour: notificationTime.hour, minute: notificationTime.minute)
        }
    }
    
    var isTextToSpeechEnabled: Bool {
        didSet {
            UserDefaults.standard.set(!isTextToSpeechEnabled, forKey: OptionsStoreKeys.IsTextToSpeechDisabled)
        }
    }
    
    var notificationPermissionStatus: NotificationPermissionStatus? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.OptionsUpdate, object: nil)
        }
    }
}

extension Options {
    static private var sharedInstance: Options!
    
    static public var shared: Options {
        if let _ = sharedInstance {
            return sharedInstance
        }
        
        let didNotificationTimeManuallySet = UserDefaults.standard.bool(forKey: OptionsStoreKeys.DidNotificationTimeManuallySet)
        
        var notificationTime: NotificationTime
        if didNotificationTimeManuallySet {
            let notificationHour = UserDefaults.standard.integer(forKey: OptionsStoreKeys.NotificationHour)
            let notificationMinute = UserDefaults.standard.integer(forKey: OptionsStoreKeys.NotificationMinute)
            
            notificationTime = NotificationTime(hour: notificationHour, minute: notificationMinute)
        } else {
            notificationTime = NotificationTime()
        }
        
        let isTextToSpeechEnabled = !UserDefaults.standard.bool(forKey: OptionsStoreKeys.IsTextToSpeechDisabled)
        
        let options = Options(notificationTime: notificationTime,
                              isTextToSpeechEnabled: isTextToSpeechEnabled,
                              notificationPermissionStatus: nil)
        
        Options.sharedInstance = options
        
        return options
    }
    
    static public func setNotificationTime(_ time: NotificationTime) {
        Options.sharedInstance = shared
        
        Options.sharedInstance.notificationTime = time
    }
    
    static public func setNotificationPermission(_ status: NotificationPermissionStatus) {
        Options.sharedInstance = shared
        
        Options.sharedInstance.notificationPermissionStatus = status
    }
    
    static public func setTextToSpeech(_ isEnabled: Bool) {
        Options.sharedInstance = shared
        
        Options.sharedInstance.isTextToSpeechEnabled = isEnabled
    }
}
