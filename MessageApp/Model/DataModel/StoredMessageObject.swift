//
//  OutputMessageObject.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/19.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//
import Foundation

final class StoredMessageObject {
    let senderId: String
    let senderName: String
    let content: String?
    let sentDate: String
    let imageURL: String?
    let audioURL: String?
    
    init(senderId: String, senderName: String, content: String? = nil, sentDate: Date, imageURL: URL? = nil, audioURL: URL? = nil ) {
        self.senderId = senderId
        self.senderName = senderName
        
        let date = sentDate.description
        self.sentDate = date
        
        self.content = content
        
        if let iurl = imageURL {
            self.imageURL = iurl.absoluteString
        } else {
            self.imageURL = nil
        }
        
        if let aurl = audioURL {
            self.audioURL = aurl.absoluteString
        } else {
            self.audioURL = nil
        }
    }
}
