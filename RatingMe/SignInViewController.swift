//
//  SignInViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 09/11/15.
//  Copyright © 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var userName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var passwordConfirmation: UITextField!
    let userDataSignIn = UserController()
    var mainController:LoginViewController?
    var keyboardWasShowed = false
    
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
        userName.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        passwordConfirmation.resignFirstResponder()
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
    
    @IBAction func signInButtonClick(sender: AnyObject) {
        
        if (userName.text == "") ||
           (email.text == "") ||
           (password.text == "") ||
            (passwordConfirmation.text == "") {
                self.showMessage("Error", detail: "Please insert all values for sign in")
                return
        }
        
        if (password.text != passwordConfirmation.text) {
            self.showMessage("Error in password", detail: "The password field and password confirmation doesn't match")
            return
        }
    
        userDataSignIn.signInWithCredentials(userName.text!, email: email.text!, password: password.text!) { (message, success) -> () in
            if success {
                self.mainController?.delegate?.userInfos = self.userDataSignIn.user
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                if message != "" {
                    self.showMessage("Error on Sign In", detail: message)
                }
            }
        }
    }

    @IBAction func cancelButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
