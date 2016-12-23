//
// Created by admin on 21/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FacebookCore

class FacebookAccessTokenCache {
    static let sharedInstance: FacebookAccessTokenCache = { FacebookAccessTokenCache() } ()
    let accessTokenKey = "accessToken"
    let expirationDateKey = "expirationDate"

    private init() {}

    func load() -> AccessToken? {
        let cachedAccessToken = UserDefaults.standard.object(forKey: accessTokenKey)
        let cachedExpiration = UserDefaults.standard.object(forKey: expirationDateKey)

        if let accessToken = cachedAccessToken as? String,
           let expiration = cachedExpiration as? Date {
            return AccessToken.init(authenticationToken: accessToken, expirationDate: expiration)
        }

        return nil
    }

    func store(_ accessToken: AccessToken) {
        UserDefaults.standard.set(accessToken.authenticationToken, forKey: accessTokenKey)
        UserDefaults.standard.set(accessToken.expirationDate, forKey: expirationDateKey)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: expirationDateKey)
    }
}