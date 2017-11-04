//
//  Options.swift
//  Daily Affirmation
//
//  Created by Efe Helvacı on 28.10.2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import Foundation

fileprivate let defaults = UserDefaults.standard

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
        static let ApplicationLaunchCount = "ApplicationLaunchCount"
    }
    
    var notificationTime: NotificationTime {
        didSet {
            defaults.set(true, forKey: OptionsStoreKeys.DidNotificationTimeManuallySet)
            
            defaults.set(notificationTime.hour, forKey: OptionsStoreKeys.NotificationHour)
            
            defaults.set(notificationTime.minute, forKey: OptionsStoreKeys.NotificationMinute)
            
            defaults.synchronize()
            
            AppDelegate.setDailyNotifications(hour: notificationTime.hour, minute: notificationTime.minute)
        }
    }
    
    var isTextToSpeechEnabled: Bool {
        didSet {
            defaults.set(!isTextToSpeechEnabled, forKey: OptionsStoreKeys.IsTextToSpeechDisabled)
        }
    }
    
    var notificationPermissionStatus: NotificationPermissionStatus?
    
    var applicationLaunchCount: Int {
        didSet {
            defaults.set(applicationLaunchCount, forKey: OptionsStoreKeys.ApplicationLaunchCount)
        }
    }
}

extension Options {
        
    static public var shared: Options = {
        let didNotificationTimeManuallySet = defaults.bool(forKey: OptionsStoreKeys.DidNotificationTimeManuallySet)
        
        var notificationTime: NotificationTime
        if didNotificationTimeManuallySet {
            let notificationHour = defaults.integer(forKey: OptionsStoreKeys.NotificationHour)
            let notificationMinute = defaults.integer(forKey: OptionsStoreKeys.NotificationMinute)
            
            notificationTime = NotificationTime(hour: notificationHour, minute: notificationMinute)
        } else {
            notificationTime = NotificationTime()
        }
        
        let isTextToSpeechEnabled = !defaults.bool(forKey: OptionsStoreKeys.IsTextToSpeechDisabled)
        
        let applicationLaunchCount = defaults.integer(forKey: OptionsStoreKeys.ApplicationLaunchCount)
        
        let options = Options(notificationTime: notificationTime,
                              isTextToSpeechEnabled: isTextToSpeechEnabled,
                              notificationPermissionStatus: nil,
                              applicationLaunchCount: applicationLaunchCount)
        
        return options
    }()
    
    static public func setNotificationTime(_ time: NotificationTime) {
        Options.shared.notificationTime = time
    }
    
    static public func setNotificationPermission(_ permisson: NotificationPermissionStatus) {
        Options.shared.notificationPermissionStatus = permisson
        
        NotificationCenter.default.post(name: Notification.Name.OptionsUpdate, object: nil)
    }
    
    static public func setTextToSpeech(_ isEnabled: Bool) {
        Options.shared.isTextToSpeechEnabled = isEnabled
    }
    
    static public func increaseApplicationLaunchCount() {
        Options.shared.applicationLaunchCount += 1
    }
    
    static public func shouldDisplayRatePrompt() -> Bool {
        let launchCount = Options.shared.applicationLaunchCount
        
        if launchCount == 6 || launchCount % 20 == 0 {
            return true
        }
        
        return false
    }
}
