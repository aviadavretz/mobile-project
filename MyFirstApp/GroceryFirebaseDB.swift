//
//  GroceryFirebaseDB.swift
//  MyFirstApp
//
//  Created by admin on 15/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroceryFirebaseDB {
    static let sharedInstance: GroceryFirebaseDB = { GroceryFirebaseDB() } ()
    let rootNode = "grocery-lists"

    var databaseRef: FIRDatabaseReference!
    var groceryLists: [FIRDataSnapshot]! = []

    deinit {
        self.databaseRef.child(rootNode).removeAllObservers()
    }

    private init() {
        databaseRef = FIRDatabase.database().reference()
        observeChildAddition()
        observeChildDeletion()
    }

    private func observeChildAddition() {
        databaseRef.child(rootNode).observe(FIRDataEventType.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else {return }
            strongSelf.groceryLists.append(snapshot)

            strongSelf.notifyChanges()
        })
    }

    private func observeChildDeletion() {
        databaseRef.child(rootNode).observe(FIRDataEventType.childRemoved, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else {return }
            strongSelf.groceryLists.remove(at: strongSelf.getSnapshotIndex(key: snapshot.key as String)!)

            strongSelf.notifyChanges()
        })
    }
    
    func addList(list:GroceryList) -> String {
        let values = loadValues(from: list)

        let generatedKey = self.databaseRef.child(rootNode).childByAutoId().key
        self.databaseRef.child(rootNode).child(generatedKey).setValue(values)
        
        return generatedKey
    }

    private func getSnapshotIndex(key: String) -> Int? {
        return groceryLists.index(where: {$0.key == key})
    }

    private func notifyChanges() {
        NotificationCenter.default.post(name: NSNotification.Name("groceryListsModelChanged"), object: nil)
    }

    private func loadValues(from: GroceryList) -> Dictionary<String, String> {
        var values = Dictionary<String, String>()
        values["title"] = from.title as String
        values["date"] = getStringFromDate(date: from.date as Date, timeZone: TimeZone(secondsFromGMT: 0)!)
        values["groupKey"] = from.groupKey as String

        return values
    }
    
    func deleteList(id: String) {
        self.databaseRef.child(rootNode).child(id).removeValue()
    }

    private func getDateFormatter(timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        formatter.timeZone = timeZone

        return formatter
    }

    private func getStringFromDate(date: Date, timeZone: TimeZone) -> String {
        return getDateFormatter(timeZone: timeZone).string(from: date)
    }

    private func getDateFromString(date: String, timeZone: TimeZone) -> Date {
        return getDateFormatter(timeZone: timeZone).date(from: date)!
    }

    func getGroceryList(row:Int) -> GroceryList? {
        if (row < getListCount()) {
            let groceryListKey = groceryLists[row].key as String
            let groceryListValues = groceryLists[row].value as! Dictionary<String, Any>

            return extractGroceryList(key: groceryListKey, values: groceryListValues)
        }
        
        return nil
    }

    private func extractGroceryList(key: String, values: Dictionary<String, Any>) -> GroceryList {
        return GroceryList(
                id: key as NSString,
                title: values["title"]! as! NSString,
                date: getDateFromString(
                        date: values["date"]! as! String,
                        timeZone: TimeZone(secondsFromGMT: 0 - getCurrentTimeZoneSecondsFromGMT())!) as NSDate,
                groupKey: values["groupKey"] as! NSString)
    }

    private func getCurrentTimeZoneSecondsFromGMT() -> Int {
        return TimeZone.current.secondsFromGMT()
    }
    
    func updateList(list:GroceryList) -> Bool {
        return false
    }
    
    func getListCount() -> Int {
        return groceryLists.count
    }
}
