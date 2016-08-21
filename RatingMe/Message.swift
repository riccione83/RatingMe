//
//  Message.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 14/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit

enum MessageStatus {
   case Read
   case Unread
}

class Message: NSObject {

    var Message:NSString?
    var longText:NSString?
    var messageFrom:NSString?
    var createAt:NSString?
    var Status:MessageStatus
    var Id:NSInteger!
    
    override init() {
        self.Id = 0
        self.Message = ""
        self.longText = ""
        self.messageFrom = ""
        self.createAt = ""
        self.Status = .Unread
    }
    
    init(id:NSInteger,message:String,longMessage:String,status:NSInteger, userId:NSString, createAt:String) {
        self.Id = id
        self.Message = message
        self.longText = longMessage
        self.messageFrom = userId
        self.Status = status == 0 ? .Unread : .Read
        
        let _createAt = createAt.componentsSeparatedByString(".")
        
        // create dateFormatter with UTC time format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        //dateFormatter.timeZone = NSTimeZone(name: "UTC")
        if _createAt.count > 1  {
            let date = dateFormatter.dateFromString(_createAt[0])// create   date from string
            
            // change to a readable time format and change to local time zone
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            let timeStamp = dateFormatter.stringFromDate(date!)
            
            self.createAt = timeStamp
        }
        else {
            self.createAt = ""
        }
        
    }
    
}
