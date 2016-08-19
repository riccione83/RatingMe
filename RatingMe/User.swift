//
//  User.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 23/10/15.
//  Copyright © 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

enum UserLoginType:String {
    case Facebook = "Facebook"
    case Twitter = "Twitter"
    case Login = "Login"
    case Anonimous = "Anonimous"
    case Unknow = "Unknow"
}

public class User {
    
    var userID: String
    var userName: String
    var userPasswordHash: String
    var userEmail: String
    var userCity: String
    var userSocialID:String
    var userLoginType:UserLoginType?
    
    
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
