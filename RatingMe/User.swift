//
//  User.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 23/10/15.
//  Copyright © 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

enum UserLoginType {
    case Facebook
    case Twitter
    case Login
    case Anonimous
    case Unknow
}

public class User {
    
    var userID: String
    var userName: String
    var userPasswordHash: String
    var userEmail: String
    var userCity: String
    var userSocialID:String
    var userLoginType:UserLoginType
    
    
    required public init() {
        self.userID = ""
        self.userName = ""
        self.userCity = ""
        self.userEmail = ""
        self.userPasswordHash = ""
        self.userSocialID = ""
        self.userLoginType = .Unknow
    }
}
