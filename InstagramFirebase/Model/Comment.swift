//
//  Comment.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 30.03.23.
//

import UIKit

struct Comment {
    let user: User
    
    let text: String
    let uid: String
    let creationDate: Date
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
