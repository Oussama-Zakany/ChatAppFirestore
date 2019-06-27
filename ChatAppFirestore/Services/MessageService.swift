//
//  MessageService.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation
import Firebase

class MessageService {
    
    static let shared = MessageService()
    
    func addMessage(message: Message, completion: @escaping (_ result: Result<Bool,Error>) -> Void) {
        let converId = getConversationId(uid1: message.fromId, uid2: message.toId)
        reference(.Conversation).document(converId).collection("Messages").addDocument(data: message.dictionary) { (error) in
            if let err = error {
                completion(.failure(err))
                return
            }
            
            let fromToPath = "\(message.fromId)/Users/\(message.toId)"
            let fromMessage = message
            fromMessage.setSeen(true)
            reference(.LastestMessages).document(fromToPath).setData(fromMessage.dictionary)
            
            let toFromPath = "\(message.toId)/Users/\(message.fromId)"
            let toMessage = message
            toMessage.setSeen(false)
            reference(.LastestMessages).document(toFromPath).setData(toMessage.dictionary)
            
            completion(.success(true))
        }
    }
    
    func updateSeen(message: Message) {
        if message.seen == false && message.fromId != AuthService.shared.currentId() {
            let toFromPath = "\(message.toId)/Users/\(message.fromId)"
            reference(.LastestMessages).document(toFromPath).updateData([kSEEN : true])
        }
    }
}
