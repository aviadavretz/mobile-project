//
//  NewGroupViewController.swift
//  MyFirstApp
//
//  Created by admin on 25/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit

class NewGroupViewController: UIViewController {
    @IBOutlet weak var titleTextView: UITextField!
    
    @IBAction func SelectAllText(sender: UITextField) {
        sender.selectAll(sender)
    }
    
    @IBAction func clearAll(sender: AnyObject) {
        let emptyString = ""
        
        titleTextView.text = emptyString
    }
    
    // MARK: Other functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UnwindNewGroup") {
            let title = titleTextView.text! as NSString
            
            let group:Group = Group(key: "-1", title:title, lists: Array<GroceryList>(), members: Array<NSString>())
            
            GroupFirebaseDB.sharedInstance.addGroup(group: group, forUserId: CurrentFirebaseUser.sharedInstance.getId()! as NSString)
            
            // Get a reference to the destination view controller
            let destinationVC:GroupTableViewController = segue.destination as! GroupTableViewController
            destinationVC.group = group
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
