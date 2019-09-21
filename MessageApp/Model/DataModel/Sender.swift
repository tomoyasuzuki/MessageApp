//
//  Sender.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/31.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import MessageKit

struct Sender: SenderType {
    var senderId: String
    
    var displayName: String
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
