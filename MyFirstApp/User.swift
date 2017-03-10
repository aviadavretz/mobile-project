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
    var lastUpdate:NSDate?

    init(key: NSString, name: NSString?, facebookId: NSString?) {
        self.key = key
        self.name = name
        self.facebookId = facebookId
    }

    init(key: NSString, name: NSString?, facebookId: NSString?, lastUpdate: NSDate) {
        self.key = key
        self.name = name
        self.facebookId = facebookId
        self.lastUpdate = lastUpdate
    }
}
