//
//  GroupTableViewController.swift
//  MyFirstApp
//
//  Created by admin on 23/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class GroupTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var group:Group? = nil
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = group?.title as String?
        
        table.delegate = self
        table.dataSource = self
    }
    
//    private func initializeModel() {
//        db = GroceryRequestsDB(listKey: list!.id)
//        db!.observeRequestAddition()
//        db!.observeRequestModification()
//    }
    
//    private func registerRequestAddedObserver() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(GroceryRequestTableViewController.requestAdded(notification:)),
//            name: NSNotification.Name(GroceryRequestsDB.requestAddedNotification),
//            object: nil)
//    }
    
//    private func registerRequestModifiedObserver() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(GroceryRequestTableViewController.requestModified(notification:)),
//            name: NSNotification.Name(GroceryRequestsDB.requestModifiedNotification),
//            object: nil)
//    }
    
//    @objc private func requestAdded(notification: Notification) {
//        guard let userInfo = notification.userInfo else {
//            table.reloadData()
//            return
//        }
//        
//        table.insertRows(at: [IndexPath(row: userInfo["row"] as! Int, section: 0)],
//                         with: UITableViewRowAnimation.automatic)
//    }
    
//    @objc private func requestModified(notification: Notification) {
//        guard let userInfo = notification.userInfo else {
//            table.reloadData()
//            return
//        }
//        
//        table.reloadRows(at: [IndexPath(row: userInfo["row"] as! Int, section: 0)],
//                         with: UITableViewRowAnimation.automatic)
//    }
    
//    deinit {
//        db!.removeObservers()
//        unregisterObservers()
//    }
    
//    private func unregisterObservers() {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    // MARK:  UITextFieldDelegate Methods
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group!.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath) as! GroupMemberCell
        
        // Fetches the appropriate item for the data source layout.
        let item = group?.members[indexPath.row]
        
        // Update the views
        updateUserDetailsInCell(cell: cell, userId: item as! String)
        updateUserImageInCell(cell: cell, userId: item as! String)
        
        return cell
    }
    
    func updateUserDetailsInCell(cell: GroupMemberCell, userId:String) {
        UserFirebaseDB.sharedInstance.findUserByKey(key: userId, whenFinished: { (user) in
            cell.nameLabel.text = "\(user!.name!)"
            
            // Fetch the user's group
            if let groupId = user?.groupKey {
                GroupFirebaseDB.sharedInstance.findGroupByKey(key: groupId as String, whenFinished: { (group) in })
            }
        })
    }
    
    func updateUserImageInCell(cell: GroupMemberCell, userId: String) {
        ImageDB.sharedInstance.downloadImage(userId: userId, whenFinished: { (image) in
            if (image != nil) {
                cell.imagez.image = image
            } else {
                cell.imagez.image = UIImage(named: "user.png")
            }
        })
    }
    
    // MARK: UITableViewDelegate Methods
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let request = db!.getGroceryRequest(row: indexPath.row) {
//            db!.toggleRequestPurchased(request: request)
//        }
//    }
    
    @IBAction func backFromNewMemberController(seque:UIStoryboardSegue) {}
}
