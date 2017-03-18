//
// Created by admin on 14/03/2017.
// Copyright (c) 2017 Naveh Ohana. All rights reserved.
//

import Foundation

class ListRequestsTable {
    static let TABLE = "LIST_REQUESTS"
    static let LIST_KEY = "LIST_KEY"
    static let REQUEST_KEY = "REQUEST_KEY"
    static let ITEM_NAME = "ITEM_NAME"
    static let PURCHASED = "PURCHASED"
    static let USER_KEY = "USER_KEY"
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let sql = "CREATE TABLE IF NOT EXISTS \(TABLE) (\(REQUEST_KEY) VARCHAR(100) PRIMARY KEY, \(LIST_KEY) VARCHAR(100), \(ITEM_NAME) VARCHAR(100), \(PURCHASED) BOOLEAN, \(USER_KEY) VARCHAR(100))"
        
        let res = sqlite3_exec(database, sql, nil, nil, &errormsg);
        if(res != 0) {
            print("error creating table \(TABLE)");
            return false
        }
        
        return true
    }
    
    static func addRequest(database:OpaquePointer?, request:GroceryRequest, listKey:String) {
        var sqlite3_stmt: OpaquePointer? = nil
        let sql = "INSERT OR REPLACE INTO \(TABLE) (\(REQUEST_KEY), \(LIST_KEY), \(ITEM_NAME), \(PURCHASED), \(USER_KEY)) VALUES ('\(request.id as String)', '\(listKey)', '\((request.itemName as String))', '\(request.purchased.description.lowercased())', '\((request.userId as String))');"
        
        if (sqlite3_prepare_v2(database, sql,-1, &sqlite3_stmt,nil) == SQLITE_OK) {
            // Execute the statement
            let status = sqlite3_step(sqlite3_stmt)
            print("Got status: \(status)")
        }
        
        let status = sqlite3_finalize(sqlite3_stmt)
        print("Got status: \(status)")
    }
    //
    //    static func getRequestsByListKey(database:OpaquePointer?, listKey:String) -> Array<GroceryRequest> {
    //        var requests = Array<GroceryRequest>()
    //
    //        var sqlite3_stmt: OpaquePointer? = nil
    //        let sql = "SELECT \(REQUEST_KEY), \(ITEM_NAME), \(PURCHASED), \(USER_KEY) FROM \(TABLE) WHERE \(LIST_KEY) = '\(listKey)';"
    //
    //        if (sqlite3_prepare_v2(database, sql, -1,&sqlite3_stmt,nil) == SQLITE_OK) {
    //            // Execute the statement
    //            while (sqlite3_step(sqlite3_stmt) == SQLITE_ROW) {
    //                let requestKey = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
    //                let itemName = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
    //                let purchased = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))?.lowercased() == "true"
    //                let userKey = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))
    //
    //                let request = GroceryRequest(id: requestKey! as NSString, itemName: itemName! as NSString, purchased: purchased, userId: userKey! as NSString)
    //
    //                requests.append(request)
    //            }
    //        }
    //
    //        sqlite3_finalize(sqlite3_stmt)
    //
    //        return requests;
    //    }
    
    //    static func addRequest(database:OpaquePointer?, request:GroceryRequest, listKey:String) {
    //        var sqlite3_stmt: OpaquePointer? = nil
    //        let sql = "INSERT OR REPLACE INTO \(TABLE) (\(REQUEST_KEY), \(LIST_KEY), \(ITEM_NAME), \(PURCHASED), \(USER_KEY)) VALUES (?, ?, ?, ?, ?);"
    //
    //        if (sqlite3_prepare_v2(database, sql,-1, &sqlite3_stmt,nil) == SQLITE_OK) {
    //            // Bind the variables to the query
    //            sqlite3_bind_text(sqlite3_stmt, 1, (request.id as String).cString(using: .utf8),-1,nil);
    //            sqlite3_bind_text(sqlite3_stmt, 2, listKey.cString(using: .utf8),-1,nil);
    //            sqlite3_bind_text(sqlite3_stmt, 3, (request.itemName as String).cString(using: .utf8),-1,nil);
    //            sqlite3_bind_text(sqlite3_stmt, 4, request.purchased.description.lowercased().cString(using: .utf8),-1,nil);
    //            sqlite3_bind_text(sqlite3_stmt, 5, (request.userId as String).cString(using: .utf8),-1,nil);
    //
    //            // Execute the statement
    //            sqlite3_step(sqlite3_stmt)
    //        }
    //
    //        sqlite3_finalize(sqlite3_stmt)
    //    }
    
    static func getRequestsByListKey(database:OpaquePointer?, listKey:String) -> Array<GroceryRequest> {
        var requests = Array<GroceryRequest>()
        
        var sqlite3_stmt: OpaquePointer? = nil
        let sql = "SELECT \(REQUEST_KEY), \(ITEM_NAME), \(PURCHASED), \(USER_KEY) FROM \(TABLE) WHERE \(LIST_KEY) = ?;"
        
        if (sqlite3_prepare_v2(database, sql, -1,&sqlite3_stmt,nil) == SQLITE_OK) {
            // Bind the variable to the query
            sqlite3_bind_text(sqlite3_stmt, 1, listKey.cString(using: .utf8),-1,nil);
            
            // Execute the statement
            while (sqlite3_step(sqlite3_stmt) == SQLITE_ROW) {
                let requestKey = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                let itemName = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
                let purchased = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))?.lowercased() == "true"
                let userKey = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))
                
                let request = GroceryRequest(id: requestKey! as NSString, itemName: itemName! as NSString, purchased: purchased, userId: userKey! as NSString)
                
                requests.append(request)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        
        return requests;
    }
    
    private static func deleteRequest(database:OpaquePointer?, requestKey:String, listKey:String) {
        var sqlite3_stmt: OpaquePointer? = nil
        let sql = "DELETE FROM \(TABLE) WHERE \(REQUEST_KEY) = ? AND \(LIST_KEY) = ?;"
        
        if (sqlite3_prepare_v2(database, sql,-1, &sqlite3_stmt,nil) == SQLITE_OK){
            // Bind the variables to the query
            sqlite3_bind_text(sqlite3_stmt, 1, requestKey.cString(using: .utf8),-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, listKey.cString(using: .utf8),-1,nil);
            
            // Execute the statement
            sqlite3_step(sqlite3_stmt)
        }
        sqlite3_finalize(sqlite3_stmt)
    }
}
