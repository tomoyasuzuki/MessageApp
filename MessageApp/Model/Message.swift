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
    
    // 画像メッセージ用オブジェクト
    struct ImageMediaItem: MediaItem {
        var url: URL?
        var image: UIImage?
        var placeholderImage: UIImage
        var size: CGSize
        
        init(image: UIImage) {
            self.image = image
            self.size = CGSize(width: 100, height: 100)
            self.placeholderImage = UIImage()
        }
    }
    
    /*
 
     mainとなるinit.
     kindで生成するメッセージオブジェクトの種類を制御する
 
    */
    init(kind: MessageKind, sender: SenderType, sentDate: Date, messageId: String) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    
    /*
 
     kindに合わせてそれぞれinitを定義する
 
    */
    
    init(text: String, sender: SenderType, messageId: String, sentDate: Date) {
        self.init(kind: .text(text), sender: sender, sentDate: sentDate, messageId: messageId)
    }
    
    init(image: UIImage, sender: SenderType, messageId: String, sentDate: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, sentDate: sentDate, messageId: messageId)
    }
    
    
    
    
    
//    init?(document: QueryDocumentSnapshot) {
//        let sentDate = document.data()["sentDate"] as? Timestamp
//        let senderName = document.data()["senderName"] as? String
//        let senderId = document.data()["senderID"] as? String
//
//        self.messageId = document.documentID
//        self.sender = Sender(senderId: senderId!, displayName: senderName!)
//        self.sentDate = sentDate!.dateValue()
//
//        if let content = document.data()["content"] as? String {
//            self.kind = .text(content)
//            self.content = content
//            self.imageURL = nil
//        } else if let imageURL = document.data()["imageURL"] as? String {
//            self.kind = .photo(<#T##MediaItem#>)
//            self.content = ""
//            self.imageURL = imageURL
//        }
//    }
}
