//
// Created by admin on 10/03/2017.
// Copyright (c) 2017 Naveh Ohana. All rights reserved.
//

import Foundation

extension User {
    static let USERS_TABLE = "Users"
    static let USER_ID = "ID"
    static let USER_NAME = "NAME"
    static let USER_FACEBOOK_ID = "FACEBOOK_ID"
    static let USER_LAST_UPDATE_DATE = "LAST_UPDATE_DATE"

    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil

        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + USERS_TABLE + " ( "
                + USER_ID + " TEXT PRIMARY KEY, "
                + USER_NAME + " TEXT, "
                + USER_FACEBOOK_ID + " TEXT, "
                + USER_LAST_UPDATE_DATE + " DOUBLE)", nil, nil, &errormsg);

        if(res != 0){
            print("error creating table");
            return false
        }

        return true
    }

    func addUserToLocalDb(database:OpaquePointer?){
        var sqlite3_stmt: OpaquePointer? = nil

        let insertOrReplaceUserSql = "INSERT OR REPLACE INTO " + User.USERS_TABLE + "("
                + User.USER_ID + ","
                + User.USER_NAME + ","
                + User.USER_FACEBOOK_ID + ","
                + User.USER_LAST_UPDATE_DATE
                + ") VALUES (?,?,?,?);"

        if (sqlite3_prepare_v2(database, insertOrReplaceUserSql, -1, &sqlite3_stmt,nil) == SQLITE_OK) {

            let id = (self.key as String).cString(using: .utf8)
            let name = (self.name as! String).cString(using: .utf8)
            let facebookId = (self.facebookId as! String).cString(using: .utf8)

            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, name,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, facebookId,-1,nil);

            if (lastUpdate == nil){
                lastUpdate = NSDate()
            }

            sqlite3_bind_double(sqlite3_stmt, 4, lastUpdate!.toFirebase());

            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }

    static func getUserByKeyFromLocalDB(database:OpaquePointer?, key:String)->User?{
        var sqlite3_stmt: OpaquePointer? = nil
        let getUserByKeySql = "SELECT * from " + User.USERS_TABLE + " Where " + User.USER_ID + "=?;"

        if (sqlite3_prepare_v2(database, getUserByKeySql,-1,&sqlite3_stmt,nil) == SQLITE_OK){
            sqlite3_bind_text(sqlite3_stmt, 1, key.cString(using: .utf8),-1,nil);

            if (sqlite3_step(sqlite3_stmt) == SQLITE_ROW) {
                let keyValue =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                let name =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
                let facebookId =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))

                return User(key: keyValue! as NSString, name: name! as NSString, facebookId: facebookId! as NSString)
            }
        }

        sqlite3_finalize(sqlite3_stmt)
        return nil
    }
}