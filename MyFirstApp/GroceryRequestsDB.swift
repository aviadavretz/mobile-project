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
    var groceryRequests: Array<GroceryRequest> = []

    init(listKey: NSString) {
        databaseRef = FIRDatabase.database().reference(withPath: "\(rootNode)/\(listKey)/\(requestsNode)")
    }

    func observeRequestAddition(whenRequestAdded: @escaping (_: Int) -> Void) {
        databaseRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            let addedRequest = self.getGroceryRequestFromSnapshot(snapshot as FIRDataSnapshot)!

            self.groceryRequests.append(addedRequest)
            whenRequestAdded(self.groceryRequests.count - 1)
        })
    }

    func observeRequestModification(whenRequestModified: @escaping (_: Int) -> Void) {
        databaseRef.observe(FIRDataEventType.childChanged, with: { (snapshot) in
            let updatedRequest = self.getGroceryRequestFromSnapshot(snapshot as FIRDataSnapshot)!
            let updatedIndex = self.findRequestIndex(id: updatedRequest.id)!

            self.groceryRequests[updatedIndex] = updatedRequest
            whenRequestModified(updatedIndex)
        })
    }

    func removeObservers() {
        databaseRef.removeAllObservers()
    }

    private func findRequestIndex(id: NSString) -> Int? {
        return groceryRequests.index(where: {$0.id == id})
    }

    private func getGroceryRequestFromSnapshot(_ snapshot: FIRDataSnapshot) -> GroceryRequest? {
        let requestKey = snapshot.key as NSString
        let requestValues = snapshot.value as! Dictionary<String, String>

        return extractGroceryRequest(key: requestKey, values: requestValues)
    }

    private func extractGroceryRequest(key: NSString, values: Dictionary<String, String>) -> GroceryRequest? {
        return GroceryRequest(
                id: key,
                itemName: values["itemName"]! as NSString,
                purchased: Bool(values["purchased"]!)!,
                userId: values["userId"]! as NSString)
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
                       "userId" : userId]

        databaseRef.childByAutoId().setValue(request)
    }

    func toggleRequestPurchased(request: GroceryRequest) {
        databaseRef.child(request.id as String).updateChildValues(["purchased" : (!request.purchased).description])
    }
}