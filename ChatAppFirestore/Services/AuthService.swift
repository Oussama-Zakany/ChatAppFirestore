//
//  AuthService.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation
import Firebase

enum AuthError: Error {
    case noUser
}

class AuthService {
    
    static let shared = AuthService()
    
    //MARK: Returning current user funcs
    
    func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    func currentUser() -> User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) as? [String : Any] {
                return User(_dictionary: dictionary)
            }
        }
        return nil
    }
    
    //MARK: Login function
    
    func loginUserWith(email: String, password: String, completion: @escaping (_ result: Result<Bool,Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (firUser, error) in
            
            if let err = error {
                completion(.failure(err))
                return
            }
            
            guard let userId = firUser?.user.uid else {
                completion(.failure(AuthError.noUser))
                return
            }
            
            UserService.shared.fetchUser(userId: userId, completion: { (result) in
                switch result {
                case .success(let user):
                    self.saveUserLocally(user: user)
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        })
    }
    
    //MARK: Register functions
    
    func registerUserWith(email: String, password: String, name: String, image: UIImage, completion: @escaping (_ result: Result<Bool,Error>) -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
            if let err = error {
                completion(.failure(err))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(AuthError.noUser))
                return
            }
            
            StorageService.shared.uploadImage(image: image, path: kPROFILE, completion: { (result) in
                switch result {
                case .success(let profileImageURL):
                    let dic: [String : Any] = [
                        kID: uid,
                        kEMAIL: email,
                        kNAME: name,
                        kPROFILEIMAGEURL: profileImageURL
                    ]
                    
                    let user = User(_dictionary: dic)
                    
                    self.saveUserLocally(user: user)
                    UserService.shared.saveUser(user: user, completion: { (result) in
                        completion(result)
                    })
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        })
    }
    
    //MARK: LogOut func
    
    func logOutCurrentUser(completion: @escaping (_ result: Result<Bool,Error>) -> Void ) {
        
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        do {
            try Auth.auth().signOut()
            completion(.success(true))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    //MARK: Save user locally
    
    func saveUserLocally(user: User) {
        UserDefaults.standard.set(user.dictionary, forKey: kCURRENTUSER)
        UserDefaults.standard.synchronize()
    }
}

