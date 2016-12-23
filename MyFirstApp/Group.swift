//
//  Group.swift
//  MyFirstApp
//
//  Created by admin on 19/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation

class Group {
    var key:NSString
    var title:NSString?
    var adminUserId:NSString
    var lists = Array<GroceryList>()
    var members = Array<NSString>()
    
    init(key: NSString, title:NSString, adminUserId: NSString, lists: Array<GroceryList>, members: Array<NSString>) {
        self.key = key
        self.title = title
        self.adminUserId = adminUserId
        self.lists = lists
        self.members = members
    }
}
