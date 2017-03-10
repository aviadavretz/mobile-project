//
// Created by admin on 10/03/2017.
// Copyright (c) 2017 Naveh Ohana. All rights reserved.
//

import Foundation

extension String {
    public init?(validatingUTF8 cString: UnsafePointer<UInt8>) {
        if let (result, _) = String.decodeCString(cString, as: UTF8.self,
                repairingInvalidCodeUnits: false) {
            self = result
        }
        else {
            return nil
        }
    }
}


class LocalDb {
    var database: OpaquePointer? = nil

    init?(){
        let dbFileName = "MyFirstAppDatabase.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let path = dir.appendingPathComponent(dbFileName)

            // Opening the database file
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return nil
            }
        }

        // Creating the last update table (if it doesn't already exists)
        if LastUpdateTable.createTable(database: database) == false {
            return nil
        }

        // Creating the users table (if it doesn't already exists)
        if User.createTable(database: database) == false {
            return nil
        }
    }
}