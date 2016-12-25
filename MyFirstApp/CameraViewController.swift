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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func refreshImage(image:UIImage?) {
        imagePicked.image = image
    }
    
    @IBAction func openCameraButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openPhotoLibraryButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicked.image = info[UIImagePickerControllerOriginalImage] as? UIImage

        self.dismiss(animated: true, completion: saveImage);
    }
    
    func saveImage() {
        // Save the image to db
        ImageDB.sharedInstance.storeImage(image: imagePicked.image!, userId: CurrentFirebaseUser.sharedInstance.getId()!)
    }
    
    func save() {
        let imageData = UIImageJPEGRepresentation(imagePicked.image!, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
    }
    
    public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {}
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        CurrentFirebaseUser.sharedInstance.signOut()
        FacebookAccessTokenCache.sharedInstance.clear()
        
        // Unwind back to MainController
        self.performSegue(withIdentifier: "UnwindLogOut", sender: self)
    }
}
