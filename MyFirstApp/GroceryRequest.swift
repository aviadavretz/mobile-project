//
//  GroceryRequest.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation

class GroceryRequest {
    var id:NSString
    var itemName:NSString
    var purchased:Bool
    var userId:NSString
    
    init(id: NSString, itemName: NSString, purchased: Bool, userId: NSString) {
        self.id = id
        self.itemName = itemName
        self.purchased = purchased
        self.userId = userId
    }
}
