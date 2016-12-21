//
// Created by admin on 21/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import Firebase

class FacebookUserData {
    static let sharedInstance: FacebookUserData = { FacebookUserData() } ()

    func getUserId() -> String? {
        if let currentUser = getFirebaseUser() {
            return getFacebookData(user: currentUser).uid
        }

        return nil
    }

    func getDisplayName() -> String? {
        if let currentUser = getFirebaseUser() {
            return getFacebookData(user: currentUser).displayName
        }

        return nil
    }

    private func getFirebaseUser() -> FIRUser? {
        return FIRAuth.auth()?.currentUser
    }

    private func getFacebookData(user: FIRUser) -> FIRUserInfo {
        // TODO : You can't rely that facebook will be first index always
        return user.providerData[0]
    }
}