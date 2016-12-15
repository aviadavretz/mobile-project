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
    var itemName:NSString?
    var purchased:Bool
    var user:User
    
    init(user:User) {
        id = "-1"
        purchased = false
        self.user = user
    }
    
    func togglePurchased() {
        purchased = !purchased
    }
}
