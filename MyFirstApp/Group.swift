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
    var lists = Array<NSString>()
    var members = Array<NSString>()
    
    init(key: NSString, title:NSString, lists: Array<NSString>, members: Array<NSString>) {
        self.key = key
        self.title = title
        self.lists = lists
        self.members = members
    }
}
