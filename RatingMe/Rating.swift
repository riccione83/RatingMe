//
//  Rating.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 01/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit

class Rating: NSObject {
    
    var Description:String?
    var userName:String?
    var rate1:Float?
    var rate2:Float?
    var rate3:Float?
    
    override init() {
        
    }
    
    init(description:String, username:String, rate1:Float, rate2:Float, rate3:Float) {
        self.Description = description
        self.userName = username
        self.rate1 = rate1
        self.rate2 = rate2
        self.rate3 = rate3
    }
    
}
