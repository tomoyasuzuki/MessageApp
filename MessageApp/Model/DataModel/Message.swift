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
import AVFoundation

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
            self.size = CGSize(width: 200, height: 200)
            self.placeholderImage = UIImage()
        }
    }
    
    struct customAudioItem: AudioItem {
        var url: URL
        var duration: Float
        var size: CGSize
        
        init(audioURL: URL) {
            self.url = audioURL
            self.size = CGSize(width: 160, height: 35)
            let audioAsset = AVURLAsset(url: url)
            print(audioAsset.duration)
            self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
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
    
    init(audioURL: URL, sender: SenderType, messageId: String, sentDate: Date) {
        let audioItem = customAudioItem(audioURL: audioURL)
        print("duration: \(audioItem.duration)")
        self.init(kind: .audio(audioItem), sender: sender, sentDate: sentDate, messageId: messageId)
    }
}

