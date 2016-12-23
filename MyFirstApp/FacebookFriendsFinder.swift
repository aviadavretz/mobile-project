//
// Created by admin on 20/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FacebookCore

class FacebookFriendsFinder {
    func find(forEachFriend: @escaping (_: User?) -> Void) {
        let connection = GraphRequestConnection()

        connection.add(GraphRequest(graphPath: "/me/friends", parameters: ["fields": "name, id"])) {
            (httpResponse, result) in
            switch result {
                case .success(let response):
                    let data = response.dictionaryValue!["data"]! as! NSArray

                    data.forEach( {(value) in
                        let friendData = value as! NSDictionary
                        UserFirebaseDB.sharedInstance.findUserByKey(key: friendData["id"] as! String, whenFinished: forEachFriend)
                    })
                case .failed(let error):
                    print("Graph Request Failed: \(error)")
            }
        }

        connection.start()
    }
}
