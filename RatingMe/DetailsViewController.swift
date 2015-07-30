//
//  DetailsViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 25/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    var FrameTitle:String?
    var Description:String?
    var Rating: String?
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var txtDescription: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if FrameTitle != nil {
            labelTitle?.text = FrameTitle
        }
        if Description != nil {
            txtDescription?.text = description
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
