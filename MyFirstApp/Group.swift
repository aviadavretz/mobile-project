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
    var adminUserId:NSString
    var lists = Array<GroceryList>()
    var members = Array<NSString>()
    
    init(title:NSString, adminUserId: NSString, lists: Array<GroceryList>, members: Array<NSString>) {
        self.id = "-1"
        self.title = title
        self.adminUserId = adminUserId
        self.lists = lists
        self.members = members
    }
    
    init(id: NSString, title:NSString, adminUserId: NSString, lists: Array<GroceryList>, members: Array<NSString>) {
        self.id = id
        self.title = title
        self.adminUserId = adminUserId
        self.lists = lists
        self.members = members
    }
    
//    func addList(list:GroceryList) {
//        lists.append(list)
//    }
//
//    func addMember(userId:NSString) {
//        members.append(userId)
//    }
}
