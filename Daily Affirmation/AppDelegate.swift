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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1014468065824783~7402067556")
        
        var notificationHour = UserDefaults.standard.integer(forKey: "notificationHour")
        var notificationMinute = UserDefaults.standard.integer(forKey: "notificationMinute")
        
        if !UserDefaults.standard.bool(forKey: "notificationTimeManuallySet") {
            notificationHour = 7
            notificationMinute = 0
        }
        
        if #available(iOS 10, *) {
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    // Notifications not allowed
                    
                    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
                    
                    center.requestAuthorization(options: options) {
                        (granted, error) in
                        if !granted {
                            // User cancelled request
                        } else {
                            self.setDailyNotification10(hour: notificationHour, minute: notificationMinute)
                        }
                    }
                } else {
                    self.setDailyNotification10(hour: notificationHour, minute: notificationMinute)
                }
            }
        } else {
            self.setDailyNotifications9(application: application, hour: notificationHour, minute: notificationMinute)
        }
        
        application.applicationIconBadgeNumber = 1
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    @available (iOS 10, *)
    func setDailyNotification10(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("NotificationTitle", comment: "NotifTitle")
        content.body = NSLocalizedString("NotificationBody", comment: "NotifBody")
        content.sound = UNNotificationSound.default()
        content.badge = 1
        
        var date = Date()
        
        date.hour = hour
        date.minute = minute
        date.second = 0

        let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
        let identifier = "DailyMorningNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }
    
    func setDailyNotifications9(application: UIApplication, hour: Int, minute: Int) {
        let notificationTypes : UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        
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
    }
}

