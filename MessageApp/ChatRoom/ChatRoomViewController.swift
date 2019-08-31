//
//  ChatRoomViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import FirebaseFirestore
import InputBarAccessoryView

class ChatRoomViewController: MessagesViewController {
    let user = Auth.auth().currentUser
    var sender: Sender {
        return Sender(senderId: "any_unique_id", displayName: user?.displayName ?? "defauls name")
    }
    
    var channel: Channel!
    var messages: [MessageType] = []
    var messageListener: ListenerRegistration?
    
    private var db = Firestore.firestore()
    private var ref: CollectionReference?
    
    deinit {
        messageListener?.remove()
    }
    
    init(id: String, name: String) {
        super.init(nibName: nil, bundle: nil)
        channel = Channel(id: id, name: name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = channel?.name ?? "default"
        
        guard let channelId = channel?.id else { return }
        ref = db.collection(["channels", channelId, "threads"].joined(separator: "/"))
        
        messageListener = ref?.addSnapshotListener({ (querySnapshot, error) in
            if querySnapshot == nil || error != nil {
                print("snapshot update error: \(error!.localizedDescription)")
                return
            }
            
            querySnapshot?.documentChanges.forEach({ change in
                self.handleDocumentChanged(change)
            })
        })

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.green
        
        print(channel.id, channel.name)
    }
    // MARK: - Helpers
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        messagesCollectionView.reloadData()
    }
    
    private func handleDocumentChanged(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else { return }
        print(message.content)
        
        switch change.type {
        case .added:
            insertNewMessage(message)
        default:
            break
        }
        
    }
    func save(_ message: Message) {
        ref?.addDocument(data: ["sentDate": message.sentDate, "senderID": sender.senderId, "senderName": sender.displayName,"content": message.content], completion: { error in
            if error != nil {
                print("error: \(error!.localizedDescription)")
                return
            }
            self.messagesCollectionView.scrollToBottom()
        })
    }
}


extension ChatRoomViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(content: text)
        print(message.sentDate)
        save(message)
        
        inputBar.inputTextView.text = ""
    }
}


extension ChatRoomViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(senderId: "any_unique_id", displayName: "Steven")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension ChatRoomViewController: MessagesLayoutDelegate {
    
}


extension ChatRoomViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {

        // 1
        return isFromCurrentSender(message: message) ? UIColor.green : UIColor.red
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {

        // 2
        return false
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft

        // 3
        return .bubbleTail(corner, .curved)
    }
}

