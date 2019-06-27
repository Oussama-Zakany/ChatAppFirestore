//
//  UserService.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation

class UserService {
    static let shared = UserService()
    
    func saveUser(user: User, completion: @escaping (_ result: Result<Bool,Error>) -> Void) {
        guard let userId = user.id else {
            completion(.failure(AuthError.noUser))
            return
        }
        reference(.Users).document(userId).setData(user.data) { (error) in
            if let err = error {
                completion(.failure(err))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func fetchUser(userId: String, completion: @escaping (_ result: Result<User,Error>) -> Void) {
        reference(.Users).document(userId).getDocument { (document, error) in
            if let err = error {
                completion(.failure(err))
                return
            }
            
            guard let document = document, document.exists else { return }
            guard let data = document.data() else { return }
            let user = User(_dictionary: data, _id: document.documentID)
            completion(.success(user))
        }
    }
}
