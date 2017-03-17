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
    var userKey: NSString

    init(userKey: NSString) {
        self.userKey = userKey
        databaseRef = FIRDatabase.database().reference(withPath: "\(usersNode)/\(userKey)/\(groupsNode)")
    }

    func observeUserGroupsAddition(whenGroupAdded: @escaping (Int) -> Void) {
        // TODO: REVERT.
        // Observe all records from remote
        databaseRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            self.handleUserGroupAddition(groupKey: snapshot.key, whenGroupAdded: whenGroupAdded)
        })
        
//        // Get the last-update time in the local db
//        let localUpdateTime = LastUpdateTable.getLastUpdateDate(database: LocalDb.sharedInstance?.database,
//                                                                table: UserGroupsTable.TABLE,
//                                                                
//                                                                // TODO: What is supposed to be here?
//                                                                key: UserGroupsTable.USER_KEY)
//        
//        if (localUpdateTime != nil) {
//            let nsUpdateTime = localUpdateTime as NSDate?
//            
//            // Get the relevant records from the remote
//            let fbQuery = databaseRef.queryOrdered(byChild:"lastUpdated").queryStarting(atValue: nsUpdateTime!.toFirebase())
//            fbQuery.observe(FIRDataEventType.childAdded, with: { (snapshot) in
//                self.handleUserGroupAddition(groupKey: snapshot.key, whenGroupAdded: whenGroupAdded)
//                
//                self.addGroupToLocal(groupKey: snapshot.key)
//            })
//            
//            // TODO: This is supposed to happen in a different thread?
//            
//            // Get the up-to-date records from the local
//            let localGroupsKeys = UserGroupsTable.getGroupKeysByUserKey(database: LocalDb.sharedInstance?.database,
//                                                                        userKey: userKey as String)
//            
//            // Handle each local record
//            for groupKey in localGroupsKeys {
//                self.handleUserGroupAddition(groupKey: groupKey, whenGroupAdded: whenGroupAdded)
//            }
//        }
//        else {
//            // Observe all records from remote
//            databaseRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
//                self.handleUserGroupAddition(groupKey: snapshot.key, whenGroupAdded: whenGroupAdded)
//                
//                self.addGroupToLocal(groupKey: snapshot.key)
//            })
//        }
    }
    
    private func addGroupToLocal(groupKey: String) {
        // Add the updated record to the local database
        UserGroupsTable.addGroupKeyForUser(database: LocalDb.sharedInstance?.database, userKey: self.userKey as String, groupKey: groupKey)
        
        // TODO: What about users that left groups? No update time for that
        
        // Update the local update time
        LastUpdateTable.setLastUpdate(database: LocalDb.sharedInstance?.database,
                                      table: UserGroupsTable.TABLE,
                                      
                                      // TODO: What is supposed to be here?
                                      key: UserGroupsTable.USER_KEY,
                                      lastUpdate: Date())
    }
    
    private func handleUserGroupAddition(groupKey: String, whenGroupAdded: @escaping (Int) -> Void) {
        // Retrieve the group object
        GroupsDB.sharedInstance.findGroupByKey(key: groupKey, whenFinished: {(group) in
            guard let foundGroup = group else { return }
            
            self.groups.append(foundGroup)
            
            // Checking index explicitly - For multithreading safety
            let newGroupIndex = self.groups.index(where: { $0.key == foundGroup.key })
            whenGroupAdded(newGroupIndex!)
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
                        GroupsDB.sharedInstance.findGroupByKey(key: snapshot.key, whenFinished: { (group) in
                            whenFound(group)
                        })
                    }
                })
    }
}
