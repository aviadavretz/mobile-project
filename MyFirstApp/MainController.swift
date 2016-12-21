//
//  ViewController.swift
//  MyFirstApp
//
//  Created by Naveh Ohana on 09/11/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit
import Darwin
import FacebookLogin
import FacebookCore
import Firebase

class MainController: UIViewController, LoginButtonDelegate {
    let defaultGreeting = "Hello"
    var user:User? = nil;
    var greetingPrefix:String = ""
    
    // MARK: Properties
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    @IBOutlet weak var loginButtonView: UIView!
    
    // MARK: Other functions
    override func viewDidLoad() {
        super.viewDidLoad()

        greetingPrefix = defaultGreeting
        initializeFacebookLoginButton()
        initializeCurrentUserData()
    }

    func initializeFacebookLoginButton() {
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends])
        loginButton.delegate = self
        loginButtonView.addSubview(loginButton)
    }

    func initializeCurrentUserData() {
        let accessToken = AccessTokenCache.sharedInstance.load()

        if (accessToken != nil && accessToken!.expirationDate.timeIntervalSince(Date()) > 0) {
            AccessToken.current = accessToken
            loadUserData()
        }
    }

    private func loadUserData() {
        let userId = FacebookUserData.sharedInstance.getUserId()!

        UserFirebaseDB.sharedInstance.findUserByKey(key: userId,
                whenFinished: refreshUserNotificationReceived)

        ImageDB.sharedInstance.downloadImage(userId: userId, whenFinished: refreshImage)

        createButton.isEnabled = true
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

    private func refreshImage(image:UIImage?) {
        userImage.image = image
    }

    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            print("User cancelled login.")
        case .success( _, let declinedPermissions, let accessToken):
            if declinedPermissions.count > 0 {
                // TODO : Show that asshole an angry message
            }
            else {
                loginToFirebase(authenticationToken: accessToken.authenticationToken, whenFinished: tryFindingUserInDB)
                AccessTokenCache.sharedInstance.store(accessToken)
            }
        }
    }

    private func loginToFirebase(authenticationToken: String, whenFinished: @escaping () -> Void) {
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: authenticationToken)

        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print("Error logging in : \(error)")
                return
            }

            whenFinished()
        }
    }

    private func tryFindingUserInDB() {
        UserFirebaseDB.sharedInstance.findUserByKey(key: FacebookUserData.sharedInstance.getUserId()!, whenFinished: {(existingUser) in
            if (existingUser != nil) {
                self.loadUserData()
            }
            else {
                self.createUser()
            }
        })
    }

    private func createUser() {
        let newUser = User(id: FacebookUserData.sharedInstance.getUserId()! as NSString,
                           firstName: FacebookUserData.sharedInstance.getDisplayName()! as NSString,
                           lastName: "" as NSString)

        UserFirebaseDB.sharedInstance.addUser(user: newUser, whenFinished: {(_, _) in self.loadUserData()})
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        do {
            try FIRAuth.auth()?.signOut()
            AccessTokenCache.sharedInstance.clear()
            createButton.isEnabled = false
            elapseScreenData()
        }
        catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
    }

    private func elapseScreenData() {
        studentNameLabel.text = defaultGreeting
        firstNameTextView.text = ""
        lastNameTextView.text = ""
        userImage.image = UIImage(named: "user")
    }

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

//            let deviceId = UIDevice.current.identifierForVendor!.uuidString
//            let newUser = User(id: deviceId as NSString, firstName: firstNameTextView.text! as NSString, lastName: lastNameTextView.text! as NSString)
//
//            // Add this user
//            UserFirebaseDB.sharedInstance.addUser(user: newUser)
//
//            User.me = newUser
        }
    }
}