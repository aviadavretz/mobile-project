//
//  GroceryRequestTableViewController.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit

class GroceryRequestTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var db:GroceryRequestsDB? = nil
    var list:GroceryList? = nil
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = list?.title as String?
        
        table.delegate = self
        table.dataSource = self

        initializeModel()
        
        // tapRecognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
    }

    private func initializeModel() {
        db = GroceryRequestsDB(listKey: list!.id)
        db!.observeRequestAddition(whenRequestAdded: requestAdded)
        db!.observeRequestModification(whenRequestModified: requestModified)
        
        ImageDB.observeImageModification(whenImageModified: imageModified)
    }
    
    private func imageModified() {
        if (table != nil) {
            table.reloadData()
        }
    }
    
    private func requestAdded(requestIndex: Int) {
        table.insertRows(at: [IndexPath(row: requestIndex, section: 0)],
                         with: UITableViewRowAnimation.automatic)
    }

    private func requestModified(requestIndex: Int) {
        table.reloadRows(at: [IndexPath(row: requestIndex, section: 0)],
                        with: UITableViewRowAnimation.automatic)
    }

    deinit {
        db!.removeObservers()
    }

    // MARK:  UITextFieldDelegate Methods
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return db!.getListCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryRequestTableViewCell", for: indexPath) as! GroceryRequestTableViewCell
        manageCell(cell: cell, row: indexPath.row)
        
        return cell
    }
    
    private func manageCell(cell: GroceryRequestTableViewCell, row: Int) {
        cell.showSpinner()

        // Fetches the appropriate item
        let item = db!.getGroceryRequest(row: row)
        let userId = item?.userId as! String
        
        // Update the views
        updateUserDetailsInCell(cell: cell, userId: userId)
        updateUserImageInCell(cell: cell, userId: userId)
        updateItemNameInCell(cell: cell, item: item!)
    }

    func updateUserDetailsInCell(cell: GroceryRequestTableViewCell, userId: String) {
        UsersDB.sharedInstance.findUserByKey(key: userId, whenFinished: { (user) in
            if (user != nil) {
                cell.nameLabel.text = "\(user!.name!)"
            }
        })
    }

    func updateUserImageInCell(cell: GroceryRequestTableViewCell, userId: String) {
        ImageDB.sharedInstance.downloadImage(userId: userId, whenFinished: { (image) in
            cell.imagez.image = image
            
            cell.hideSpinner()
        })
    }

    private func updateItemNameInCell(cell: GroceryRequestTableViewCell, item: GroceryRequest) {
        if (item.purchased) {
            updatePurchasedItemNameInCell(cell: cell, name: item.itemName)
        } else {
            updateRequestedItemNameInCell(cell: cell, name: item.itemName)
        }
    }

    private func updatePurchasedItemNameInCell(cell: GroceryRequestTableViewCell, name: NSString) {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: name as String)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))

        cell.itemLabel.attributedText = attributeString
        cell.itemLabel.textColor = UIColor.gray
        cell.itemLabel.alpha = 0.2
    }

    private func updateRequestedItemNameInCell(cell: GroceryRequestTableViewCell, name: NSString) {
        cell.itemLabel.text = name as String?
        cell.itemLabel.textColor = UIColor.black
        cell.itemLabel.alpha = 1
    }

    // MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let request = db!.getGroceryRequest(row: indexPath.row) {
            db!.toggleRequestPurchased(request: request)
        }
    }
    
    // Called when long press occurred
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            
            // Get the path in which the long press occured
            if let indexPath = table.indexPathForRow(at: touchPoint) {
                // Get the referenced request
                if let request = db!.getGroceryRequest(row: indexPath.row) {
                    // Make sure the current user created the request
                    if (request.userId.isEqual(to: AuthenticationUtilities.sharedInstance.getId()!)) {
                        // Table view cells are reused and should be dequeued using a cell identifier.
                        let cell = table.dequeueReusableCell(withIdentifier: "GroceryRequestTableViewCell", for: indexPath) as! GroceryRequestTableViewCell
                        manageCell(cell: cell, row: indexPath.row)
                        
                        cell.startEditing(whenFinishedEditing: { (newItemName) in
                            request.itemName = newItemName as NSString
                            
                            // Save the new item name
                            self.db!.updateRequestItemName(request: request)
                        })
                    }
                }
            }
        }
    }

    @IBAction func backFromNewRequestController(seque:UIStoryboardSegue) {}
}
