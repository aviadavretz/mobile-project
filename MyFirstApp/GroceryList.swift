//
//  GroceryList.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation

class GroceryList {
    var id:NSString
    var title:NSString
    var date:NSDate
    var requests = Array<GroceryRequest>()
    
    init(title:NSString) {
        self.id = "-1"
        self.title = title
        
        // This gets the current date and time at GMT+0 timezone
        self.date = NSDate()
    }

    init(id: NSString, title:NSString, date: NSDate) {
        self.id = id
        self.title = title
        self.date = date
    }
    
    func addRequest(request:GroceryRequest) {
        requests.append(request)
    }
}
