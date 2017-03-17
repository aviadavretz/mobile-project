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
    var group: Group

    init(group: Group) {
        self.group = group
        databaseRef = FIRDatabase.database().reference(withPath: "\(groupsNode)/\(group.key)/\(membersNode)")
    }

    func observeGroupMembersAddition(whenMemberAdded: @escaping (Int) -> Void) {
        // Get the last-update time in the local db
        let localUpdateTime = LastUpdateTable.getLastUpdateDate(database: LocalDb.sharedInstance?.database,
                                                                table: GroupMembersTable.TABLE,
                                                                key: group.key as String)
        
        if (localUpdateTime != nil) {
            let nsUpdateTime = localUpdateTime as NSDate?
            
            // Get the relevant records from the remote
            let fbQuery = databaseRef.queryOrdered(byChild:"lastUpdated").queryStarting(atValue: nsUpdateTime!.toFirebase())
            fbQuery.observe(FIRDataEventType.childAdded, with: { (snapshot) in
                self.handleGroupMemberAddition(userKey: snapshot.key, whenMemberAdded: whenMemberAdded)
                
                self.addUserToLocal(userKey: snapshot.key)
            })
            
            // TODO: This is supposed to happen in a different thread?
            
            // Get the up-to-date records from the local
            let localUsersKeys = GroupMembersTable.getUserKeysByGroupKey(database: LocalDb.sharedInstance?.database,
                                                                       groupKey: group.key as String)
            
            // Handle each local record
            for userKey in localUsersKeys {
                handleGroupMemberAddition(userKey: userKey, whenMemberAdded: whenMemberAdded)
            }
        }
        else {
            // Observe all records from remote
            databaseRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
                self.handleGroupMemberAddition(userKey: snapshot.key, whenMemberAdded: whenMemberAdded)
                
                self.addUserToLocal(userKey: snapshot.key)
            })
        }
    }
    
    private func addUserToLocal(userKey: String) {
        // Add the updated record to the local database
        GroupMembersTable.addUserToGroup(
                database: LocalDb.sharedInstance?.database, userKey: userKey, groupKey: self.group.key as String)
        
        // TODO: What about users that left groups? No update time for that
        
        // Update the local update time
        LastUpdateTable.setLastUpdate(database: LocalDb.sharedInstance?.database,
                                      table: GroupMembersTable.TABLE,
                                      
                                      // TODO: What is supposed to be here?
                                      key: GroupMembersTable.GROUP_KEY,
                                      lastUpdate: Date())
    }
    
    private func handleGroupMemberAddition(userKey: String, whenMemberAdded: @escaping (Int) -> Void) {
        // Retrieve the user object
        UsersDB.sharedInstance.findUserByKey(key: userKey, whenFinished: {(user) in
            guard let foundUser = user else { return }
            
            self.members.append(foundUser)
            
            // Checking index explicitly - For multithreading safety
            let newUserIndex = self.members.index(where: { $0.key == foundUser.key })
            whenMemberAdded(newUserIndex!)
        })
    }

    func findGroupMembersCount(whenFound: @escaping (_: Int) -> Void) {
        databaseRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
                    if (!snapshot.exists()) {
                        whenFound(0)
                    }
                    else {
                        whenFound(Int(snapshot.childrenCount))
                    }
                })
    }

    func addMember(userKey: NSString) {
        databaseRef.updateChildValues([userKey : true, "lastUpdateDate": FIRServerValue.timestamp()])
    }
    
    func removeMember(userKey: String) {
        databaseRef.updateChildValues(["lastUpdateDate": FIRServerValue.timestamp()])
        databaseRef.child(userKey).removeValue(completionBlock: { (_,_) in self.deleteGroupIfEmpty()})
    }

    private func deleteGroupIfEmpty() {
        self.findGroupMembersCount(whenFound: { (count) in
            if (count == 0) {
                GroupsDB.sharedInstance.deleteGroup(key: self.group.key)
            }
        })
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
