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
    var user:User? = nil;
    var greetingPrefix:String = "Hello"
    
    // MARK: Properties
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    
    // MARK: Actions
    @IBAction func SelectAllText(sender: UITextField) {
        sender.selectAll(sender)
    }
    
    @IBAction func Exit(sender: AnyObject) {
        // Exit the application
        exit(0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UserCreated") {
            
            let deviceId = UIDevice.current.identifierForVendor!.uuidString
            let newUser = User(id: deviceId as NSString, firstName: firstNameTextView.text! as NSString, lastName: lastNameTextView.text! as NSString)
            
            // Add this user
            UserFirebaseDB.sharedInstance.addUser(user: newUser)
            
            User.me = newUser
        }
    }
    
    // MARK: Other functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserFirebaseDB.sharedInstance.findUserByKey(key: UIDevice.current.identifierForVendor!.uuidString,
                                                           whenFinished: refreshUserNotificationReceived)
        
        ImageDB.sharedInstance.downloadImage(userId: UIDevice.current.identifierForVendor!.uuidString, whenFinished: refreshImage)
    }

    private func refreshImage(image:UIImage?) {
        userImage.image = image
    }

    func refreshUserNotificationReceived(userFromDB : User?) {
        if (userFromDB != nil) {
            user = userFromDB
            
            createButton.setTitle("Continue", for: .normal)
            greetingPrefix = "Welcome back"
            
            refreshLabelsByUserData()
        }
    }
    
    func refreshLabelsByUserData() {
        firstNameTextView.text = user?.firstName as String?
        lastNameTextView.text = user?.lastName as String?
        
        refreshLabels()
    }
    
    @IBAction func refreshLabels() {
        let firstName = firstNameTextView.text!
        let lastName = lastNameTextView.text!
        
        var finalString:String
        
        if (firstName != "" && lastName != "") {
            finalString = "\(greetingPrefix), \(firstName) \(lastName)!"
        }
        else if (firstName != "") {
            finalString = "\(greetingPrefix), \(firstName)!"
        }
        else if (firstName != "") {
            finalString = "\(greetingPrefix), Mr. \(lastName)!"
        }
        else {
            finalString = "\(greetingPrefix)!"
        }
        
        studentNameLabel.text = finalString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
