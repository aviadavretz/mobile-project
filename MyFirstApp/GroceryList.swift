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
    var groupKey:NSString
    
    init(title:NSString, groupKey:NSString) {
        self.id = "-1"
        self.title = title
        self.groupKey = groupKey
        
        // This gets the current date and time at GMT+0 timezone
        self.date = NSDate()
    }

    init(id: NSString, title:NSString, date: NSDate, groupKey: NSString) {
        self.id = id
        self.title = title
        self.date = date
        self.groupKey = groupKey
    }
}
