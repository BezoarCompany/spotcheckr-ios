//
//  Post.swift
//  spotcheck-ios
//
//  Created by Miguel Paysan on 1/29/20.
//  Copyright © 2020 Miguel Paysan. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Post: Codable {
    static let POSTS_COLLECTION_NAME = "posts"
    let postId: String
    
    var authorId = "",
    authorName = "",
    createdAt = "",
    updatedAt = "",
    question = ""
    
}

protocol PostsService {}

//Refer to https://medium.com/@foffer/easily-parse-firebase-object-in-swift-bfe151eada41
extension PostsService {
    
    var firestore: Firestore { return Firestore.firestore() }
    
    func fetchPost(withId id: String, completion: @escaping (Post?) -> Post?) {
        
        let docRef = firestore.collection(Post.POSTS_COLLECTION_NAME).document(id)
        docRef.getDocument { docSnapshot, error in
            guard error == nil, let doc = docSnapshot, doc.exists == true else {
                print(error)
                return
            }
            
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd kk:mm:ss Z"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            //Make a mutable copy of the NSDictionary
            var dict = doc.data()
            
            for (key, value) in dict! {
                //We need to check if the value is a Timestamp and parse it as a string, since you can't serialize a Timestamp. This might be true for other types you have serverside.
                if let value = value as? Timestamp {
                    dict?[key] = dateFormatter.string(from: value.dateValue())
                }
            }
            
            //Serialize the Dictionary into a JSON Data representation then decode it using the Decoder()
            if let data = try? JSONSerialization.data(withJSONObject: dict!, options: []) {
                let post = try? decoder.decode(Post.self, from: data)
                completion(post)
            }
        }
    }
}



