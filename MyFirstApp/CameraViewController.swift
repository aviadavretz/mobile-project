//
//  CameraViewController.swift
//  MyFirstApp
//
//  Created by Naveh Ohana on 14/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var imagePicked: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageDB.sharedInstance.downloadImage(userId: User.me?.id as! String, whenFinished: refreshImage)
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
        ImageDB.sharedInstance.storeImage(image: imagePicked.image!, userId: User.me?.id as! String)
    }
    
    func save() {
        let imageData = UIImageJPEGRepresentation(imagePicked.image!, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
    }
}
