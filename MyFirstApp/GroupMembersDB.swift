//
// Created by admin on 26/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroupMembersDB {
    let groupsNode = "groups"
    let membersNode = "members"

    var databaseRef: FIRDatabaseReference!
    var members: Array<User> = []

    init(groupKey: NSString) {
        databaseRef = FIRDatabase.database().reference(withPath: "\(groupsNode)/\(groupKey)/\(membersNode)")
    }

    func observeGroupMembersAddition(whenMemberAdded: @escaping (_: Int) -> Void) {
        databaseRef.observe(FIRDataEventType.childAdded, with: {(snapshot) in
            UsersDB.sharedInstance.findUserByKey(key: snapshot.key, whenFinished: {(user) in
                guard let foundUser = user else { return }

                self.members.append(foundUser)
                whenMemberAdded(self.members.count - 1)
            })
        })
    }

    func addMember(userKey: NSString) {
        databaseRef.updateChildValues([userKey : true])
    }
    
    func removeMember(userKey: String) {
        databaseRef.child(userKey).removeValue()
    }

    func removeObservers() {
        databaseRef.removeAllObservers()
    }

    func getMembersCount() -> Int {
        return members.count
    }

    func getMember(row: Int) -> User? {
        if (row < getMembersCount()) {
            return members[row]
        }

        return nil
    }
}
