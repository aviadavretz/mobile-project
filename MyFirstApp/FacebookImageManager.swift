//
//  FacebookImageManager.swift
//  MyFirstApp
//
//  Created by admin on 28/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class FacebookImageManager {

    func getFacebookProfilePic(facebookId: NSString, whenFinished: @escaping (UIImage?)->()) {
        let url = NSURL(string: "https://graph.facebook.com/\(facebookId)/picture?type=large")
        let urlRequest = NSURLRequest(url: url! as URL)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest as URLRequest, queue: OperationQueue.main) { (response:URLResponse?, data:Data?, error:Error?) -> Void in
            let image = UIImage(data: data!)
            whenFinished(image)
        }
    }
}
