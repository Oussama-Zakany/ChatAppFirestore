//
//  StorageService.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation
import FirebaseStorage

enum StorageError: Error {
    case noImage
}

class StorageService {
    
    static let shared = StorageService()
    private let reference = Storage.storage().reference()
    
    func uploadImage(image: UIImage, path: String, completion: @escaping (_ result: Result<String,Error>) -> ()) {
        
        guard let data = image.jpegData(compressionQuality: 0.4) else {
            completion(.failure(StorageError.noImage))
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let storageRef = reference.child(path).child(imageName)
        
        storageRef.putData(data, metadata: metadata) { (meta, error) in
            if let err = error {
                completion(.failure(err))
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if let err = error {
                    completion(.failure(err))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(StorageError.noImage))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            })
        }
        
    }
    
    func downloadImage(at url: URL, completion: @escaping (_ result: Result<UIImage,Error>) -> Void) {
        let reference = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        reference.getData(maxSize: megaByte) { data, error in
            if let err = error {
                completion(.failure(err))
                return
            }
            
            guard let imageData = data, let image = UIImage(data: imageData) else {
                completion(.failure(StorageError.noImage))
                return
            }
            
            completion(.success(image))
        }
    }
}

