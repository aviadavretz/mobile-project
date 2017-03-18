//
// Created by admin on 14/03/2017.
// Copyright (c) 2017 Naveh Ohana. All rights reserved.
//

import Foundation

class GroupMembersTable {
    static let TABLE = "GROUP_MEMBERS"
    static let USER_KEY = "USER_KEY"
    static let GROUP_KEY = "GROUP_KEY"

    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let sql = "CREATE TABLE IF NOT EXISTS \(TABLE) (\(USER_KEY) TEXT, \(GROUP_KEY) TEXT, PRIMARY KEY (\(USER_KEY), \(GROUP_KEY)))"

        let res = sqlite3_exec(database, sql, nil, nil, &errormsg);
        if(res != 0) {
            print("error creating table");
            return false
        }

        return true
    }
    
    static func getUserKeysByGroupKey(database:OpaquePointer?, groupKey: String) -> Array<String> {
        var usersKeys = Array<String>()
        
        var sqlite3_stmt: OpaquePointer? = nil
        let sql = "SELECT * FROM \(TABLE) WHERE \(GROUP_KEY) = '\(groupKey)';"
        
        if (sqlite3_prepare_v2(database, sql, -1,&sqlite3_stmt,nil) == SQLITE_OK) {
//            sqlite3_bind_text(sqlite3_stmt, 1, groupKey.cString(using: .utf8),-1,nil);
            
            while (sqlite3_step(sqlite3_stmt) == SQLITE_ROW) {
                let userKey = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                usersKeys.append(userKey!)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        
        return usersKeys;
    }

    static func updateUserKeys(database: OpaquePointer?, userKeys: Array<String>, groupKey: String) {
        removeUsersFromGroup(database: database, groupKey: groupKey)

        userKeys.forEach({ addUserToGroup(database: database, userKey: $0, groupKey: groupKey) })
    }

    private static func removeUsersFromGroup(database: OpaquePointer?, groupKey: String) {
        var sqlite3_stmt: OpaquePointer? = nil
        let sql = "DELETE FROM \(TABLE) WHERE \(GROUP_KEY) = '\(groupKey)';"

        if (sqlite3_prepare_v2(database, sql,-1, &sqlite3_stmt,nil) == SQLITE_OK) {
//            sqlite3_bind_text(sqlite3_stmt, 1, groupKey.cString(using: .utf8),-1,nil)

            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE) {
                print("\(TABLE): All rows deleted for groupKey = \(groupKey)")
            }
        }

        sqlite3_finalize(sqlite3_stmt)
    }

    private static func addUserToGroup(database:OpaquePointer?, userKey:String, groupKey:String) {
        var sqlite3_stmt: OpaquePointer? = nil
        let sql = "INSERT OR REPLACE INTO \(TABLE) (\(USER_KEY),\(GROUP_KEY)) VALUES ('\(userKey)','\(groupKey)');"

        if (sqlite3_prepare_v2(database, sql,-1, &sqlite3_stmt,nil) == SQLITE_OK) {
//            sqlite3_bind_text(sqlite3_stmt, 1, userKey.cString(using: .utf8),-1,nil);
//            sqlite3_bind_text(sqlite3_stmt, 2, groupKey.cString(using: .utf8),-1,nil);

            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE) {
                print("\(TABLE): New row added: userKey = \(userKey), groupKey = \(groupKey)")
            }
        }

        sqlite3_finalize(sqlite3_stmt)
    }
}
