//
//  UserDB.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation

class UserDB {
    static let sharedInstance: UserDB = { UserDB() }()
    var users = Array<User>()
    var me:User? = nil
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    func addUser(user:User) {
        if (getIndexById(id: user.id) == nil) {
            users.append(user)
        }
        
        // Determine who the current user is
        me = users[getIndexById(id: user.id)!]
    }
    
    func deleteUser(id:NSString) -> Bool {
        
        let index = getIndexById(id: id)
        
        if let indexValue = index {
            users.remove(at: indexValue)
            
            return true
        }
        
        return false
    }
    
    func getUser(id:NSString) -> User? {
        return users.first(where: {$0.id == id})
    }
    
    func updateUser(user:User) -> Bool {
        let userWasDeleted = deleteUser(id: user.id)
        
        if (userWasDeleted) {
            addUser(user: user)
            
            return true
        }
        
        return false
        
    }
    
    func getIndexById(id: NSString) -> Int? {
        return users.index(where: {$0.id == id})
    }
}
