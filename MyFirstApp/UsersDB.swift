//
//  UsersDB.swift
//  MyFirstApp
//
//  Created by admin on 17/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UsersDB {
    static let sharedInstance: UsersDB = { UsersDB() } ()
    let rootNode = "users"
    var databaseRef: FIRDatabaseReference!
    var localDb: LocalDb!

    init() {
        databaseRef = FIRDatabase.database().reference()
        localDb = LocalDb()!
    }
    
    deinit {
        databaseRef.removeAllObservers()
    }
    
//    private func manageRefresh() {
//        // Get the local update time
//        var localUpdateTime = LastUpdateTable.getLastUpdateDate(database: localDb.database, table: "Users")
//        
//        if (localUpdateTime == nil) {
//            // Init the date with the oldest date
//            localUpdateTime = Date.init(timeIntervalSince1970: 0)
//        }
//        
//        // Add time interval so that we don't select the same objects
//        localUpdateTime = localUpdateTime?.addingTimeInterval(1)
//        
//        // TODO: Query not working correctly..
////        findNewUsersFromRemote(localUpdateTime: localUpdateTime!)
//    }
    
//    private func findNewUsersFromRemote(localUpdateTime: Date) {
//        let nsDate = localUpdateTime as NSDate
//        databaseRef.child(rootNode).queryOrdered(byChild: "lastUpdated").queryStarting(atValue: nsDate.timeIntervalSince1970).observeSingleEvent(
//            of: FIRDataEventType.value, with: {(snapshot) in
//
//                if !(snapshot.value is NSNull) {
//                    var latestDate = localUpdateTime
//                    
//                    let users = snapshot.value as! Dictionary<NSString, Dictionary<String, Any>>
//                    
//                    for child in users.keys {
//
//                        let user = self.extractUser(key: child as NSString, values: users[child]! as Dictionary<String, Any>)
//                        let currentUserDate = user.lastUpdate
//                        
//                        // Save in local db
//                        user.addUserToLocalDb(database: self.localDb.database)
//                        
//                        // Save the latest date
//                        if (currentUserDate?.compare(latestDate) == .orderedDescending) {
//                            latestDate = currentUserDate as! Date
//                        }
//                    }
//
//                    print("Updating User LastUpdate to \(latestDate)")
//                    
//                    // Update the last update date
//                    LastUpdateTable.setLastUpdate(database: self.localDb.database, table: "Users", lastUpdate: latestDate)
//                }
//        })
//    }
    
    func findUserByKey(key: String, whenFinished: @escaping (_: User?) -> Void) {
//        manageRefresh()
        
        // Fetch the user from local db
//        let userFromLocal = User.getUserByKeyFromLocalDB(database: localDb.database, key: key)
        
//        if (userFromLocal == nil) {
            findUserFromRemote(key: key, whenFinished: whenFinished)
//        }
//        else {
//            whenFinished(userFromLocal)
//            print("Got user from local.")
//        }
    }
    
    private func findUserFromRemote(key: String, whenFinished: @escaping (_: User?) -> Void) {
        databaseRef.child(rootNode).child(key).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            // Make sure the user was found in the database
            if (!(snapshot.value is NSNull)) {
                let user = self.extractUser(key: snapshot.key as NSString, values: snapshot.value as! Dictionary<String, Any>)
                user.addUserToLocalDb(database: self.localDb.database)
                
                whenFinished(user)
                print("Got user from remote.")
            }
            else {
                whenFinished(nil)
            }
        })
    }

    func findUserByFacebookId(facebookId: String, whenFinished: @escaping (_: User) -> Void) {
        databaseRef.child(rootNode).queryOrdered(byChild: "facebookId").queryEqual(toValue: facebookId).observeSingleEvent(
                        of: FIRDataEventType.value, with: {(snapshot) in
                    if !(snapshot.value is NSNull) {
                        let userSnapshot = (snapshot.value as! Dictionary<String, Any>).first!
                        let user = self.extractUser(key: userSnapshot.key as NSString, values: userSnapshot.value as! Dictionary<String, Any>)
                        whenFinished(user)
                    }
                })
    }
    
    private func extractUser(key: NSString, values: Dictionary<String, Any>) -> User {
        return User(
                key: key,
                name: values["name"] as? NSString,
                facebookId: values["facebookId"] as? NSString,
                lastUpdate: TimeUtilities.getDateFromString(
                        date: values["lastUpdated"]! as! String,
                        timeZone: TimeZone(secondsFromGMT: 0 - TimeUtilities.getCurrentTimeZoneSecondsFromGMT())!) as NSDate)
    }
    
    func addUser(user:User, whenFinished: @escaping (Error?, FIRDatabaseReference) -> Void) {
        let values = loadValues(from: user)
        
        // Add to remote
        self.databaseRef.child(rootNode).child(user.key as String).setValue(values, withCompletionBlock: whenFinished)
        
        // Add to local db
        user.addUserToLocalDb(database: localDb.database)
    }
    
    private func loadValues(from: User) -> Dictionary<String, Any> {
        var values = Dictionary<String, Any>()
        values["name"] = from.name as? String
        values["facebookId"] = from.facebookId as? String
        values["lastUpdated"] = FIRServerValue.timestamp()
        
        return values
    }
}
