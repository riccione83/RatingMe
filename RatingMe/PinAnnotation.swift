//
//  ParkAnnotation.swift
//  JustParkTechnicalTest
//
//  Created by Riccardo Rizzo on 19/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    var Tag: NSNumber
    var Rating: String
    var ImageLink: String
    var ReviewID: String
    var Question1:String
    var Question2:String
    var Question3:String
    
    init(coordinate: CLLocationCoordinate2D, title:String, subtitle: String, tag: NSNumber, rating:String, link:String, ID:String, Q1:String, Q2:String, Q3:String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.Tag = tag
        self.Rating = rating
        self.ImageLink = link
        self.ReviewID = ID
        self.Question1 = Q1
        self.Question2 = Q2
        self.Question3 = Q3
    }    
}
