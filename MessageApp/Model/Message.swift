//
//  MessageModel.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//
import MessageKit
import FirebaseAuth
import FirebaseFirestore

struct Message: MessageType {
    var messageId: String
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    var content: String
    
    
    init(sender: SenderType, content: String) {
        self.sender = Sender(senderId: sender.senderId, displayName: sender.displayName)
        self.messageId = ""
        self.sentDate = Date()
        self.kind = .text(content)
        self.content = content
    }
    
    
    init?(document: QueryDocumentSnapshot) {
        let sentDate = document.data()["sentDate"] as? Timestamp
        let senderName = document.data()["senderName"] as? String
        let senderId = document.data()["senderID"] as? String
        
        self.messageId = document.documentID
        self.sender = Sender(senderId: senderId!, displayName: senderName!)
        self.sentDate = sentDate!.dateValue()
        
        if let content = document.data()["content"] as? String {
            self.kind = .text(content)
            self.content = content
        } else {
            self.kind = .text("")
            self.content = ""
        }
    }
}
