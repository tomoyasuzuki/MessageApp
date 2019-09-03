//
//  ChatRoomViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

protocol ChatRoomViewControllerProtocol {
    func reloadData() -> Void
    func scrollToBottom() -> Void
}

class ChatRoomViewController: MessagesViewController {
    
    private let presenter = ChatRoomPresenter()
    
    var id: String!
    var name: String!
    
    init(id: String, name: String) {
        super.init(nibName: nil, bundle: nil)
        self.id = id
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePresenter()
        configureMessageUI()
        
        navigationItem.title = presenter.channel?.name
    }
}


extension ChatRoomViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        presenter.createMessage(text)
        inputBar.inputTextView.text = ""
    }
}

extension ChatRoomViewController {
    private func configurePresenter() {
        presenter.view = self
        presenter.channel = Channel(id: id, name: name)
        presenter.updateMessages()
    }
    
    private func configureMessageUI() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.green
    }
}

extension ChatRoomViewController: ChatRoomViewControllerProtocol {
    func reloadData() {
        messagesCollectionView.reloadData()
    }
    
    func scrollToBottom() {
        messagesCollectionView.scrollToBottom()
    }
}


extension ChatRoomViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return presenter.sender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return presenter.messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return presenter.messages[indexPath.section]
    }
}

extension ChatRoomViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .green : .white
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .black
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .pointedEdge)
    }
}

