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
    var Status:MessageStatus
    var Id:NSInteger!
    
    override init() {
        self.Id = 0
        self.Message = ""
        self.longText = ""
        self.Status = .Unread
    }
    
    init(id:NSInteger,message:String,longMessage:String,status:NSInteger) {
        self.Id = id
        self.Message = message
        self.longText = longMessage
        self.Status = status == 0 ? .Unread : .Read
    }
    
}
