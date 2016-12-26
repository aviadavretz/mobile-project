//
// Created by admin on 26/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroupListsDB {
    let groupsNode = "groups"
    let listsNode = "lists"

    var databaseRef: FIRDatabaseReference!

    init(groupKey: NSString) {
        databaseRef = FIRDatabase.database().reference(withPath: "\(groupsNode)/\(groupKey)/\(listsNode)")
    }

    func addList(listKey: NSString) {
        databaseRef.updateChildValues([listKey: true])
    }
}