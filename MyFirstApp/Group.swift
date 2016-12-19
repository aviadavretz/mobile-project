//
//  Group.swift
//  MyFirstApp
//
//  Created by admin on 19/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation

class Group {
    var id:NSString
    var title:NSString?
    var admin:User
    var lists = Array<GroceryList>()
    
    init(id: NSString, title:NSString, admin: User) {
        self.id = id
        self.title = title
        self.admin = admin
    }
    
    func addList(list:GroceryList) {
        lists.append(list)
    }
}
