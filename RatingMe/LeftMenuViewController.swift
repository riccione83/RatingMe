//
//  LeftMenuViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 05/10/15.
//  Copyright © 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class LeftCustomCEll: UITableViewCell {
    
    @IBOutlet var Title: UILabel!
    
}


class LeftMenuViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
   
    @IBOutlet var leftMenuTableView: UITableView!
    var delegate:ViewController?
    let menuItem = ["New Review","Messages","Map Type","Logout"]
    let notification = RemoteNotificationController()

    override func viewDidAppear(animated: Bool) {
        let layer = self.view.layer
        
        //layer.cornerRadius = 5
        //layer.masksToBounds = true
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5
        
        leftMenuTableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItem.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = leftMenuTableView.dequeueReusableCellWithIdentifier("Cell") as! LeftCustomCEll
        
        cell.Title.text = menuItem[indexPath.row]
        
        if indexPath.row == 1 {
            let numOfMessage = notification.getNotificationCount()!
            if numOfMessage > 0 {
                cell.Title.text?.appendContentsOf(" (\(numOfMessage))")
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Selected menu item: #\(indexPath.row)")
        switch indexPath.row {
            case 3: delegate?.logoutClick(self)
            case 0: delegate?.performSegueWithIdentifier("ReviewSegue", sender: nil)
            case 2: delegate?.swapMapType()
            case 1: delegate?.showMessageView()
            default: self.closeLeft()
        }
        
        self.closeLeft()
    }
    

}
