//
//  NewMessageController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 01/03/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewMessageController: NSObject {
    
    let jsonRequest:JSonHelper = JSonHelper()
    
    override init() {
        
    }
    
    func newMessageToUser(user_id:String, message:String, toUser:String, completitionHandler:(result:String, errorMessage:String) ->()) {
        
        let params = [ "user_id": user_id,
                       "to_user": toUser,
                       "message" : message]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_sendNewMessage, parameters: params) { (jsonData) -> () in
            
            
            if jsonData == nil {
                completitionHandler(result: "",errorMessage: "No connection")
            }
            let json = JSON(jsonData!)
            
            if let message = json["message"].string {
                print(message)
                completitionHandler(result: "",errorMessage: message)
            }
            
            completitionHandler(result: "OK" ,errorMessage: message)
        }
    }

}
