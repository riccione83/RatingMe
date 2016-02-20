//
//  MessageController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 14/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import SwiftyJSON

class MessageController: NSObject {
    
    let jsonRequest:JSonHelper = JSonHelper()
    
    override init() {
        
    }
    
    func setMessageAsUnreaded(user_id:String, message_id:String, completitionHandler:(result:NSMutableArray, errorMessage:String) ->()) {
        let params = [ "user_id": user_id,
            "message_id" : message_id]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_setMessageUnread, parameters: params) { (jsonData) -> () in
            
            let messages = NSMutableArray()
            
            if jsonData == nil {
                completitionHandler(result: NSMutableArray(),errorMessage: "No connection")
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
                print(message)
                completitionHandler(result: NSMutableArray(),errorMessage: message)
            }
            
            for (_,subJson):(String, JSON) in json {
                print(subJson)
                let message = Message(id: subJson["id"].int!,message: subJson["message"].string!,longMessage: subJson["long_text"].string!,status: subJson["status"].int!)
                messages.addObject(message)
            }
            completitionHandler(result:messages, errorMessage: "")
        }
    }
    
    func setMessageAsReaded(user_id:String, message_id:String, completitionHandler:(result:NSMutableArray, errorMessage:String) ->()) {
        let params = [ "user_id": user_id,
                       "message_id" : message_id]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_setMessageReaded, parameters: params) { (jsonData) -> () in
            
            let messages = NSMutableArray()
            
            if jsonData == nil {
                completitionHandler(result: NSMutableArray(),errorMessage: "No connection")
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
                print(message)
                completitionHandler(result: NSMutableArray(),errorMessage: message)
            }
            
            for (_,subJson):(String, JSON) in json {
                print(subJson)
                let message = Message(id: subJson["id"].int!,message: subJson["message"].string!,longMessage: subJson["long_text"].string!,status: subJson["status"].int!)
                messages.addObject(message)
            }
            completitionHandler(result:messages, errorMessage: "")
        }
    }
    
    func deleteMessage(user_id:String, message_id:String, completitionHandler:(result:NSMutableArray, errorMessage:String) ->()) {
        let params = [ "user_id": user_id,
            "message_id" : message_id]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_deleteMessage, parameters: params) { (jsonData) -> () in
            
            let messages = NSMutableArray()
            
            if jsonData == nil {
                completitionHandler(result: NSMutableArray(),errorMessage: "No connection")
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
                print(message)
                completitionHandler(result: NSMutableArray(),errorMessage: message)
            }
            
            for (_,subJson):(String, JSON) in json {
                print(subJson)
                let message = Message(id: subJson["id"].int!,message: subJson["message"].string!,longMessage: subJson["long_text"].string!,status: subJson["status"].int!)
                messages.addObject(message)
            }
            completitionHandler(result:messages, errorMessage: "")
        }
    }
    
    func getMessages(user_id:String, completitionHandler:(result:NSMutableArray,errorMessage:String) ->()) {
        
        let params = [ "user_id": user_id]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_getMessages, parameters: params) { (jsonData) -> () in
            
            let messages = NSMutableArray()
            
            if jsonData == nil {
                completitionHandler(result: NSMutableArray(),errorMessage: "No connection")
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
                print(message)
                completitionHandler(result: NSMutableArray(),errorMessage: message)
            }
            
            for (_,subJson):(String, JSON) in json {
                print(subJson)
                let message = Message(id: subJson["id"].int!,message: subJson["message"].string!,longMessage: subJson["long_text"].string!,status: subJson["status"].int!)
                messages.addObject(message)
            }
            completitionHandler(result:messages, errorMessage: "")
        }
    }
    
}
