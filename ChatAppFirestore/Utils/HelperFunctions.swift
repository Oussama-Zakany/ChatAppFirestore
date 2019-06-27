//
//  HelperFunctions.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation

public func getConversationId(uid1: String, uid2: String) -> String{
    return uid1 < uid2 ? uid1 + uid2 : uid2 + uid1
}
