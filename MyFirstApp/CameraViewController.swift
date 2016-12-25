//
//  CameraViewController.swift
//  MyFirstApp
//
//  Created by Naveh Ohana on 14/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LoginButtonDelegate
{
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var loginButtonView: UIButton!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var chooseImageDialog: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseImageDialog.isHidden = true
        
        // Get the User & Image (this will fetch only from cache, because the user was already fetched from DB)
        UserFirebaseDB.sharedInstance.findUserByKey( key: CurrentFirebaseUser.sharedInstance.getId()!, whenFinished: refreshLabels)
        ImageDB.sharedInstance.downloadImage(userId: CurrentFirebaseUser.sharedInstance.getId()!, whenFinished: refreshImage)
        
        initializeFacebookLoginButton()
    }
    
    func refreshLabels(user:User?) -> Void {
        let userName = user!.name!
        var finalString:String
        
        if (userName != "") {
            finalString = "\(userName)"
        }
        else {
            finalString = "Hello!"
        }
        
        self.greetingLabel.text = finalString
    }
    
    private func initializeFacebookLoginButton() {
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends])
        loginButton.delegate = self
        loginButtonView.addSubview(loginButton)
    }
    
    public func refreshImage(image:UIImage?) {
        imagePicked.image = image
        
        saveImage()
    }
    
    @IBAction func showChooseImageDialog(sender: AnyObject) {
        chooseImageDialog.isHidden = false
    }
    
    private func hideChooseImageDialog() {
        chooseImageDialog.isHidden = true
    }
    
    func saveImage() {
        // Save the image to db
        ImageDB.sharedInstance.storeImage(image: imagePicked.image!, userId: CurrentFirebaseUser.sharedInstance.getId()!)
    }
    
    public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {}
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        CurrentFirebaseUser.sharedInstance.signOut()
        FacebookAccessTokenCache.sharedInstance.clear()
        
        // Unwind back to MainController
        self.performSegue(withIdentifier: "UnwindLogOut", sender: self)
    }
    
    @IBAction func backFromChooseImageDialog(seque:UIStoryboardSegue) {
        hideChooseImageDialog()
    }
}
