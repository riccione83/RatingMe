//
//  ReviewsController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 01/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class ReviewsController: NSObject {

    func getReviewsByCoordinates(latitude:String, longitude:String, radius:String, completitionHandler: (reviews: NSMutableArray?) -> ()) {
        
        let jsonRequest = JSonHelper()
        var params = [:]
        
        params = [
                "lat": "\(latitude)",
                "lon": "\(longitude)",
                "radius":"\(radius)"
            ]
        
        jsonRequest.getJson("GET",apiUrl: jsonRequest.API_showReviews, parameters: params as! [String:AnyObject]) { (jsonData) -> () in
            
            let returnedReviews:NSMutableArray = NSMutableArray()
            
            if jsonData == nil {
                return
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
                print(message)
                return
            }
            if let message = json["error"].string {
                print(message)
                return
            }
            
            for (key,subJson):(String, JSON) in json {
                let description = subJson[0]["description"].string!
                let image = subJson[0]["picture"].string ?? ""
                let latitude = subJson[0]["latitude"].double!
                let longitude = subJson[0]["longitude"].double!
                let rating = subJson[0]["point"].int!
                let title = subJson[0]["title"].string!
                let id = subJson[0]["id"].int!
                print(subJson[0]["point"])
                let reviewID = String(format: "\(id)")
                let question1 = subJson[0]["question1"].string!
                let question2 = subJson[0]["question2"].string!
                let question3 = subJson[0]["question3"].string!
                let isAdvertisement = subJson[0]["is_advertisement"].string ?? "0"
                let advertisementImageLink = subJson[0]["ad_image_link"].string ?? ""
                
                let coord:String = String(format:"{%f,%f}", latitude,longitude)
                let point = CGPointFromString(coord)
                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
                
                let tag = Int(key)! + 1
                let review = Review(coordinate: coordinate, title:title, description: description, tag: tag ,rating: rating, link: image, ID: reviewID, Q1: question1, Q2: question2, Q3: question3, isAdv: isAdvertisement, advImgLink: advertisementImageLink)
                
                returnedReviews.addObject(review)
            }
            
            completitionHandler(reviews: returnedReviews)
        }

    }
    
}
