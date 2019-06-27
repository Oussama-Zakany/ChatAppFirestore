//
//  FCollectionReference.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case Users
    case Conversation
    case LastestMessages
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}

func reference(_ collectionReference: String) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference)
}

