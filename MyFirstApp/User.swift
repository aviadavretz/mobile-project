//
//  User.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation

class User {
    var firstName:NSString?
    var lastName:NSString?
    var id:NSString
    
    init(id:NSString) {
        self.id = id
        firstName = ""
        lastName = ""
    }
    
    init(id: NSString, firstName: NSString, lastName: NSString) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
