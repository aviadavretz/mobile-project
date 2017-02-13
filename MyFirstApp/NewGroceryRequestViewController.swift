//
//  NewGroceryRequestViewController.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit

class NewGroceryRequestViewController : UIViewController {
    // MARK: Properties
    @IBOutlet weak var itemNameTextView: UITextField!
    
    // MARK: Actions
    @IBAction func SelectAllText(sender: UITextField) {
        sender.selectAll(sender)
    }
    
    @IBAction func clearAll(sender: AnyObject) {
        let emptyString = ""
        
        itemNameTextView.text = emptyString
    }
    
    // MARK: Other functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UnwindNewRequest") {
            // Get a reference to the destination view controller
            let destinationVC:GroceryRequestTableViewController = segue.destination as! GroceryRequestTableViewController
            
            let itemName = itemNameTextView.text! as NSString
            
            destinationVC.db?.addRequest(itemName: itemName as String, userId: CurrentUserUtilities.sharedInstance.getId()!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
