//
//  MessageModel.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
}
