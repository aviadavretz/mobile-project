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
        
        // This gets the current date
        self.date = NSDate()
    }
    
    func addRequest(request:GroceryRequest) {
        requests.append(request)
    }
}
