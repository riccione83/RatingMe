//
//  LoginViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 20/08/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {
    
    var user:UserController = UserController()
    var delegate:ViewController?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidAppear(animated: Bool) {
        if delegate?.userInfos != nil {
            showMainView()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideLoadingHUD()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func showMessage(message:String) {
        let alert = UIAlertController(title: "RatingMe", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true) { () -> Void in
            self.hideLoadingHUD()
        }
    }
    
    @IBAction func loginWithTwitterClick(sender: AnyObject) {
        
        self.showLoadingHUD()
        
        user.signInWithTwitter({ (loggedIn,message) -> () in
            if loggedIn {
                print("Perfetto!! Effettuato login con Twitter: \(self.user.user.userName)  \(self.user.user.userID)")
                self.user.user.userLoginType = .Twitter
                 self.delegate?.saveLoginData(self.user.user)
                self.showMainView()
            }
            else
            {
                self.hideLoadingHUD()
                print("Errore. Non posso accedere a Twitter")
                self.showMessage("Unable to access with your Twitter account. Check the connection or the settings. [" + message + "]")
            }
        })
        
    }
    
    
    @IBAction func loginWithFacebookClick(sender: AnyObject) {
        
        self.showLoadingHUD()
        
        user.signInWithFacebook({ (loggedIn,message) -> () in
            if loggedIn {
                print("Perfetto!! Effettuato login con Facebook: \(self.user.user.userName)  \(self.user.user.userID)")
                self.user.user.userLoginType = .Facebook
                self.delegate?.saveLoginData(self.user.user)
                self.showMainView()
            }
            else
            {
                self.hideLoadingHUD()
                print(message)
                self.showMessage("Unable to access with your Facebook account. Check the connection or the settings. [" + message + "]")
            }
        })
        
    }
    
    @IBAction func btnAnonimousLogin(sender: AnyObject) {
        
        user.user.userLoginType = UserLoginType.Anonymous
        self.showMainView();
        
    }
    
    
    func showMainView() {
        
        self.hideLoadingHUD()
        
        if delegate?.userInfos == nil {
            delegate?.userInfos = user.user
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "loginWithCredentials") {
            let loginView = segue.destinationViewController as! LoginWithUIDViewViewController
            loginView.mainController = self
        }
        
        if (segue.identifier == "SignInWithCredentials") {
            let loginView = segue.destinationViewController as! SignInViewController
            loginView.mainController = self
        }
        
        
    }
    
    
}
