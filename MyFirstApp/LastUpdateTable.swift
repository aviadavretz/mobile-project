//
// Created by admin on 10/03/2017.
// Copyright (c) 2017 Naveh Ohana. All rights reserved.
//

import Foundation

class LastUpdateTable {
    static let TABLE = "LAST_UPDATE"
    static let NAME = "NAME"
    static let KEY = "KEY"
    static let DATE = "DATE"

    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let sql = "CREATE TABLE IF NOT EXISTS \(TABLE) (\(NAME) TEXT PRIMARY KEY, \(KEY) TEXT, \(DATE) DOUBLE)"

        let res = sqlite3_exec(database, sql, nil, nil, &errormsg);
        if(res != 0) {
            print("error creating table");
            return false
        }

        return true
    }

    static func setLastUpdate(database:OpaquePointer?, table:String, key:String, lastUpdate:Date){
        var sqlite3_stmt: OpaquePointer? = nil
        let sql = "INSERT OR REPLACE INTO \(TABLE) (\(NAME),\(KEY),\(DATE)) VALUES (?,?,?);"

        if (sqlite3_prepare_v2(database, sql,-1, &sqlite3_stmt,nil) == SQLITE_OK){
            let tableName = table.cString(using: .utf8)
            sqlite3_bind_text(sqlite3_stmt, 1, tableName,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, key,-1,nil);
            sqlite3_bind_double(sqlite3_stmt, 3, (lastUpdate as NSDate).toFirebase());
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }

    static func getLastUpdateDate(database:OpaquePointer?, table:String, key:String)->Date?{
        var uDate:Date?
        var sqlite3_stmt: OpaquePointer? = nil
        let sql = "SELECT * from \(TABLE) where \(NAME) = ? AND \(KEY) = ?;"

        if (sqlite3_prepare_v2(database, sql, -1,&sqlite3_stmt,nil) == SQLITE_OK){
            let tableName = table.cString(using: .utf8)
            let keyValue = key.cString(using: .utf8)

            sqlite3_bind_text(sqlite3_stmt, 1, tableName,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, keyValue,-1,nil);

            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let date = Double(sqlite3_column_double(sqlite3_stmt, 1))
                uDate = NSDate.fromFirebasee(date) as Date
            }
        }

        sqlite3_finalize(sqlite3_stmt)
        return uDate
    }
}