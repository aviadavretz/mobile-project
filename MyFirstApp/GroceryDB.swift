//
//  GroceryDB.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation

class GroceryDB {
    static let sharedInstance: GroceryDB = { GroceryDB() }()
    var lists = Array<GroceryList>()
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    func addList(list:GroceryList) {
        
        if (getIndexById(id: list.id) == nil) {
            lists.append(list)
        }
    }
    
    func deleteList(id:NSString) -> Bool {
        
        let index = getIndexById(id: id)
        
        if let indexValue = index {
            lists.remove(at: indexValue)
            
            return true
        }
        
        return false
    }
    
    func getList(id:NSString) -> GroceryList? {
        return lists.first(where: {$0.id == id})
    }
    
    func updateList(list:GroceryList) -> Bool {
        let listWasDeleted = deleteList(id: list.id)
        
        if (listWasDeleted) {
            addList(list: list)
            
            return true
        }
        
        return false
        
    }
    
    func getIndexById(id: NSString) -> Int? {
        return lists.index(where: {$0.id == id})
    }
}
