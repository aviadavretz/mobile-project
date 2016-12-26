//
//  GroupMembersTableViewController.swift
//  MyFirstApp
//
//  Created by admin on 23/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class GroupMembersTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var group:Group?
    var db:GroupMembersDB?
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = group?.title as String?
        
        table.delegate = self
        table.dataSource = self
        
        initializeModel()
    }

    private func initializeModel() {
        db = GroupMembersDB(groupKey: group!.key)
        db!.observeGroupMembersAddition(whenMemberAdded: memberAdded)
    }

    private func memberAdded(memberIndex: Int) {
        table.insertRows(at: [IndexPath(row: memberIndex, section: 0)], with: UITableViewRowAnimation.automatic)
    }

    deinit {
        db!.removeObservers()
    }

    // MARK:  UITextFieldDelegate Methods
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return db!.getMembersCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath) as! GroupMemberCell
        
        // Fetches the appropriate item for the data source layout.
        let user = db!.getGroup(row: indexPath.row)!
        
        // Update the views
        updateUserDetailsInCell(cell: cell, userId: user.key as String)
        updateUserImageInCell(cell: cell, userId: user.key as String)
        
        return cell
    }
    
    func updateUserDetailsInCell(cell: GroupMemberCell, userId:String) {
        UserFirebaseDB.sharedInstance.findUserByKey(key: userId, whenFinished: { (user) in
            cell.nameLabel.text = "\(user!.name!)"
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
}
