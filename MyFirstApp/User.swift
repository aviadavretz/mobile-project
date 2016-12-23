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
    var key:NSString
    var facebookId:NSString?
    var groupKey:NSString?

    init(key: NSString, name: NSString?, facebookId: NSString?, groupKey:NSString?) {
        self.key = key
        self.name = name
        self.facebookId = facebookId
        self.groupKey = groupKey
    }
}
