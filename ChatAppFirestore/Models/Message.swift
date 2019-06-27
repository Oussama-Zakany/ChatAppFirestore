//
//  Message.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    let id: String?
    var text: String
    var toId: String
    var fromId: String
    var sentDate: Date
    var seen: Bool?
    
    var dictionary: [String: Any] {
        var dic: [String: Any] =  [
            kTEXT: text,
            kTOID: toId,
            kFROMID: fromId,
            kSENTDATE: sentDate
        ]
        
        if let seen = seen {
            dic[kSEEN] = seen
        }
        
        return dic
    }
    
    var chatPartnerId: String {
        return fromId == AuthService.shared.currentId() ? toId : fromId
    }
    
    //MARK: Initializers
    
    init?(dictionary: [String : Any], id: String? = nil) {
        guard let text = dictionary[kTEXT] as? String,
            let toId = dictionary[kTOID] as? String,
            let fromId = dictionary[kFROMID] as? String,
            let sentDate = dictionary[kSENTDATE] as? Timestamp
            else {
                return nil
        }
        
        self.id = dictionary[kID] as? String ?? id
        self.text = text
        self.toId = toId
        self.fromId = fromId
        self.sentDate = sentDate.dateValue()
        self.seen = dictionary[kSEEN] as? Bool
    }
    
    func setSeen(_ seen: Bool) {
        self.seen = seen
    }
}

extension Message: Equatable {
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
