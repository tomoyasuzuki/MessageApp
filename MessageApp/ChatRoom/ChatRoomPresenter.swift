//
//  ChatRoomPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/02.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth

protocol ChatRoomPresenterProtocol {
    func createMessage(_ text: String) -> Void
    func saveMessage(_ message: Message) -> Void
    func updateMessages() -> Void
}

final class ChatRoomPresenter: ChatRoomPresenterProtocol {
    var view: ChatRoomViewControllerProtocol? = nil
    
    var channel: Channel? = nil
    var messages: [Message] = []
    
    let user = Auth.auth().currentUser
    var sender: Sender {
        let user = Auth.auth().currentUser
        return Sender(senderId: user!.uid, displayName: user!.displayName!)
    }
    
    private let db = Firestore.firestore()
    private var ref: CollectionReference {
        return db.collection(["channels", channel!.id, "threads"].joined(separator: "/"))
    }
    
    func createMessage(_ text: String) {
        let message = Message(sender: sender, content: text)
        saveMessage(message)
    }
    
    func saveMessage(_ message: Message) {
        ref.addDocument(data: ["senderID": message.sender.senderId,
                               "senderName": message.sender.displayName,
                               "sentDate": message.sentDate,
                               "content": message.content]) { [weak self] error in
                                guard let self = self else { return }
                                if error != nil {
                                    //print("error: \(error!.localizedDescription)")
                                    return
                                }
                                self.view?.scrollToBottom()
        }
    }
    
    func updateMessages() {
        ref.addSnapshotListener { snapshot, error in
            if error != nil {
                //print("error: \(error!.localizedDescription)")
                return
            }
            
            snapshot?.documentChanges.forEach { [weak self] change in
                guard let self = self else { return }
                self.handleDocumentChange(change)
            }
        }
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            guard let message = Message(document: change.document) else { return }
            self.messages.append(message)
            self.view?.reloadData()
        default:
            break
        }
    }
}
