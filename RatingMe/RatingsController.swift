//
//  RatingsController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 01/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import SwiftyJSON

class RatingsController: NSObject {
    
    func getRatingsByID(reviewID:String, completitionHandled:(rating: NSMutableArray?) -> ()) {
        
        let jsonRequest = JSonHelper()
        let params = [ "id": reviewID]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_showRatings, parameters: params) { (jsonData) -> () in
            
            let ratingResult = NSMutableArray()
            
            if jsonData == nil {
                completitionHandled(rating: NSMutableArray())
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
                print(message)
                completitionHandled(rating: NSMutableArray())
            }
            
            for (_,subJson):(String, JSON) in json {
                let rating = Rating(description: subJson[0]["description"].string!,username: subJson[0]["user_name"].string!,rate1: subJson[0]["rate1"].float!,rate2: subJson[0]["rate2"].float != nil ? subJson[0]["rate2"].float! : 0.0, rate3: subJson[0]["rate3"].float != nil ? subJson[0]["rate3"].float! : 0.0)
                
                ratingResult.addObject(rating)
            }
            completitionHandled(rating: ratingResult)
        }
    }

}
