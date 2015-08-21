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

public class User{
    
    var userID:String
    var userName:String
    
    
    required public init() {
            self.userID = ""
            self.userName = ""
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
                        self.userID = user_id
                        self.userName = twitterAccount!.username as String
                        onComplete(true)
                    }
                }
                else
                {
                    onComplete(false)
                }
                
            }
            else {
                println("Access denied to twitter account")
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
                        self.userID = data?.objectForKey("id") as! String
                        self.userName = facebookAccount!.username as String
                        onComplete(true)
                    })
                }
                else
                {
                    onComplete(false)
                }
                
            }
            else {
                println("Access denied to twitter account")
                onComplete(false)
            }
        }
    }
    
    private func loadProfileInfo(accountStore: ACAccountStore,account: ACAccount, onComplete: (NSDictionary?) -> ()) {
        var meUrl = NSURL(string: "https://graph.facebook.com/me")
        
        var slRequest = SLRequest(forServiceType: SLServiceTypeFacebook,
            requestMethod: SLRequestMethod.GET,
            URL: meUrl, parameters: nil)
        
        slRequest.account = account
        
        let myaccount = account
        
        slRequest.performRequestWithHandler {
            (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            
                if error != nil { onComplete(nil) }
                
                var serializationError: NSError?;
                
                let meData = NSJSONSerialization.JSONObjectWithData(
                    data,
                    options: NSJSONReadingOptions.MutableContainers,
                    error: &serializationError) as? NSDictionary
                
                onComplete(meData)
        }
    }
    
}
