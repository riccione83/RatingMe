//
//  SingleMessageViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 18/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit

class SingleMessageViewController: UIViewController {

    let notificationController = RemoteNotificationController()
    
    var userInfos:User?
    var messageID:String?
    var messageFrom:String?
    var titleString:NSString?
    var bodyString:NSString?
    var messageStatus:MessageStatus?
    
    @IBOutlet var htmlBodyMessage: UIWebView!
    @IBOutlet var txtTitle: UILabel!
    @IBOutlet var txtMessageBody: UITextView!
    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func deleteMessageClick(sender: AnyObject) {
        let messageUtil = MessageController()
        
        messageUtil.deleteMessage(userInfos!.userID, message_id: messageID!) { (result, errorMessage) -> () in
            if self.messageStatus == MessageStatus.Unread {
                self.notificationController.deleteOneNotification()
            }
         self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    @IBAction func setMessageAsUnreadedClick(sender: AnyObject) {
        
        
        let uN = txtTitle.text?.componentsSeparatedByString(":")
        
        if uN?.count > 1 {
            let userName = uN![1].stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
            )
        
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("newMesageViewController") as! NewMessageViewController
            vc.UserInfos = userInfos!
            vc.ToUser = userName
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtTitle.text = titleString != nil ? titleString as! String : ""
        htmlBodyMessage.loadHTMLString(bodyString != nil ? bodyString as! String : "", baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
