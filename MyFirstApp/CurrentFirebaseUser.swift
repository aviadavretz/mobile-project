//
// Created by admin on 23/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import Firebase

class CurrentFirebaseUser {
    static let sharedInstance: CurrentFirebaseUser = { CurrentFirebaseUser() } ()

    private init() {}

    func getId() -> String? {
        return getCurrentUser()?.uid
    }

    func getFacebookUser() -> FIRUserInfo? {
        let currentUser = getCurrentUser()
        guard let index = currentUser?.providerData.index(where: { $0.providerID.contains("facebook.com") }) else {
            return nil
        }

        return currentUser!.providerData[index]
    }

    private func getCurrentUser() -> FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
    
    public func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out from Firebase: \(signOutError)")
        }
    }
}
