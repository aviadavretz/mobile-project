//
//  MyFuckingTableController.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit

class GroceryRequestTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    let db:GroceryDB = GroceryDB.sharedInstance;
    var list:GroceryList? = nil
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
    }
    
    // MARK:  UITextFieldDelegate Methods
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (list?.requests.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GroceryRequestTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroceryRequestTableViewCell
        
        // Fetches the appropriate item for the data source layout.
        let item = list?.requests[indexPath.row]
        
        // Update the views
        cell.nameLabel.text = "\(item?.user.firstName! as! String) \(item?.user.lastName! as! String)"
        cell.imagez.image = UIImage(named: "launch.jpg")! // TODO: item.student.photo
        
        // Check if the item was purchased
        if (item?.purchased)! {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string:item!.itemName! as String)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            
            cell.itemLabel.attributedText = attributeString
            cell.itemLabel.textColor = UIColor.gray
            cell.itemLabel.alpha = 0.2
        }
        else {
            cell.itemLabel.text = item?.itemName as String?
            cell.itemLabel.textColor = UIColor.black
            cell.itemLabel.alpha = 1
        }
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // Toggle the purchase
        list?.requests[indexPath.row].togglePurchased()
        
        // TODO: Refresh the cell UI
        table.reloadData()
    }
    
    @IBAction func backFromNewRequestController(seque:UIStoryboardSegue) {
        print("Back from grocery request creation")
        
        db.updateList(list: list!)
        
        table.reloadData()
    }
}
