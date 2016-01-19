//
//  EULAViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 14/01/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MBProgressHUD

class EULAViewController: UIViewController {

    let eulaWebSite:String = "http://www.ratingme.eu/eula"
    
    @IBOutlet var webViewEula: UIWebView!
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading data..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    @IBAction func btnAccept(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject("1", forKey: "loginData.EULA")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webViewEula.delegate = self
        let url:NSURL = NSURL(string: eulaWebSite)!
        let requestObj:NSURLRequest = NSURLRequest(URL: url)
        webViewEula.loadRequest(requestObj)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension EULAViewController: UIWebViewDelegate {
    func webViewDidStartLoad(webView: UIWebView) {
        self.showLoadingHUD()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        self.hideLoadingHUD()
    }
}
