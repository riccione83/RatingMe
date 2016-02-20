//
//  RemoteNotificationController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 12/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit

class RemoteNotificationController: NSObject {

    func clearNotifications() {
        NSUserDefaults.standardUserDefaults().setObject(0, forKey: "count")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func newNotification() {
        var notificationCount = getNotificationCount()
        
        notificationCount = notificationCount! + 1
        NSUserDefaults.standardUserDefaults().setObject(notificationCount, forKey: "count")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getNotificationCount() -> NSInteger? {
            if let count =  NSUserDefaults.standardUserDefaults().objectForKey("count") as? NSInteger {
                return count
            }
            else {
                return 0
            }
    }

}
