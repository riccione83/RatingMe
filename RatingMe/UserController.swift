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
    
    func loginWithSocial(userID:String, completitionHandler:(success:Bool) -> ()) {
        
        let params = [
            "user_id": userID
        ]
        
        loginHelper.getJson(loginHelper.API_loginWithSocial, parameters: params) { (jsonData) -> () in
            
            if jsonData == nil {
                completitionHandler(success: false)
            }
            else {
                let json = JSON(jsonData!)
            
                if let message = json["message"].string {
                    print(message)
                    if message == "success" {
                        completitionHandler(success: true)
                    }
                    else {
                        completitionHandler(success: false)
                    }
                }
                else {
                    completitionHandler(success: false)
                }
            }
        }
    }
    
    public func signInWithTwitter(onComplete: (Bool) -> ()) {
        
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
                        self.loginWithSocial(self.user.userName, completitionHandler: { (success) -> () in
                            onComplete(success)
                        })

                    }
                }
                else
                {
                    onComplete(false)
                }
                
            }
            else {
                print("Access denied to Twitter account")
                onComplete(false)
            }
        }
    }
    
    
    public func signInWithFacebook(onComplete: (Bool) -> ()) {
        
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
                        self.user.userSocialID = data?.objectForKey("id") as! String
                        self.user.userName = facebookAccount!.username as String
                        self.loginWithSocial(self.user.userName, completitionHandler: { (success) -> () in
                            onComplete(success)
                        })

                    })
                }
                else
                {
                    onComplete(false)
                }
                
            }
            else {
                print("Access denied to Facebook account")
                onComplete(false)
            }
        }
    }
    
    private func loadProfileInfo(accountStore: ACAccountStore,account: ACAccount, onComplete: (NSDictionary?) -> ()) {
        let meUrl = NSURL(string: "https://graph.facebook.com/me")
        
        let slRequest = SLRequest(forServiceType: SLServiceTypeFacebook,
            requestMethod: SLRequestMethod.GET,
            URL: meUrl, parameters: nil)
        
        slRequest.account = account
        
      //  let myaccount = account
        
        slRequest.performRequestWithHandler {
            (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            
                if error != nil { onComplete(nil) }
                
             //   var serializationError: NSError?;
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
