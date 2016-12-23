//
//  GroupDB.swift
//  MyFirstApp
//
//  Created by admin on 23/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroupFirebaseDB {
    static let sharedInstance: GroupFirebaseDB = { GroupFirebaseDB() } ()
    let rootNode = "groups"
    var databaseRef: FIRDatabaseReference!
    
    // This array holds the userIds of all the group members
    var groupMembers: Array<NSString> = []
    
    // This variable is the cache for groups
    var myGroup:Group? = nil
    
    deinit {
        self.databaseRef.child(rootNode).removeAllObservers()
    }
    
    private init() {
        databaseRef = FIRDatabase.database().reference()
        observeChildAddition()
        observeChildDeletion()
    }
    
    private func observeChildAddition() {
        databaseRef.child(rootNode).observe(FIRDataEventType.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else {return }
            strongSelf.groupMembers.append(snapshot.key as NSString)
            
            strongSelf.notifyChanges()
        })
    }
    
    private func observeChildDeletion() {
        databaseRef.child(rootNode).observe(FIRDataEventType.childRemoved, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else {return }
            strongSelf.groupMembers.remove(at: strongSelf.getSnapshotIndex(key: snapshot.key as String)!)
            
            strongSelf.notifyChanges()
        })
    }
    
    func addMember(userId:NSString) {
        if (myGroup != nil) {
            self.databaseRef.child(rootNode).child(myGroup?.id as! String).childByAutoId().setValue(userId)
        }
    }
    
    func addGroup(group:Group) {
        let values = loadValues(from: group)
        
        self.databaseRef.child(rootNode).childByAutoId().setValue(values)
        
        self.myGroup = group
    }
    
    private func getSnapshotIndex(key: String) -> Int? {
        return groupMembers.index(where: { $0 as String == key })
    }
    
    private func notifyChanges() {
        NotificationCenter.default.post(name: NSNotification.Name("groupMembersModelChanged"), object: nil)
    }
    
    private func loadValues(from: Group) -> Dictionary<String, Any> {
        var values = Dictionary<String, Any>()
//        values["id"] = from.id as String
        values["title"] = from.title as String?
        values["adminUserId"] = from.adminUserId as String
        values["lists"] = from.lists
        values["members"] = from.members
        
        return values
    }
    
    func removeMember(userId: String) {
        self.databaseRef.child(rootNode).child(userId).removeValue()
    }
    
//    func getGroceryList(row:Int) -> GroceryList? {
//        if (row < getListCount()) {
//            let groceryListKey = groceryLists[row].key as String
//            let groceryListValues = groceryLists[row].value as! Dictionary<String, Any>
//            
//            return extractGroceryList(key: groceryListKey, values: groceryListValues)
//        }
//        
//        return nil
//    }
    
    private func extractGroup(key: String, values: Dictionary<String, Any>) -> Group {
        return Group(
            id: key as NSString,
            title: values["title"]! as! NSString,
            adminUserId: values["adminUserId"] as! NSString,
            lists: values["lists"] as! Array<GroceryList>,
            members: values["members"] as! Array<NSString>)
    }
    
    func findGroupByKey(key: String, whenFinished: @escaping (_: Group?) -> Void) {
        if (self.myGroup == nil) {
            databaseRef.child(rootNode).child(key).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                // Make sure the group was found in the database
                if (!(snapshot.value is NSNull)) {
                    let group = self.extractGroup(key: snapshot.key, values: snapshot.value as! Dictionary<String, String>)
                    self.myGroup = group
                    
                    whenFinished(group)
                } else {
                    whenFinished(nil)
                }
            })
        }
        else {
            whenFinished(self.myGroup!)
        }
    }

    func getMembersCount() -> Int {
        return groupMembers.count
    }
}
