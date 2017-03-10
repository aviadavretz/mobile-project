//
//  ImageDB.swift
//  MyFirstApp
//
//  Created by admin on 16/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import Firebase

class ImageDB {
    private static let defaultImage = UIImage(named: "user")
    
    static let sharedInstance: ImageDB = { ImageDB() } ()
    var storageRef: FIRStorageReference?
    
    private init() {
        configureStorage()
    }
    
    func configureStorage() {
        let storageUrl = FIRApp.defaultApp()?.options.storageBucket
        storageRef = FIRStorage.storage().reference(forURL: "gs://" + storageUrl!)
    }
    
    func storeImage(image: UIImage, userId: String) {
        storeImage(image: image, userId: userId, whenFinished: {})
    }
    
    func storeImage(image: UIImage, userId: String, whenFinished: @escaping ()->()) {
        // Don't store the default picture
        if (!(ImageDB.defaultImage!.isEqual(image))) {
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            let imagePath = "\(userId).jpg"

            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"

            self.storageRef?.child(imagePath).put(imageData!, metadata: metadata) {(metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                
                // Save the image to local storage
                LocalImageStorage.sharedInstance.saveImageToFile(image: image, name: imagePath);
                
                whenFinished()
            }
        }
    }
    
    func downloadImage(userId: String, whenFinished: @escaping (UIImage?)  -> Void) {
        var image:UIImage?
        let imagePath = "\(userId).jpg"
        
        // Try to get the image from local storage
        let url = URL(string: imagePath)
        let localImageName = url!.lastPathComponent
        
        // Check if the image is up to date.
        let needToUpdate = remoteImageWasUpdated(imagePath: imagePath)
        
        // If image exists in local storage and it's up to date
        if !needToUpdate, let image = LocalImageStorage.sharedInstance.getImageFromFile(name: localImageName) {
            
            print ("Got Image \(imagePath) from local storage.")
            whenFinished(image)
        }
        else {
            self.storageRef?.child(imagePath).data(withMaxSize: INT64_MAX) { (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                        
                    // Return the default image
                    whenFinished(ImageDB.defaultImage)
                    return
                }
                
                image = UIImage.init(data: data!)!
                
                // Save the image to local storage
                LocalImageStorage.sharedInstance.saveImageToFile(image: image!, name: imagePath);
            
                whenFinished(image)
            
            }
        }
    }
    
    private func remoteImageWasUpdated(imagePath: String) -> Bool {
        let remoteUpdateTime = getUpdateTime(imagePath: imagePath)
        let localUpdateTime = LocalImageStorage.sharedInstance.getUpdateTime(path: imagePath)
        
        print ("Remote update time: \(remoteUpdateTime)")
        print ("Local update time: \(localUpdateTime)")
        
        // Check if the remote image was updated
        if (remoteUpdateTime != nil &&
            (localUpdateTime == nil || localUpdateTime?.compare(remoteUpdateTime!) == .orderedAscending)) {
            // Download the new remote image
            print("Need to download the new \(imagePath)")
            return true
        }
        else {
            print("\(imagePath) is up to date.")
            return false
        }
    }
    
    private func getUpdateTime(imagePath: String) -> Date? {
        var updateTime: Date?
        
        // Create reference to the file whose metadata we want to retrieve
        let imageRef = self.storageRef?.child(imagePath)
        
        // Get metadata properties
        imageRef?.metadata { metadata, error in
            if let error = error {
                // An error occurred!
                print ("Error getting update time: \(error)")
                return
            }
            else {
                // Metadata now contains the metadata for the image
                updateTime = metadata?.updated
            }
        }
        
        return updateTime
    }
}
