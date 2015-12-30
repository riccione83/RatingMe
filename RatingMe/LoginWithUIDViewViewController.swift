//
//  LogineWithUIDViewViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 07/11/15.
//  Copyright © 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginWithUIDViewViewController: UIViewController {

    @IBOutlet var emailOrUser: UITextField!
    @IBOutlet var password: UITextField!
    let userData = UserController()
    var mainController:LoginViewController?
    var keyboardWasShowed = false
    @IBOutlet var mainScrollView: UIScrollView!
    
    func showMessage(message:String, detail:String?) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if (detail != nil) {
            hud.detailsLabelText = detail
        }
        hud.mode = MBProgressHUDMode.Text
        hud.dimBackground = true
        hud.hide(true, afterDelay: 2.5)
    }

    
    func keyboardWillShow(sender: NSNotification) {
        if !keyboardWasShowed {
            self.view.frame.origin.y -= 160
            keyboardWasShowed = true
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if keyboardWasShowed {
            self.view.frame.origin.y += 160
            keyboardWasShowed = false
        }
    }
    
    func closeKeyboard(touch:UIGestureRecognizer) {
        emailOrUser.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let touchImage: UITapGestureRecognizer = UITapGestureRecognizer()
        touchImage.addTarget(self, action: "closeKeyboard:")
        touchImage.numberOfTapsRequired = 1
        mainScrollView.addGestureRecognizer(touchImage)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnBtnClick(sender: AnyObject) {
        
    }
    @IBAction func cancelButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func loginBtnClick(sender: AnyObject) {
            if emailOrUser.text != "" &&
                password.text != "" {
                    userData.loginWithCredentials(emailOrUser.text!, password: password.text!, completitionHandler: { (success) -> () in
                        if success {
                            self.mainController?.delegate?.userInfos = self.userData.user
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            self.showMessage("Error on Login", detail: "Please check that user name or password are correct.")
                        }
                    })
            }
            else {
                self.showMessage("Error", detail: "Please insert user name and password")
        }
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