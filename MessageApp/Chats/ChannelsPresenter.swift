//
//  ChannelsPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/01.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth

protocol ChannelPresenterProtocol {
    func chatchChatsSnapshot() -> Void
    func handleDocumentChanged(change: DocumentChange) -> Void
    func insertNewChannel(_ channel: Channel) -> Void
    func addUserDocument(channelName: String) -> Void
}
final class ChannelPresenter: ChannelPresenterProtocol {
    private lazy var view = ChannelsViewController()
    
    private let ref = Firestore.firestore().collection("channels")
    private let user = Auth.auth().currentUser
    
    var channels: [Channel] = []
    
    func chatchChatsSnapshot() {
        guard  let user = user else { return }
        
        Firestore.firestore()
            .collection("channels")
            .whereField("members", arrayContains: user.uid)
            .addSnapshotListener { (querySnapshot, error) in
                if querySnapshot == nil || error != nil {
                    print("snapshot update error: \(error!.localizedDescription)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach { change in
                    self.handleDocumentChanged(change: change)
                }
        }
    }
    
    func handleDocumentChanged(change: DocumentChange) {
        guard let channel = Channel(change.document) else { return }
        
        switch change.type {
        case .added:
            insertNewChannel(channel)
        default:
            break
        }
    }
    
    func insertNewChannel(_ channel: Channel) {
        channels.append(channel)
        self.view.reloadTable()
    }
    
    func addUserDocument(channelName: String) {
        guard let user = user else { return }
        self.ref.addDocument(data: ["name": channelName, "members": [user.uid]])
    }
}
