//
//  GroceryListTableViewController.swift
//  MyFirstApp
//
//  Created by admin on 02/01/2017.
//  Copyright © 2017 Naveh Ohana. All rights reserved.
//

import UIKit

class GroceryListTableViewController: UITableViewController {
    var db: UserGroceryListsDB?
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeModel()

        // Display a delete button in the navigation bar for this view controller, which has the functinallity of Edit button.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    deinit {
        db!.removeObservers()
    }
    
    private func initializeModel() {
        db = UserGroceryListsDB(userKey: AuthenticationUtilities.sharedInstance.getId()! as NSString)
        db!.observeLists(whenListAddedAtIndex: listAdded, whenListDeletedAtIndex: listDeleted)
    }
    
    private func listAdded(listIndex: Int) {
        table.insertRows(at: [IndexPath(row: listIndex, section: 0)], with: UITableViewRowAnimation.fade)
    }
    
    private func listDeleted(listIndex: Int?) {
        table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return db!.getListsCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GroceryListTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroceryListTableViewCell
        
        cell.tag = indexPath.row

        let list = db!.getGroceryList(row: indexPath.row)!
        
        let dateString = TimeUtilities.getStringFromDate(date: list.date as Date, timeZone: TimeZone(secondsFromGMT: 0)!)
        
        // Update the views
        cell.titleLabel.text = "\(list.title)"
        cell.dateLabel.text = "\(dateString)"
        
        GroupsDB.sharedInstance.findGroupByKey(key: list.groupKey as String, whenFinished: { (group) in
            cell.dateLabel.text = "\(cell.dateLabel!.text!), \"\(group!.title!)\""
        })
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            deleteList(row: indexPath.row)
        }
    }

    private func deleteList(row: Int) {
        let list = db!.getGroceryList(row: row)!
        
        GroceryListsDB.sharedInstance.deleteList(id: list.id as String)
    }
    
    @IBAction func backFromNewListController(seque:UIStoryboardSegue) {
        print("Back from grocery list creation")
        
        table.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ListDetails") {
            let selectedRow = (sender as! GroceryListTableViewCell).tag
            
            // Get a reference to the destination view controller
            let destinationVC:GroceryRequestTableViewController = segue.destination as! GroceryRequestTableViewController
            
            let list:GroceryList = db!.getGroceryList(row: selectedRow)!
            
            // Pass the selected list to the next controller
            destinationVC.list = list
        }
    }
    
    override func shouldPerformSegue(withIdentifier: String, sender: Any?) -> Bool {
        // Check if the user has any groups
        if ((withIdentifier == "New List") && (!(db?.doesUserHaveGroup())!)) {
            // Stop the segue and display an alert
            let alert = UIAlertController(title: "Sorry!", message: "You can't create a grocery list because you don't have any groups yet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
}
