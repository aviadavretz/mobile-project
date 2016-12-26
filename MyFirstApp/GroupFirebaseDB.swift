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
    let listNode = "lists"
    var databaseRef: FIRDatabaseReference!
    
//    // This array holds the userIds of all the group members
//    var groupMembers: Array<NSString> = []
    
    var groupCache: Dictionary<NSString, Group> = Dictionary<NSString, Group>()
    
    deinit {
        self.databaseRef.child(rootNode).removeAllObservers()
    }
    
    private init() {
        databaseRef = FIRDatabase.database().reference()
//        observeChildAddition()
//        observeChildDeletion()
    }
    
//    private func observeChildAddition() {
//        databaseRef.child(rootNode).observe(FIRDataEventType.childAdded, with: { [weak self] (snapshot) -> Void in
//            guard let strongSelf = self else {return }
//            strongSelf.groupCache[.append(snapshot.key as NSString)
//            
//            strongSelf.notifyChanges()
//        })
//    }
//    
//    private func observeChildDeletion() {
//        databaseRef.child(rootNode).observe(FIRDataEventType.childRemoved, with: { [weak self] (snapshot) -> Void in
//            guard let strongSelf = self else {return }
//            strongSelf.groupMembers.remove(at: strongSelf.getSnapshotIndex(key: snapshot.key as String)!)
//            
//            strongSelf.notifyChanges()
//        })
//    }
    
    func addMember(userId:NSString, forGroupId: NSString) {
        // TODO:(?) add .child(memberNode)
        self.databaseRef.child(rootNode).child(forGroupId as String).childByAutoId().setValue(userId)
    }
    
    func addGroup(group:Group, forUserId: NSString) {
        // Make sure the user is in the group
        if (!group.members.contains(forUserId)) {
            group.members.append(forUserId)
        }
        
        let values = loadValues(from: group)
        
        let generatedKey = self.databaseRef.child(rootNode).childByAutoId().key
        self.databaseRef.child(rootNode).child(generatedKey).setValue(values)
        
        UserFirebaseDB.sharedInstance.setGroup(forUserId: forUserId as String, groupKey: generatedKey as String)
        
        // Update the group's key in the cache
        group.key = generatedKey as NSString

        self.groupCache[generatedKey as NSString] = group
    }
    
//    private func getSnapshotIndex(key: String) -> Int? {
//        return groupMembers.index(where: { $0 as String == key })
//    }
    
    func addListToGroup(listKey:NSString, forGroupKey:NSString) {
        // TODO: Find a better way to insert into the db (the keys should be 0,1,2...)
        let group = groupCache[forGroupKey]
        group?.lists.append(listKey)
        
        updateGroup(group: group!)
    }
    
    private func updateGroup(group: Group) {
        let values = loadValues(from: group)
        
        let key = group.key
        self.databaseRef.child(rootNode).child(key as String).setValue(values)
        
        self.groupCache[key] = group
    }
    
    private func notifyChanges() {
        NotificationCenter.default.post(name: NSNotification.Name("groupMembersModelChanged"), object: nil)
    }
    
    private func loadValues(from: Group) -> Dictionary<String, Any> {
        var values = Dictionary<String, Any>()
        values["title"] = from.title as String?
        values["members"] = from.members
        values["lists"] = from.lists
        
        return values
    }
    
    func removeMember(userId: String) {
        self.databaseRef.child(rootNode).child(userId).removeValue()
    }
    
//    public func removeList(listKey: NSString, fromGroupKey: NSString) {
//        self.databaseRef.child(rootNode).child(fromGroupKey as String).child(listNode).child(listKey as String).removeValue()
//    }
    
    public func removeList(listKey: NSString, fromGroupKey: NSString) {
        // TODO: Find a better way to remove from the db (the keys should be 0,1,2...)
        let group = groupCache[fromGroupKey]
        let index = group?.lists.index(of: listKey)
        
        group?.lists.remove(at: index!)
        
        updateGroup(group: group!)
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
        var lists = values["lists"]

        // Avoid NullPointerExceptions
        if (lists == nil) {
            lists = Array<NSString>()
        }
        
        return Group(
            key: key as NSString,
            title: values["title"]! as! NSString,
            lists: lists as! Array<NSString>,
            members: values["members"] as! Array<NSString>)
    }
    
    func findGroupByKey(key: String, whenFinished: @escaping (_: Group?) -> Void) {
        if (self.groupCache[key as NSString] == nil) {
            databaseRef.child(rootNode).child(key).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
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

//    func getMembersCount() -> Int {
//        return groupMembers.count
//    }
}
