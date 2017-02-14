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
    var imagesCache:Dictionary<String, UIImage> = Dictionary<String, UIImage>()
    
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
                
                self.imagesCache[userId] = image
                whenFinished()
            }
        }
    }
    
    func downloadImage(userId: String, whenFinished: @escaping (UIImage?)  -> Void) {
        var image:UIImage?
        
        if (imagesCache[userId] == nil) {
            let imagePath = "\(userId).jpg"

            self.storageRef?.child(imagePath).data(withMaxSize: INT64_MAX){ (data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        
                        // We don't want it to try loading every time when an image is missing
                        self.imagesCache[userId] = ImageDB.defaultImage
                        
                        whenFinished(self.imagesCache[userId])
                        return
                    }

                    image = UIImage.init(data: data!)!
                    self.imagesCache[userId] = image
            
                    whenFinished(image)
            }
        }
        else {
            whenFinished(self.imagesCache[userId])
        }
    }
}
