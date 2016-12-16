//
//  ViewController.swift
//  MyFirstApp
//
//  Created by Naveh Ohana on 09/11/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit
import Darwin

class MainController: UIViewController {
    let user:User = User(id: UIDevice.current.identifierForVendor!.uuidString as NSString);
    let db:UserDB = UserDB.sharedInstance;
    
    // MARK: Properties
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    
    // MARK: Actions
    @IBAction func FirstNameChanged(sender: AnyObject) {
        let newNameNS:NSString = sender.text! as NSString
        
        self.user.firstName = newNameNS
        refreshLabels()
    }
    
    @IBAction func LastNameChanged(sender: AnyObject) {
        let newNameNS:NSString = sender.text! as NSString
        
        self.user.lastName = newNameNS
        refreshLabels()
    }
    
    @IBAction func SelectAllText(sender: UITextField) {
        sender.selectAll(sender)
    }
    
    @IBAction func Exit(sender: AnyObject) {
        // Exit the application
        print("Bye")
        exit(0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UserCreated") {
            // Add this user
            db.addUser(user: user)
        }
    }
    
    @IBAction func ShowItems(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "ItemTableViewController")
        
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.modalPresentationStyle = UIModalPresentationStyle.formSheet
        
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: Other functions
    override func viewDidLoad() {
        super.viewDidLoad()
        user.firstName=""
        user.lastName=""
    }
    
    func refreshLabels() {
        var finalString:String
        
        if (user.firstName != "" && user.lastName != "") {
            finalString = "Hello, \(user.firstName!) \(user.lastName!)!"
        }
        else if (user.firstName != "") {
            finalString = "Hello, \(user.firstName!)!"
        }
        else if (user.lastName != "") {
            finalString = "Hello, Mr. \(user.lastName!)!"
        }
        else {
            finalString = "Hello!"
        }
        
        studentNameLabel.text = finalString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
