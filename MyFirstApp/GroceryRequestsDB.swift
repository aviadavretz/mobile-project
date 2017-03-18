//
// Created by admin on 17/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroceryRequestsDB {
    let rootNode = "grocery-lists"
    let requestsNode = "requests"

    var databaseRef: FIRDatabaseReference!
    var fbQueryRef: FIRDatabaseQuery!
    
    var groceryRequests: Array<GroceryRequest> = []
    var listKey: NSString
    
    init(listKey: NSString) {
        self.listKey = listKey
        databaseRef = FIRDatabase.database().reference(withPath: "\(rootNode)/\(listKey)/\(requestsNode)")
    }

    func observeRequestAddition(whenRequestAdded: @escaping (Int) -> Void) {
        // Get the last-update time in the local db
        let localUpdateTime = LastUpdateTable.getLastUpdateDate(database: LocalDb.sharedInstance?.database,
                                                                table: ListRequestsTable.TABLE,
                                                                key: self.listKey as String)
        
        if (localUpdateTime != nil) {
            let nsUpdateTime = localUpdateTime as NSDate?
            
            // Get the relevant records from the remote
            fbQueryRef = databaseRef.queryOrdered(byChild:"lastUpdated").queryStarting(atValue: nsUpdateTime!.toFirebase())
            fbQueryRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
                let newRequest = self.getGroceryRequestFromSnapshot(snapshot)
                
                self.handleRequestAddition(request: newRequest!, whenRequestAdded: whenRequestAdded)
                self.addRequestToLocal(request: newRequest!)
            })

            // Get the up-to-date records from the local
            let localRequests = ListRequestsTable.getRequestsByListKey(database: LocalDb.sharedInstance?.database,
                                                                       listKey: self.listKey as String)
            
            // Handle each local record
            for request in localRequests {
                self.handleRequestAddition(request: request, whenRequestAdded: whenRequestAdded)
            }
        }
        else {
            // Observe all records from remote
            databaseRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
                let newRequest = self.getGroceryRequestFromSnapshot(snapshot)
                
                self.handleRequestAddition(request: newRequest!, whenRequestAdded: whenRequestAdded)
                self.addRequestToLocal(request: newRequest!)
            })
        }
    }
    
    private func addRequestToLocal(request:GroceryRequest) {
        // Add the updated record to the local database
        ListRequestsTable.addRequest(database: LocalDb.sharedInstance?.database, request: request, listKey: self.listKey as String)

        // Update the local update time
        LastUpdateTable.setLastUpdate(database: LocalDb.sharedInstance?.database,
                                      table: ListRequestsTable.TABLE,
                                      key: self.listKey as String,
                                      lastUpdate: request.lastUpdated as Date)
    }
    
    private func handleRequestAddition(request:GroceryRequest, whenRequestAdded: @escaping (Int) -> Void) {
        // Don't append the same request twice
        if (findRequestIndex(id: request.id) == nil) {
            self.groceryRequests.append(request)
            
            // Checking index explicitly - For multithreading safety
            let newRequestIndex = findRequestIndex(id: request.id)
            whenRequestAdded(newRequestIndex!)
        }
    }

    func observeRequestModification(whenRequestModified: @escaping (_: Int) -> Void) {
        databaseRef.observe(FIRDataEventType.childChanged, with: { (snapshot) in
            let updatedRequest = self.getGroceryRequestFromSnapshot(snapshot as FIRDataSnapshot)!
            let updatedIndex = self.findRequestIndex(id: updatedRequest.id)!

            self.groceryRequests[updatedIndex] = updatedRequest
            
            // Save to local
            self.addRequestToLocal(request: updatedRequest)
            
            whenRequestModified(updatedIndex)
        })
    }

    func removeObservers() {
        databaseRef.removeAllObservers()
        fbQueryRef.removeAllObservers()
    }

    private func findRequestIndex(id: NSString) -> Int? {
        return groceryRequests.index(where: {$0.id == id})
    }

    private func getGroceryRequestFromSnapshot(_ snapshot: FIRDataSnapshot) -> GroceryRequest? {
        let requestKey = snapshot.key as NSString
        let requestValues = snapshot.value as! Dictionary<String, Any>

        return extractGroceryRequest(key: requestKey, values: requestValues)
    }

    private func extractGroceryRequest(key: NSString, values: Dictionary<String, Any>) -> GroceryRequest? {
        return GroceryRequest(
                id: key,
                itemName: values["itemName"]! as! NSString,
                purchased: Bool(values["purchased"]! as! String)!,
                userId: values["userId"]! as! NSString,
                lastUpdated: NSDate.fromFirebasee(values["lastUpdated"] as! Double))
    }

    func getGroceryRequest(row:Int) -> GroceryRequest? {
        if (row < getListCount()) {
            return groceryRequests[row]
        }

        return nil
    }

    func getListCount() -> Int {
        return groceryRequests.count
    }

    func addRequest(itemName: String, userId: String) {
        let request = ["itemName" : itemName,
                       "purchased" : "false",
                       "userId" : userId,
                       "lastUpdated" : FIRServerValue.timestamp()] as [String : Any]
        
        databaseRef.childByAutoId().setValue(request)
    }

    func toggleRequestPurchased(request: GroceryRequest) {
        databaseRef.child(request.id as String).updateChildValues(["purchased" : (!request.purchased).description, "lastUpdated" : FIRServerValue.timestamp()])
    }
    
    func updateRequestItemName(request: GroceryRequest) {
        databaseRef.child(request.id as String).updateChildValues(["itemName" : request.itemName, "lastUpdated" : FIRServerValue.timestamp()])
    }
}
