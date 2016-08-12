//
//  Category.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 27/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit


class Category: NSObject {
    
    var catDescription:NSString?
    var id:NSString?
    var imageLink:NSString?
    var imageThumb: CustomImageView!
    
    init(description: NSString, id:NSString, image:NSString) {
        super.init()
        self.catDescription = description
        self.id = id
        self.imageLink = image
        self.imageThumb = CustomImageView(frame: CGRectMake(0, 0, 32, 32))
    }

    
}
