//
//  AppDelegate.swift
//  Daily Affirmation
//
//  Created by Efe Helvaci on 05/02/2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FTIndicator
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1014468065824783~7402067556")

        application.applicationIconBadgeNumber = 1
        
        if #available(iOS 10.3, *), Options.shouldDisplayRatePrompt() {
            SKStoreReviewController.requestReview()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppDelegate.checkNotificationPermissionStatus()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}



extension AppDelegate {
    
    // MARK: -Notification Operations
    class func checkNotificationPermissionStatus() {
        if #available(iOS 10, *) {
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings(completionHandler: {settings in
                switch settings.authorizationStatus {
                case .authorized:
                    DispatchQueue.main.async {
                        Options.setNotificationPermission(.Authorized)
                    }
                    break
                case .denied:
                    DispatchQueue.main.async {
                        Options.setNotificationPermission(.NotAuthorized)
                    }
                    break
                case .notDetermined:
                    DispatchQueue.main.async {
                        Options.setNotificationPermission(.NotDetermined)
                    }
                    break
                }
                
                return
            })
        } else {  // #available(iOS 8, *)
            if UserDefaults.standard.bool(forKey: "NotificationPermissionAsked") {
                if let settings = UIApplication.shared.currentUserNotificationSettings {
                    if settings.types.intersection([.alert, .badge, .sound]).isEmpty {
                        Options.setNotificationPermission(.NotAuthorized)
                    } else {
                        Options.setNotificationPermission(.Authorized)
                    }
                }
            } else {
                Options.setNotificationPermission(.NotDetermined)
            }
        }
    }
    
    class func setDailyNotifications(hour: Int, minute: Int) {
        if #available(iOS 10, *) {
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            
            center.requestAuthorization(options: options) { (granted, error) in
                guard granted == true else {
                    return
                }
                
                Options.setNotificationPermission(.Authorized)
                
                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("NotificationTitle", comment: "NotifTitle")
                content.body = NSLocalizedString("NotificationBody", comment: "NotifBody")
                content.sound = UNNotificationSound.default()
                content.badge = 1
                
                var date = Date()
                
                date.hour = hour
                date.minute = minute
                date.second = 0
                
                let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second,], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
                
                let identifier = "DailyMorningNotification"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                center.add(request, withCompletionHandler: nil)
            }
        } else {
            let notificationTypes : UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            
            let application = UIApplication.shared
            
            application.registerUserNotificationSettings(notificationSettings)
            
            var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            var calendarComponents = DateComponents()
            calendarComponents.hour = hour
            calendarComponents.minute = minute
            calendarComponents.second = 0
            calendar.timeZone = TimeZone.current
            
            let dateToFire = calendar.date(from: calendarComponents)
            
            let notification:UILocalNotification = UILocalNotification()
            notification.alertTitle = NSLocalizedString("NotificationTitle", comment: "NotifTitle")
            notification.alertBody = NSLocalizedString("NotificationBody", comment: "NotifBody")
            notification.fireDate = dateToFire
            notification.repeatInterval = NSCalendar.Unit.day
            notification.applicationIconBadgeNumber = 1
            
            application.cancelAllLocalNotifications()
            application.scheduleLocalNotification(notification)
            
            UserDefaults.standard.set(true, forKey: "NotificationPermissionAsked")
        }
    }
}
