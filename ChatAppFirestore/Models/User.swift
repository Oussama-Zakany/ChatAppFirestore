//
//  User.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    let id: String?
    var email: String
    var name: String
    var profileImageURL: String
    
    var data: [String: Any] {
        return [
            kEMAIL: email,
            kNAME: name,
            kPROFILEIMAGEURL: profileImageURL
        ]
    }
    
    var dictionary: [String: Any] {
        var dic: [String: Any] =  [
            kEMAIL: email,
            kNAME: name,
            kPROFILEIMAGEURL: profileImageURL
        ]
        
        if let id = id {
            dic[kID] = id
        }
        
        return dic
    }
    
    //MARK: Initializers
    
    init(_dictionary: [String : Any], _id: String? = nil) {
        id = _dictionary[kID] as? String ?? _id
        email = _dictionary[kEMAIL] as? String ?? ""
        name = _dictionary[kNAME] as? String ?? ""
        profileImageURL = _dictionary[kPROFILEIMAGEURL] as? String ?? ""
    }
}

