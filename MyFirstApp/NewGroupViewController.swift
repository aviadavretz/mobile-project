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
            
            GroupFirebaseDB.sharedInstance.addGroup(groupTitle: title, forUserKey: AuthenticationUtilities.sharedInstance.getId()! as NSString)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
