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
    let childNodeName = "grocery-lists"
    
    fileprivate var _databaseHandle: FIRDatabaseHandle!
    var databaseRef: FIRDatabaseReference!
    var groceryLists: [FIRDataSnapshot]! = []

    deinit {
        self.databaseRef.child(childNodeName).removeObserver(withHandle: _databaseHandle)
    }

    private init() {
        configureDatabase()
    }

    func configureDatabase() {
        databaseRef = FIRDatabase.database().reference()
        _databaseHandle = listenToNewListsInDb(dbRef: databaseRef)
    }

    private func listenToNewListsInDb(dbRef: FIRDatabaseReference!) -> FIRDatabaseHandle! {
        return databaseRef.child(childNodeName).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else {return }
            strongSelf.groceryLists.append(snapshot)

            strongSelf.notifyChanges()
        })
    }
    
    func addList(list:GroceryList) {
        let values = loadValues(from: list)

        self.databaseRef.child(childNodeName).childByAutoId().setValue(values)
    }

    private func notifyChanges() {
        NotificationCenter.default.post(name: NSNotification.Name("groceryListsModelChanged"), object: nil)
    }

    private func loadValues(from: GroceryList) -> Dictionary<String, String> {
        var values = Dictionary<String, String>()
        values["title"] = from.title as String
        values["date"] = getStringFromDate(date: from.date as Date, timeZone: TimeZone(secondsFromGMT: 0)!)

        return values
    }

    func deleteList(id:NSString) -> Bool {
        return false
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
            let groceryListValues = groceryLists[row].value as! Dictionary<String, String>

            return extractGroceryList(values: groceryListValues)
        }
        
        return nil
    }

    private func extractGroceryList(values: Dictionary<String, String>) -> GroceryList {
        return GroceryList(
                title: values["title"]! as NSString,
                date: getDateFromString(
                        date: values["date"]!,
                        timeZone: TimeZone(secondsFromGMT: 0 - getCurrentTimeZoneSecondsFromGMT())!) as NSDate)
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