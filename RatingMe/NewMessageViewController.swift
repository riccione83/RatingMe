//
//  NewMessageViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 01/03/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MBProgressHUD

class NewMessageViewController: UIViewController {

    var UserInfos:User?
    var ToUser:String?
    var done:Bool = false
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var messageText: UITextField!
    
    func showMessage(message:String, detail:String?) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if (detail != nil) {
            hud.detailsLabelText = detail
        }
        hud.mode = MBProgressHUDMode.Text
        hud.dimBackground = true
        hud.hide(true, afterDelay: 2.5)
    }

    
    @IBAction func sendNewMessageClick(sender: AnyObject) {
        
        let newMessageController = NewMessageController()
        
        newMessageController.newMessageToUser((UserInfos?.userID)!, message: messageText.text!, toUser: self.ToUser!) { (result, errorMessage) -> () in
            
            if !self.done {
                self.done = true
                if result == "OK" {
                    self.showMessage("Message sent successfully.", detail: "Message sent successfully.")
                }
                else {
                    self.showMessage("Error while sending message.", detail: "Error while sending message.")
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func returnButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        labelTitle.text = labelTitle.text! + ToUser!
        done = false
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
