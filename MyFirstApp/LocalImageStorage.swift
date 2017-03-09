//
//  LocalImageStorage.swift
//  MyFirstApp
//
//  Created by admin on 09/03/2017.
//  Copyright © 2017 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class LocalImageStorage {
    static let sharedInstance: LocalImageStorage = { LocalImageStorage() } ()
    
    public func saveImageToFile(image:UIImage, name:String) {
        // Create the data for the image
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            
            // Get the filename
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            
            // Write the data to the file
            try? data.write(to: filename)
            
            print("Saved Image to local storage: \(name)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    public func getImageFromFile(name:String)->UIImage? {
        // Get the filename
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        
        // Get the UIImage from the file
        return UIImage(contentsOfFile:filename.path)
    }
}
