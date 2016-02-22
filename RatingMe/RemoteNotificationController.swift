//
//  RemoteNotificationController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 12/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit

class RemoteNotificationController: NSObject {
    
    var numOfNotification:NSInteger = 0

    func clearNotifications() {
        NSUserDefaults.standardUserDefaults().setObject(0, forKey: "count")
     //   NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func setNotification(numOfNotification:NSInteger) {
        NSUserDefaults.standardUserDefaults().setObject(numOfNotification, forKey: "count")
        //NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func newNotification() {
        var notificationCount = getNotificationCount()
        
        notificationCount = notificationCount! + 1
        numOfNotification++
        NSUserDefaults.standardUserDefaults().setObject(notificationCount, forKey: "count")
        
        //NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func deleteOneNotification() {
        var notificationCount = getNotificationCount()
        
        if notificationCount > 0 {
            notificationCount = notificationCount! - 1
            numOfNotification--
            NSUserDefaults.standardUserDefaults().setObject(notificationCount, forKey: "count")
           // NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func getNotificationCount() -> NSInteger? {
            if let count =  NSUserDefaults.standardUserDefaults().objectForKey("count") as? NSInteger {
                numOfNotification = count
                return count
            }
            else {
                numOfNotification = 0
                return nil
            }
    }

}
