//
//  StudentTableViewController.swift
//  MyFirstApp
//
//  Created by admin on 01/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class GroceryListTableViewController : UITableViewController {
    let db: GroceryFirebaseDB = GroceryFirebaseDB.sharedInstance
    @IBOutlet weak var table: UITableView!
    var deleting:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        toggleDelete()
        registerTableObserver()
    }

    deinit {
        unregisterTableObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func unregisterTableObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    func registerTableObserver() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(GroceryListTableViewController.refreshTableNotificationReceived),
                name: NSNotification.Name("groceryListsModelChanged"),
                object: nil)
    }

    @objc func refreshTableNotificationReceived() {
        table.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ListDetails") {
            let selectedRow = (sender as! GroceryListTableViewCell).tag
            
            // Get a reference to the destination view controller
            let destinationVC:GroceryRequestTableViewController = segue.destination as! GroceryRequestTableViewController
        
            let list:GroceryList = db.getGroceryList(row: selectedRow)!
            
            // Pass the selected list to the next controller
            destinationVC.list = list
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return db.getListCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GroceryListTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroceryListTableViewCell
        
        cell.tag = indexPath.row
        
        // Fetches the appropriate item for the data source layout.
        let list = db.getGroceryList(row: indexPath.row)!


        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy, HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = formatter.string(from: list.date as Date)

        // Update the views
        cell.titleLabel.text = "\(list.title)"
        cell.dateLabel.text = "\(dateString)"
        cell.deleteButton.tag = indexPath.row
        
        cell.deleteButton.isHidden = !deleting
        
        return cell
    }
    
    @IBAction func toggleDelete() {
        var deleteShouldBeHidden:Bool = false
        
        // Create a new button
        let button: UIButton = UIButton(type: UIButtonType.custom)
        
        if (!deleting) {
            // Set image for button
            button.setImage(UIImage(named: "done.png"), for: UIControlState.normal)
            
            // Set frame
            button.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
            
            // Delete should not be hidden, newButtonImage is doneImage
        }
        else {
            // Set image for button
            button.setImage(UIImage(named: "trash.png"), for: UIControlState.normal)
            
            // Set frame
            button.frame = CGRect(x: 25, y: 0, width: 30, height: 30)
            
            // Delete should be hidden, newButtonImage is trashCanImage
            deleteShouldBeHidden = true
        }

        // Add function for button
        button.addTarget(self, action: #selector(GroceryListTableViewController.toggleDelete), for: UIControlEvents.touchDown)
        let barButton = UIBarButtonItem(customView: button)
        // Assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
        
        // Show/hide the delete buttons for each cell
        for cell in table.visibleCells {
            (cell as! GroceryListTableViewCell).deleteButton.isHidden = deleteShouldBeHidden
        }
        
        deleting = !deleting
    }
    
    @IBAction func deleteList(sender: UIButton) {
        let row = (sender as UIButton).tag

        db.deleteList(id: db.getGroceryList(row: row)!.id as String)
    }
    
    @IBAction func backFromNewListController(seque:UIStoryboardSegue) {
        print("Back from grocery list creation")
        
        table.reloadData()
    }
}
