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
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var pleaseWait: UIActivityIndicatorView!
    
    // MARK: Other functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createButton.isHidden = false
        createButton.isEnabled = false
        pleaseWait.isHidden = true

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
        let accessToken = FacebookAccessTokenCache.sharedInstance.load()

        if (accessToken != nil && accessToken!.expirationDate.timeIntervalSince(Date()) > 0) {
            self.greetingPrefix = "Welcome back"
            
            AccessToken.current = accessToken
            loadUserData()
        }
    }

    private func loadUserData() {
        let userId = CurrentFirebaseUser.sharedInstance.getId()!

        UserFirebaseDB.sharedInstance.findUserByKey(key: userId,
                whenFinished: refreshUserNotificationReceived)

        ImageDB.sharedInstance.downloadImage(userId: userId, whenFinished: refreshImage)

        createButton.isEnabled = true
    }
    private func showSpinner() {
        createButton.isHidden = true
        pleaseWait.isHidden = false
        pleaseWait.startAnimating()
    }
    
    private func hideSpinner() {
        pleaseWait.stopAnimating()
        pleaseWait.isHidden = true
        createButton.isHidden = false
    }

    func refreshUserNotificationReceived(userFromDB : User?) {
        if (userFromDB != nil) {
            user = userFromDB

            refreshLabels()
            
            hideSpinner()
            
            addGroupStub(user: userFromDB!)
        }
    }
    
    private func addGroupStub(user:User) {
        var members = Array<NSString>()
        members.append(user.id)
        
        let newGroup = Group(title: "This is our group ya'll!", adminUserId: user.id, lists: Array<GroceryList>(), members: members)
        GroupFirebaseDB.sharedInstance.addGroup(group: newGroup)
    }

    @IBAction func refreshLabels() {
        let userName = user!.name!

        var finalString:String

        if (userName != "") {
            finalString = "\(greetingPrefix), \(userName)!"
        }
        else {
            finalString = "\(greetingPrefix)!"
        }

        greetingLabel.text = finalString
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
                showSpinner()
                
                loginToFirebase(authenticationToken: accessToken.authenticationToken, whenFinished: tryFindingUserInDB)
                FacebookAccessTokenCache.sharedInstance.store(accessToken)
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
        UserFirebaseDB.sharedInstance.findUserByKey(key: CurrentFirebaseUser.sharedInstance.getId()!, whenFinished: {(existingUser) in
            if (existingUser != nil) {
                self.greetingPrefix = "Welcome back"
                
                self.loadUserData()
            }
            else {
                self.greetingPrefix = "Welcome"
                
                self.createUser()
            }
        })
    }

    private func createUser() {
        let newUser = User(id: CurrentFirebaseUser.sharedInstance.getId()! as NSString,
                           name: CurrentFirebaseUser.sharedInstance.getFacebookUser()!.displayName! as NSString,
                           facebookId: CurrentFirebaseUser.sharedInstance.getFacebookUser()!.uid as NSString)

        UserFirebaseDB.sharedInstance.addUser(user: newUser, whenFinished: {(_, _) in self.loadUserData()})
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        do {
            try FIRAuth.auth()?.signOut()
            FacebookAccessTokenCache.sharedInstance.clear()
            createButton.isEnabled = false
            elapseScreenData()
        }
        catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
    }

    private func elapseScreenData() {
        greetingLabel.text = "\(defaultGreeting)!"
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
}
