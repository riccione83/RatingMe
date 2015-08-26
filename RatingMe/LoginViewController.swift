//
//  LoginViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 20/08/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var userInfos:User = User()
    var delegate:ViewController?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       activityIndicator.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMessage(message:String) {
        var alert = UIAlertController(title: "RateMe", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
    
        self.presentViewController(alert, animated: true) { () -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }
    }

    @IBAction func loginWithTwitterClick(sender: AnyObject) {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        userInfos.signInWithTwitter({ (loggedIn) -> () in
            if loggedIn {
                println("Perfetto!! Effettuato login con Twitter: \(self.userInfos.userName)  \(self.userInfos.userID)")
                self.showMainView()
            }
            else
            {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                println("Errore. Non posso accedere a Twitter")
                self.showMessage("Non posso accedere al tuo account Twitter. Verifica le impostazioni.")
            }
        })
        
    }
    
    
    @IBAction func loginWithFacebookClick(sender: AnyObject) {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        userInfos.signInWithFacebook({ (loggedIn) -> () in
            if loggedIn {
                println("Perfetto!! Effettuato login con Facebook: \(self.userInfos.userName)  \(self.userInfos.userID)")
                self.showMainView()
            }
            else
            {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                println("Errore. Non posso accedere a Facebook")
                 self.showMessage("Non posso accedere al tuo account Facebook. Verifica le impostazioni.")
            }
        })

    }
    
    func showMainView() {
        
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true

        delegate?.userInfos = userInfos
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
