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
    let image: UIImage
    let members: [String]
    
    init(id: String, name: String, image: UIImage, members: [String]) {
        self.id = id
        self.name = name
        self.image = image
        self.members = members
    }
}
