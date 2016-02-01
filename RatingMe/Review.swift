//
//  Review.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 01/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit

class Review: NSObject {
    var Title: String?
    var Description: String?
    var Tag: NSNumber
    var Rating: Int
    var ImageLink: String
    var ReviewID: String
    var Question1:String
    var Question2:String
    var Question3:String
    var isAdvertisement:Bool
    var advertisementImageLink:String
    var coordinate: CLLocationCoordinate2D
    
    
    init(coordinate: CLLocationCoordinate2D, title:String, description: String, tag: NSNumber, rating:Int, link:String, ID:String, Q1:String, Q2:String, Q3:String, isAdv:String, advImgLink:String)
    {
        self.coordinate = coordinate
        self.Title = title
        self.Description = description
        self.Tag = tag
        self.Rating = rating
        self.ImageLink = link
        self.ReviewID = ID
        self.Question1 = Q1
        self.Question2 = Q2
        self.Question3 = Q3
        self.isAdvertisement = isAdv.toBool()!
        self.advertisementImageLink = advImgLink
    }

}
