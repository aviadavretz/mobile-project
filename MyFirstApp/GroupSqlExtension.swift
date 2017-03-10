//
//  GroupSqlExtension.swift
//  MyFirstApp
//
//  Created by admin on 10/03/2017.
//  Copyright © 2017 Naveh Ohana. All rights reserved.
//

import Foundation

extension Group {
    static let GROUPS_TABLE = "Groups"
    static let GROUP_ID = "ID"
    static let GROUP_TITLE = "TITLE"
    static let GROUP_LAST_UPDATE_DATE = "LAST_UPDATE_DATE"
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + Group.GROUPS_TABLE + " ( "
            + Group.GROUP_ID + " TEXT PRIMARY KEY, "
            + Group.GROUP_TITLE + " TEXT, "
            + Group.GROUP_LAST_UPDATE_DATE + " DOUBLE)", nil, nil, &errormsg);
        
        if(res != 0) {
            print("error creating table");
            return false
        }
        
        return true
    }
    
    func addGroupToLocalDb(database:OpaquePointer?) {
        var sqlite3_stmt: OpaquePointer? = nil
        
        let insertOrReplaceUserSql = "INSERT OR REPLACE INTO " + Group.GROUPS_TABLE + "("
            + Group.GROUP_ID + ","
            + Group.GROUP_TITLE + ","
            + Group.GROUP_LAST_UPDATE_DATE
            + ") VALUES (?,?,?);"
        
        if (sqlite3_prepare_v2(database, insertOrReplaceUserSql, -1, &sqlite3_stmt,nil) == SQLITE_OK) {
            
            let id = (self.key as String).cString(using: .utf8)
            let title = (self.title as! String).cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, title,-1,nil);
            
            if (lastUpdate == nil) {
                lastUpdate = NSDate()
            }
            
            sqlite3_bind_double(sqlite3_stmt, 4, lastUpdate!.toFirebase());
            
            if (sqlite3_step(sqlite3_stmt) == SQLITE_DONE) {
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getGroupByKeyFromLocalDB(database:OpaquePointer?, key:String)->Group? {
        var sqlite3_stmt: OpaquePointer? = nil
        let getGroupByKeySql = "SELECT * from " + Group.GROUPS_TABLE + " Where " + Group.GROUP_ID + "=?;"
        
        if (sqlite3_prepare_v2(database, getGroupByKeySql,-1,&sqlite3_stmt,nil) == SQLITE_OK) {
            sqlite3_bind_text(sqlite3_stmt, 1, key.cString(using: .utf8),-1,nil);
            
            if (sqlite3_step(sqlite3_stmt) == SQLITE_ROW) {
                let keyValue =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                let title =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))

                return Group(key: keyValue! as NSString, title: title! as NSString)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        return nil
    }
}
