//
//  ChatRoomPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/02.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MessageKit

protocol ChatRoomPresenterProtocol {
    func saveMessage(_ text: String) -> Void
    func saveImageMessage(_ url: URL) -> Void
    func saveAudioMessage(_ audioURL: URL) -> Void
    func updateMessages() -> Void
}

final class ChatRoomPresenter: ChatRoomPresenterProtocol {
    var view: ChatRoomViewControllerProtocol?
    
    var channel: Channel?
    var messages: [Message] = []
    
    let user = Auth.auth().currentUser
    var sender: Sender {
        let user = Auth.auth().currentUser
        return Sender(senderId: user!.uid, displayName: user!.displayName!)
    }
}

// MARK: Delegate

extension ChatRoomPresenter {
    func saveMessage(_ text: String) {
        let storedMessage = StoredMessageObject(senderId: sender.senderId, senderName: sender.displayName, content: text, sentDate: Date())
        FireBaseManager.shared.saveMessage(channelId: channel!.id, storedMessage: storedMessage) { (error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    func saveImageMessage(_ url: URL) {
        let storedMessage = StoredMessageObject(senderId: sender.senderId, senderName: sender.displayName, sentDate: Date(), imageURL: url)
        FireBaseManager.shared.saveMessage(channelId: channel!.id, storedMessage: storedMessage) { (error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    func saveAudioMessage(_ audioURL: URL) {
        let storedMessage = StoredMessageObject(senderId: sender.senderId, senderName: sender.displayName, sentDate: Date(), audioURL: audioURL)
        FireBaseManager.shared.saveMessage(channelId: channel!.id, storedMessage: storedMessage) { (error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    func updateMessages() {
        guard let channel = channel else { return }
        
        FireBaseManager.shared.bindSnapshot(channelId: channel.id) { (snapshot) in
            snapshot.documentChanges.forEach { [weak self] change in
                guard let self = self else { return }
                
                self.handleDocumentChange(change)
            }
        }
    }
}

// MARK: Image Helpers

extension ChatRoomPresenter {
    func saveImage(_ image: UIImage, comlition: @escaping(URL) -> ()) {
        FireBaseManager.shared.saveImageData(path: Resources.strings.KeyImage, image: image) { (downloadURL) in
            //  画像URL取得後の処理
            comlition(downloadURL)
        }
    }
    
    func getImage(url: URL, complition: @escaping(Data) -> ()) {
        FireBaseManager.shared.getImageData(url) { (data) in
            // 画像データ取得後の処理
            complition(data)
        }
    }
}

// MARK: Audio Helpers

extension ChatRoomPresenter {
    func saveAudioFile(_ localURL: URL, complition: @escaping(URL) -> ()) {
        FireBaseManager.shared.saveAudioData(localURL) { (downloadURL) in
            // 画像URL取得後の処理
            complition(downloadURL)
        }
    }
    
    func getAudioFile(_ url: URL, complition: @escaping(Data) -> ()) {
        FireBaseManager.shared.getAudioData(url) { (data) in
            // 画像データ取得後の処理
            complition(data)
        }
    }
}

// MARK: Private Methods

extension ChatRoomPresenter {
    private func handleDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            let document = change.document
            self.createMessage(document: document) { message in
                self.setup(message)
                self.view?.reloadData()
                self.view?.scrollToBottom()
            }
        default:
            break
        }
    }
    
    private func createMessage(document: QueryDocumentSnapshot, complition: @escaping(Message) -> ()) {
        let documentData = document.data()
        let timeStamp = documentData[Resources.strings.KeySentDate]
        
        let time = timeStamp as? Timestamp
        
        guard let date = time?.dateValue() else { return }
        
        if let content = documentData[Resources.strings.KeyContent] as? String, content != "" {
            let message = Message(text: content,
                                  sender: self.sender,
                                  messageId: "",
                                  sentDate: date)
            
            complition(message)
            
        } else if let imageURL = documentData[Resources.strings.KeyImageURL] as? String, imageURL != "" {
            if let url = URL(string: imageURL) {
                FireBaseManager.shared.getImageData(url) { (data) in
                    if let image = UIImage(data: data) {
                        let message = Message(image: image,
                                              sender: self.sender,
                                              messageId: "",
                                              sentDate: date)
                        
                        complition(message)
                    }
                }
            }
        } else if let audioURL = documentData[Resources.strings.KeyAudioURL] as? String, audioURL != "" {
            if let url = URL(string: audioURL) {
            let message = Message(audioURL: url,
                                  sender: self.sender,
                                  messageId: "",
                                  sentDate: date)
                
                complition(message)
            }
        }
    }
    
    private func setup(_ message: Message) {
        messages.append(message)
        let sortedMessages = messages.sortByDate()
        
        messages = sortedMessages
    }
}
