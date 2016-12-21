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
        registerRequestAddedObserver()
        registerRequestModifiedObserver()
    }

    private func initializeModel() {
        db = GroceryRequestsDB(listKey: list!.id)
        db!.observeRequestAddition()
        db!.observeRequestModification()
    }

    private func registerRequestAddedObserver() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(GroceryRequestTableViewController.requestAdded(notification:)),
                name: NSNotification.Name(GroceryRequestsDB.requestAddedNotification),
                object: nil)
    }

    private func registerRequestModifiedObserver() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(GroceryRequestTableViewController.requestModified(notification:)),
                name: NSNotification.Name(GroceryRequestsDB.requestModifiedNotification),
                object: nil)
    }

    @objc private func requestAdded(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            table.reloadData()
            return
        }
        
        table.insertRows(at: [IndexPath(row: userInfo["row"] as! Int, section: 0)],
                with: UITableViewRowAnimation.automatic)
    }

    @objc private func requestModified(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            table.reloadData()
            return
        }

        table.reloadRows(at: [IndexPath(row: userInfo["row"] as! Int, section: 0)],
                with: UITableViewRowAnimation.automatic)
    }

    deinit {
        db!.removeObservers()
        unregisterObservers()
    }

    private func unregisterObservers() {
        NotificationCenter.default.removeObserver(self)
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
        
        // Fetches the appropriate item for the data source layout.
        let item = db!.getGroceryRequest(row: indexPath.row)
        let userId = item?.userId as! String
        
        // Update the views
        updateUserDetailsInCell(cell: cell, userId: userId)
        updateUserImageInCell(cell: cell, userId: userId)
        updateItemNameInCell(cell: cell, item: item!)
        
        return cell
    }

    func updateUserDetailsInCell(cell: GroceryRequestTableViewCell, userId: String) {
        UserFirebaseDB.sharedInstance.findUserByKey(key: userId, whenFinished: { (user) in
            cell.nameLabel.text = "\(user!.firstName!) \(user!.lastName!)"
        })
    }

    func updateUserImageInCell(cell: GroceryRequestTableViewCell, userId: String) {
        ImageDB.sharedInstance.downloadImage(userId: userId, whenFinished: { (image) in
            if (image != nil) {
                cell.imagez.image = image
            } else {
                cell.imagez.image = UIImage(named: "user.png")
            }
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

    @IBAction func backFromNewRequestController(seque:UIStoryboardSegue) {
//        table.reloadData()
    }
}
