//
//  ParkAnnotation.swift
//  JustParkTechnicalTest
//
//  Created by Riccardo Rizzo on 19/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

class PinAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var userName: String?
    var Tag: NSNumber
    var Rating: Int
    var ImageLink: String
    var ReviewID: String
    var Question1:String
    var Question2:String
    var Question3:String
    var isAdvertisement:Bool
    var advertisementImageLink:String
    var category:Category?
    
    init(coordinate: CLLocationCoordinate2D, title:String, subtitle: String, tag: NSNumber, rating:Int, link:String, ID:String, Q1:String, Q2:String, Q3:String, isAdv:String, advImgLink:String, category:Category?, user_name:String) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.userName = user_name
        self.Tag = tag
        self.Rating = rating
        self.ImageLink = link
        self.ReviewID = ID
        self.Question1 = Q1
        self.Question2 = Q2
        self.Question3 = Q3
        self.isAdvertisement = isAdv.toBool()!
        self.advertisementImageLink = advImgLink
        self.category = category
    }    
}
