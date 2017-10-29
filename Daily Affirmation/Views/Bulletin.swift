//
//  Bulletin.swift
//  Daily Affirmation
//
//  Created by Efe Helvacı on 29.10.2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import Foundation
import BulletinBoard

class Bulletin {
    static func generateNotificationBulletin(shouldAskLikeFirst likeFirst: Bool) -> BulletinManager {
        let likeBulletinItem = PageBulletinItem(title: NSLocalizedString("BeforePushNotificationTitle", comment: ""))
        let askPermissionBulletinItem = PageBulletinItem(title: NSLocalizedString("PushNotificationsTitle", comment: ""))
        let bulletinManager = BulletinManager(rootItem: likeFirst ? likeBulletinItem : askPermissionBulletinItem)
        
        likeBulletinItem.descriptionText = NSLocalizedString("BeforePushNotificationDescription", comment: "")
        likeBulletinItem.actionButtonTitle = NSLocalizedString("BeforePushNotificationApproveAction", comment: "")
        likeBulletinItem.alternativeButtonTitle = NSLocalizedString("BeforePushNotificationCancelAction", comment: "")
        likeBulletinItem.image = UIImage(named: "PushHeart")
        likeBulletinItem.isDismissable = true
        
        likeBulletinItem.actionHandler = { (item: PageBulletinItem) in
            bulletinManager.push(item: askPermissionBulletinItem)
        }
        
        likeBulletinItem.alternativeHandler = { (item: PageBulletinItem) in
            bulletinManager.dismissBulletin()
        }
        
        if #available(iOS 10, *) {
            bulletinManager.backgroundViewStyle = .blurredLight
        } else {
            bulletinManager.backgroundViewStyle = .dimmed
        }
        
        askPermissionBulletinItem.descriptionText = NSLocalizedString("PushNotificationsMessage", comment: "")
        askPermissionBulletinItem.actionButtonTitle = NSLocalizedString("PushNotificationsApproveAction", comment: "")
        askPermissionBulletinItem.alternativeButtonTitle = NSLocalizedString("PushNotificationsCancelAction", comment: "")
        askPermissionBulletinItem.image = UIImage(named: "RainbowDay")
        askPermissionBulletinItem.isDismissable = true
        
        askPermissionBulletinItem.actionHandler = { (item: PageBulletinItem) in
            AppDelegate.setDailyNotifications(hour: Options.shared.notificationTime.hour,
                                              minute: Options.shared.notificationTime.minute)
            
            bulletinManager.dismissBulletin()
        }
        
        askPermissionBulletinItem.alternativeHandler = { (item: PageBulletinItem) in
            bulletinManager.dismissBulletin()
        }
        
        bulletinManager.prepare()
        
        return bulletinManager
    }
}
