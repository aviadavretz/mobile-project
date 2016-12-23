//
//  User.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation

class User {
    var name:NSString?
    var id:NSString
    var groupId:NSString?
    
    init(id:NSString) {
        self.id = id
        name = ""
        groupId = ""
    }
    
    init(id: NSString, name: NSString) {
        self.id = id
        self.name = name
    }
}
