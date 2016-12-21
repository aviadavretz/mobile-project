//
//  UserFirebaseDB.swift
//  MyFirstApp
//
//  Created by admin on 17/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserFirebaseDB {
    static let sharedInstance: UserFirebaseDB = { UserFirebaseDB() } ()
    let rootNode = "users"
    var databaseRef: FIRDatabaseReference!
    var userCache:Dictionary<String, User> = Dictionary<String, User>()
    
    init() {
        databaseRef = FIRDatabase.database().reference()
    }
    
    deinit {
        databaseRef.removeAllObservers()
    }
    
    func findUserByKey(key: String, whenFinished: @escaping (_: User?) -> Void) {
        if (self.userCache[key] == nil) {
            databaseRef.child(rootNode).child(key).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    // Make sure the user was found in the database
                    if (!(snapshot.value is NSNull)) {
                        let user = self.extractUser(key: snapshot.key as NSString, values: snapshot.value as! Dictionary<String, String>)
                        self.userCache[key] = user
                        
                        whenFinished(user)
                    } else {
                        whenFinished(nil)
                    }
            })
        }
        else {
            whenFinished(self.userCache[key]!)
        }
    }
    
    private func extractUser(key: NSString, values: Dictionary<String, String>) -> User {
        return User(id: key, firstName: values["firstName"]! as NSString, lastName: values["lastName"]! as NSString)
    }
    
    func addUser(user:User, whenFinished: @escaping (Error?, FIRDatabaseReference) -> Void) {
        let values = loadValues(from: user)
        self.databaseRef.child(rootNode).child(user.id as String).setValue(values, withCompletionBlock: whenFinished)
        self.userCache[user.id as String] = user
    }
    
    private func loadValues(from: User) -> Dictionary<String, String> {
        var values = Dictionary<String, String>()
        values["id"] = from.id as String
        values["firstName"] = from.firstName as? String
        values["lastName"] = from.lastName as? String
    
        return values
    }
}
