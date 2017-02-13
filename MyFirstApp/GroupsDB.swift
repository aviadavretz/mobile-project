//
//  GroupDB.swift
//  MyFirstApp
//
//  Created by admin on 23/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroupsDB {
    static let sharedInstance: GroupsDB = { GroupsDB() } ()

    let rootNode = "groups"
    let listsNode = "lists"

    var databaseRef: FIRDatabaseReference!
    var groupCache: Dictionary<NSString, Group> = Dictionary<NSString, Group>()
    
    deinit {
        self.databaseRef.removeAllObservers()
    }
    
    private init() {
        databaseRef = FIRDatabase.database().reference().child(rootNode)
    }
    
    func addGroup(groupTitle: NSString, forUserKey: NSString) {
        let values = ["title": groupTitle, "members": [forUserKey: true]] as [String : Any]
        
        let generatedKey = self.databaseRef.childByAutoId().key
        self.databaseRef.child(generatedKey).setValue(values)

        UserGroupsDB(userKey: forUserKey).addGroupToUser(groupKey: generatedKey as NSString)
    }
    
    func findGroupByKey(key: String, whenFinished: @escaping (_: Group?) -> Void) {
        if (self.groupCache[key as NSString] == nil) {
            databaseRef.child(key).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                // Make sure the group was found in the database
                if (!(snapshot.value is NSNull)) {
                    let group = self.extractGroup(key: snapshot.key, values: snapshot.value as! Dictionary<String, Any>)
                    self.groupCache[key as NSString] = group
                    
                    whenFinished(group)
                } else {
                    whenFinished(nil)
                }
            })
        }
        else {
            whenFinished(self.groupCache[key as NSString]!)
        }
    }

    private func extractGroup(key: String, values: Dictionary<String, Any>) -> Group {
        return Group(key: key as NSString, title: values["title"]! as! NSString)
    }

    func removeList(fromGroupKey: NSString, listKey: NSString) {
        databaseRef.child(fromGroupKey as String).child(listsNode).child(listKey as String).removeValue()
    }

    func addList(toGroupKey: NSString, listKey: NSString) {
        databaseRef.child(toGroupKey as String).child(listsNode).updateChildValues([listKey: true])
    }
}