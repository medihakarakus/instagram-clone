//
//  FirebaseUtils.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 26.03.23.
//

import Foundation
import Firebase

extension Database {
    static func fetchUserWithUID(_ uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { err in
            print("Failed to fetch user for posts: ", err)
        }
    }
}
