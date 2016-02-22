//
//  MessagesViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 14/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import SWTableViewCell

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate {

    @IBOutlet var messageTable: UITableView!
    
    let notificationController = RemoteNotificationController()
    var messages = NSMutableArray()
    var userInfo:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        let messageController:MessageController = MessageController()
        
        messageController.getMessages(userInfo!.userID) { (result, errorMessage) -> () in
            print(result)
            self.messages = result
            self.messageTable.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    func deleteHTMLFromString(string:String) -> String {
        
        let splittedStr =  string.componentsSeparatedByString("<")
        
        return splittedStr[0] + "..."
    }
    
    func openMessage(message:Message) {
        
        let messageUtil = MessageController()
        
        messageUtil.setMessageAsReaded(userInfo!.userID, message_id: String("\(message.Id)")) { (result, errorMessage) -> () in
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("singleMessageView") as! SingleMessageViewController
        vc.titleString = message.Message
        vc.bodyString = message.longText
        vc.messageID = String("\(message.Id)")
        vc.messageStatus = message.Status
        vc.userInfos = userInfo
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let message = self.messages[indexPath.row]
            openMessage(message as! Message)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MessageTableViewCell
        
        
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        cell.delegate = self
        
        cell.messageText.text = (messages[indexPath.row] as! Message).Message! as String
        cell.unreadedIcon.hidden = (messages[indexPath.row] as! Message).Status == MessageStatus.Unread ? false : true
        cell.messageID = String("\((messages[indexPath.row] as! Message).Id)")
        cell.messageStatus = (messages[indexPath.row] as! Message).Status
        cell.longMessageText.text = deleteHTMLFromString((messages[indexPath.row] as! Message).longText! as String)
        
        cell.unreadedIcon.clipsToBounds = true
        cell.unreadedIcon.layer.cornerRadius = cell.unreadedIcon.bounds.size.width/2;
        cell.unreadedIcon.layer.borderColor = UIColor.whiteColor().CGColor
        cell.unreadedIcon.layer.borderWidth = 5.0

        // Configure the cell...

        return cell
    }
    
    func rightButtons() -> NSArray {
        let rightUtilityButtons = NSMutableArray()
        
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(colorLiteralRed: 0.78, green: 0.78, blue: 0.8, alpha: 1.0), title: "Set as Readed")
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(colorLiteralRed: 1.0, green: 0.231, blue: 0.188, alpha: 1.0), title: "Delete")
        return rightUtilityButtons
    }
    
    func setMessageAsReaded(message_id:String, status:MessageStatus) {
        let messageUtil = MessageController()
        
        if status == MessageStatus.Unread {
            self.notificationController.deleteOneNotification()
        }
        
        messageUtil.setMessageAsReaded(userInfo!.userID, message_id: message_id) { (result, errorMessage) -> () in
            self.messages = result
            self.messageTable.reloadData()
        }
    }
    
    func deleteMessage(message_id:String, status:MessageStatus) {
        let messageUtil = MessageController()
        
        if status == MessageStatus.Unread {
            self.notificationController.deleteOneNotification()
        }
        messageUtil.deleteMessage(userInfo!.userID, message_id: message_id) { (result, errorMessage) -> () in
            self.messages = result
            self.messageTable.reloadData()
        }
    }
    
    
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        let c = cell as! MessageTableViewCell
        switch index {
        case 0: print("Set read a message: \(c.messageID)")
                setMessageAsReaded(c.messageID!,status: c.messageStatus)
        case 1: print("Cancel a message")
                deleteMessage(c.messageID!,status: c.messageStatus)
        default: print("Nothig")
        }
        
    }
    
    @IBAction func closeMessageView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
