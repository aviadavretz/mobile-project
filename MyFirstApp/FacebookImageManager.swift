//
//  FacebookImageManager.swift
//  MyFirstApp
//
//  Created by admin on 28/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit
import FacebookCore

class FacebookImageManager {

    func getFacebookProfilePic(facebookId: NSString, whenFinished: @escaping (UIImage?)->()) {
        let url = URL(string: "https://graph.facebook.com/\(facebookId)/picture?type=large")

        do {
            let image = try UIImage(data: NSData(contentsOf: url!) as Data)
            whenFinished(image)
        }
        catch let error as NSError {
            print ("Error fetching user profile photo: \(error)")
        }
    }
}
