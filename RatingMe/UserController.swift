//
//  UserSignIn.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 20/08/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import Accounts
import Social
import SwiftyJSON

public class UserController{
    
    var user = User()
    let loginHelper = JSonHelper()
    
    required public init() {
            self.user = User()
    }
    
    func loginWithSocial(userName:String, uid:String, provider:String, completitionHandler:(success:Bool) -> ()) {
        
        let params = [
            "user_id": uid,
            "user_name": userName,
            "provider": provider
        ]
        
        loginHelper.getJson("GET",apiUrl: loginHelper.API_loginWithSocial, parameters: params) { (jsonData) -> () in
            
            if jsonData == nil {
                completitionHandler(success: false)
            }
            else {
                let json = JSON(jsonData!)
                if let message = json["error"].string {
                    print(message)
                    completitionHandler(success: false)
                }
                else if let message = json["message"].string {
                    print(message)
                    self.user.userID = message
                    completitionHandler(success: true)
                }
                else {
                    completitionHandler(success: false)
                }
            }
        }
    }
    
    
    public func signInWithCredentials(userName:String,email:String, password:String, completitionHandler:(messages:String,success:Bool) -> ()) {
    
        let params = [
            "user_name": userName,
            "user_password_hash": password,
            "user_email": email
                     ]
        
        loginHelper.getJson("GET", apiUrl: loginHelper.API_newUser, parameters: params) { (jsonData) -> () in
            if jsonData == nil {
                completitionHandler(messages: "",success: false)
            }
            else {
                let json = JSON(jsonData!)
                if let message = json["message"].string {
                    print(message)
                    completitionHandler(messages: message,success: false)
                }
                else if let message = json["user"].string {
                    print(message)
                    self.user.userID = message
                    completitionHandler(messages: "",success: true)
                }
                else {
                    completitionHandler(messages: "",success: false)
                }
            }
        }
        
        
    }
    
    
    public func loginWithCredentials(userNameorEmail:String, password:String, completitionHandler:(success:Bool) -> ()) {
        
        let params = [
            "user_id":userNameorEmail,
            "user_password":password
        ]
        
        loginHelper.getJson("GET", apiUrl: loginHelper.API_login, parameters: params) { (jsonData) -> () in
            if jsonData == nil {
                completitionHandler(success: false)
            }
            else {
                let json = JSON(jsonData!)
                if let message = json["error"].string {
                    print(message)
                    completitionHandler(success: false)
                }
                else if let message = json["user"].string {
                    print(message)
                    self.user.userID = message
                    completitionHandler(success: true)
                }
                else {
                    completitionHandler(success: false)
                }
            }
        }
        
    }
    
    public func signInWithTwitter(onComplete: (Bool,String) -> ()) {
        
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        account.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                let allAccounts = account.accountsWithAccountType(accountType)
                if allAccounts.count > 0 {
                    
                    let twitterAccount = allAccounts.last as? ACAccount
                    
                    if let properties = twitterAccount!.valueForKey("properties") as? [String:String], user_id = properties["user_id"] {
                        self.user.userSocialID = user_id
                        self.user.userName = twitterAccount!.username as String
                        self.loginWithSocial(self.user.userName,uid: self.user.userSocialID, provider: "twitter", completitionHandler: { (success) -> () in
                            onComplete(success,"success")
                        })
                    }
                }
                else
                {
                    onComplete(false,"Unknown error.")
                }
                
            }
            else {
                print("Access denied to Twitter account")
                onComplete(false,"Access denied to Twitter account")
            }
        }
    }
    
    
    public func signInWithFacebook(onComplete: (Bool,String) -> ()) {
        
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
        
        let options = [
            "ACFacebookAppIdKey" : "907940565955155",
            "ACFacebookPermissionsKey" : ["email"],
            "ACFacebookAudienceKey" : ACFacebookAudienceOnlyMe]
        
        
        account.requestAccessToAccountsWithType(accountType, options: options as! [String : AnyObject]) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                let allAccounts = account.accountsWithAccountType(accountType)
                if allAccounts.count > 0 {
                    
                    let facebookAccount = allAccounts.last as? ACAccount
                    self.loadProfileInfo(account, account: facebookAccount!, onComplete: { (data:NSDictionary?) -> () in
                        
                        let returnedData = JSON(data!)
                        
                        if(returnedData["error"] == nil) {
                            self.user.userSocialID = data?.objectForKey("id") as! String
                            self.user.userName = facebookAccount!.userFullName as String
                            self.loginWithSocial(self.user.userName,uid: self.user.userSocialID,provider: "facebook", completitionHandler: { (success) -> () in
                                onComplete(success,"success")
                            })
                        }
                        else {
                            print(returnedData["error"]["message"])
                            onComplete(false,String(returnedData["error"]["message"]))
                        }

                    })
                }
                else
                {
                    onComplete(false,"No account found on your device")
                }
                
            }
            else {
                print("Access denied to Facebook account")
                onComplete(false,"Access denied to Facebook account")
            }
        }
    }
    
    private func loadProfileInfo(accountStore: ACAccountStore,account: ACAccount, onComplete: (NSDictionary?) -> ()) {
        let meUrl = NSURL(string: "https://graph.facebook.com/me")
        
        let slRequest = SLRequest(forServiceType: SLServiceTypeFacebook,
            requestMethod: SLRequestMethod.GET,
            URL: meUrl, parameters: nil)
        
        slRequest.account = account
        
        slRequest.performRequestWithHandler {
            (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            
            if error != nil { onComplete(nil) }
            do {
                let meData = try NSJSONSerialization.JSONObjectWithData(
                    data,
                    options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                onComplete(meData)
            }
            catch _{
                onComplete(nil)
            }
        }
    }
    
}
