//
//  NewGroceryRequestViewController.swift
//  MyFirstApp
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit
import Darwin

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
            
            let newRequest:GroceryRequest = GroceryRequest(user: User.me!)
            newRequest.itemName = itemName
            
            destinationVC.list?.addRequest(request: newRequest)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
