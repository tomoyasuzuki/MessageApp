//
//  Channel.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/31.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth

struct Channel {
    let id: String
    let name: String
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init?(_ document: QueryDocumentSnapshot){
        let data = document.data()
        let id = document.documentID
        
        if let name = data["name"] as? String {
            self.name = name
        } else {
            self.name = ""
        }
        
        self.id = id
    }
}
