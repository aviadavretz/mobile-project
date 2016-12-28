//
//  GroceryListsDB.swift
//  MyFirstApp
//
//  Created by admin on 15/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroceryListsDB {
    static let sharedInstance: GroceryListsDB = { GroceryListsDB() } ()
    let rootNode = "grocery-lists"

    var databaseRef: FIRDatabaseReference!

    private init() {
        databaseRef = FIRDatabase.database().reference()
    }

    deinit {
        self.databaseRef.child(rootNode).removeAllObservers()
    }
    
    func addList(list:GroceryList) -> String {
        let values = loadValues(from: list)

        let generatedKey = self.databaseRef.child(rootNode).childByAutoId().key
        self.databaseRef.child(rootNode).child(generatedKey).setValue(values)
        
        return generatedKey
    }

    private func loadValues(from: GroceryList) -> Dictionary<String, String> {
        var values = Dictionary<String, String>()
        values["title"] = from.title as String
        values["date"] = TimeUtilities.getStringFromDate(date: from.date as Date, timeZone: TimeZone(secondsFromGMT: 0)!)
        values["groupKey"] = from.groupKey as String

        return values
    }
    
    func deleteList(id: String) {
        self.databaseRef.child(rootNode).child(id).removeValue()
    }
}