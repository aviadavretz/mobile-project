//
// Created by admin on 25/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserGroupsDB {
    let usersNode = "users"
    let groupsNode = "groups"

    var databaseRef: FIRDatabaseReference!
    var groups: Array<Group> = []

    init(userKey: NSString) {
        databaseRef = FIRDatabase.database().reference(withPath: "\(usersNode)/\(userKey)/\(groupsNode)")
    }

    func observeUserGroupsAddition(whenGroupAdded: @escaping (_: Int) -> Void) {
        databaseRef.observe(FIRDataEventType.childAdded, with: {(snapshot) in
            GroupFirebaseDB.sharedInstance.findGroupByKey(key: snapshot.key, whenFinished: {(group) in
                guard let foundGroup = group else { return }

                self.groups.append(foundGroup)
                whenGroupAdded(self.groups.count - 1)
            })
        })
    }

    func observeUserGroupsDeletion(whenGroupDeleted: @escaping (_: Int, _: Group) -> Void) {
        databaseRef.observe(FIRDataEventType.childRemoved, with: {(snapshot) in
            guard let groupIndex = self.findGroupIndexByKey(groupKey: snapshot.key as NSString) else { return }

            let removedGroup = self.groups.remove(at: groupIndex)
            whenGroupDeleted(groupIndex, removedGroup)
        })
    }

    private func findGroupIndexByKey(groupKey: NSString) -> Int? {
        return groups.index(where: {$0.key == groupKey})
    }

    func addGroupToUser(groupKey: NSString) {
        databaseRef.updateChildValues([groupKey : true])
    }
    
    func removeGroupFromUser(groupKey: String) {
        databaseRef.child(groupKey).removeValue()
    }

    func removeObservers() {
        databaseRef.removeAllObservers()
    }

    func getGroupsCount() -> Int {
        return groups.count
    }

    func getGroup(row: Int) -> Group? {
        if (row < getGroupsCount()) {
            return groups[row]
        }

        return nil
    }

    func findFirstGroup(whenFound: @escaping (_: Group?) -> Void) {
        databaseRef.queryLimited(toFirst: 1).observeSingleEvent(of: FIRDataEventType.childAdded, with: {(snapshot) in
                    if !(snapshot.value is NSNull) {
                        GroupFirebaseDB.sharedInstance.findGroupByKey(key: snapshot.key, whenFinished: { (group) in
                            whenFound(group)
                        })
                    }
                })
    }
}
