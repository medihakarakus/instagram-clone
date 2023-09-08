//
//  User.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 17.03.23.
//
//
import UIKit

struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
        self.uid = uid
    }
}
