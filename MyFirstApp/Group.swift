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
    
    init(key: NSString, title:NSString) {
        self.key = key
        self.title = title
    }
}
